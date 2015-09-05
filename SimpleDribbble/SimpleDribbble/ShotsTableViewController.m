//  TableViewController.m
//  Thiago Rossener ( https://github.com/thiagoross/SimpleDribbble )
//
//  Copyright (c) 2015 Rossener ( http://www.rossener.com/ )
//
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "ShotsTableViewController.h"

@implementation ShotsTableViewController

#pragma mark - Superclass methods

- (id)initWithCoder:(nonnull NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        UIImage *image = [UIImage imageNamed:@"dribbble_normal.png"];
        self.navigationItem.titleView = [[UIImageView alloc] initWithImage:image];
        
        [JSONModel setGlobalKeyMapper:[JSONKeyMapper mapperFromUnderscoreCaseToCamelCase]];
        
        self.pageCounter = 1; // Starts at this page
        
        self.shotDAO = [ShotsUpdater sharedInstance];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.allowsSelection = NO;
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [self.tableView addGestureRecognizer:singleTap];
    
    PullToRefreshView *pullToRefreshView = [[[NSBundle mainBundle] loadNibNamed:@"PullToRefreshView" owner:self options:nil] objectAtIndex:0];
    
    ReleaseToRefreshView *releaseToRefreshView = [[[NSBundle mainBundle] loadNibNamed:@"ReleaseToRefreshView" owner:self options:nil] objectAtIndex:0];
    
    UIImageView *loading = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loading.png"]];
    loading.frame = CGRectMake(0.0f, 0.0f, 25.0f, 25.0f);
    
    NoMoreUpdatesView *noMoreUpdatesView = [[[NSBundle mainBundle] loadNibNamed:@"NoMoreUpdatesView" owner:self options:nil] objectAtIndex:0];
    
    __weak ShotsTableViewController *weakSelf = self;
    
    // Set up pull-to-refresh
    [self.tableView addPullToRefreshWithActionHandler:^{
        [AnimationUtils rotateLayerInfinite:loading.layer];
        
        if (weakSelf.pageCounter > [[weakSelf.shotDAO currentPage] pages]) {
            [weakSelf.tableView.pullToRefreshView stopAnimating];
            
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:NSLocalizedString(@"No more updates", nil)
                                  message:NSLocalizedString(@"All shots are loaded.\nCome back later :)", nil)
                                  delegate:nil
                                  cancelButtonTitle:NSLocalizedString(@"Ok", nil)
                                  otherButtonTitles:nil];
            [alert show];
        } else {
            [weakSelf.shotDAO findShotsForPage:weakSelf.pageCounter sender:weakSelf updateOn:UPDATE_ON_TOP];
        }
    }];
    
    [self.tableView.pullToRefreshView setCustomView:pullToRefreshView forState:SVPullToRefreshStateStopped];
    [self.tableView.pullToRefreshView setCustomView:releaseToRefreshView forState:SVPullToRefreshStateTriggered];
    [self.tableView.pullToRefreshView setCustomView:loading forState:SVPullToRefreshStateLoading];
    
    // Set up infinite scrolling
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        if (weakSelf.shotDAO.currentPage != nil && weakSelf.pageCounter > [[weakSelf.shotDAO currentPage] pages]) {
            [weakSelf.tableView.infiniteScrollingView setCustomView:noMoreUpdatesView forState:SVInfiniteScrollingStateAll];
            [weakSelf.tableView.infiniteScrollingView stopAnimating];
        } else {
            [AnimationUtils rotateLayerInfinite:loading.layer];
            [weakSelf.shotDAO findShotsForPage:weakSelf.pageCounter sender:weakSelf updateOn:UPDATE_ON_BOTTOM];
        }
    }];
    
    [self.tableView.infiniteScrollingView setCustomView:loading forState:SVInfiniteScrollingStateAll];
    
    [self.tableView triggerInfiniteScrolling];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadFirstShots) name:UIApplicationWillEnterForegroundNotification object:[UIApplication sharedApplication]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - ShotsUpdaterDelegate

- (void)updateOnTopShots:(NSArray *)shots withStatus:(int)status
{
    switch (status) {
        case 200: {
                for (Shot *shot in shots) {
                    [self.tableView beginUpdates];
                    [self.shotDAO.shots insertObject:shot atIndex:0];
                    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
                    [self.tableView endUpdates];
                }
                self.pageCounter++;
            }
            break;
        case 408:
            [self showTimeoutAlert];
            break;
        case 400:
        case 500:
        default:
            [self showErrorAlertWithStatus:status];
            break;
    }
    
    [self.tableView.pullToRefreshView stopAnimating];
}

- (void)updateOnBottomShots:(NSArray *)shots withStatus:(int)status
{
    switch (status) {
        case 200: {
                for (Shot *shot in shots) {
                    [self.tableView beginUpdates];
                
                    [self.shotDAO.shots addObject:shot];
                    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.shotDAO.shots.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
                
                    [self.tableView endUpdates];
                }
                self.pageCounter++;
            }
            break;
        case 408:
            [self showTimeoutAlert];
            break;
        case 400:
        case 500:
        default:
            [self showErrorAlertWithStatus:status];
            break;
    }
    
    [self.tableView.infiniteScrollingView stopAnimating];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.shotDAO.shots.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    
    ShotTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ShotTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    // Set up loading view
    UIImageView *loading = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loading.png"]];
    loading.frame = CGRectMake(0.0f, 0.0f, 25.0f, 25.0f);
    loading.center = CGPointMake(cell.image.center.x, cell.image.center.y - 30.0f);
    
    // Fill data from shot
    Shot *shot = [[self.shotDAO shots] objectAtIndex:indexPath.row];
    cell.title.text = shot.title;
    cell.viewsCount.text = [shot.viewsCount stringValue];
    [cell.image sd_setImageWithURL:[NSURL URLWithString:shot.image400Url]
                  placeholderImage:[UIImage imageNamed:@"placeholder.png"]
                completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL){ [loading removeFromSuperview];
                }];
    
    // Add loading in UIImageView only if it is not cached
    [[SDImageCache sharedImageCache] queryDiskCacheForKey:shot.image400Url done:^(UIImage *image, SDImageCacheType cacheType) {
        if (image == nil) {
            [cell.image addSubview:loading];
            [AnimationUtils rotateLayerInfinite:loading.layer];
        }
    }];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 225;
}

#pragma mark - Private methods

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer
{
    CGPoint locationInView = [recognizer locationInView:recognizer.view];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:locationInView];
    ShotTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    CGPoint locationInImage = [recognizer.view convertPoint:locationInView toView:cell.image];
    
    // Tap inside item
    if (CGRectContainsPoint(cell.image.bounds, locationInImage) ) {

        // Set up animation
        UIView *selection = [[UIView alloc] initWithFrame:CGRectMake(locationInImage.x - 10.0f, locationInImage.y - 10.0f, 20.0f, 20.0f)];
        selection.backgroundColor = [UIColor colorWithRed:256.0f/256.0f green:256.0f/256.0f blue:256.0f/256.0f alpha:0.3f];
        selection.layer.cornerRadius = selection.frame.size.width / 2;
        selection.clipsToBounds = YES;
        [cell.image addSubview:selection];
        
        // Prepare next view
        Shot *shot = [[self.shotDAO shots] objectAtIndex:indexPath.row];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ShotDetailsTableViewController *details = [storyboard instantiateViewControllerWithIdentifier:@"Details"];
        details.shot = shot;
        
        // Animate
        [UIView animateWithDuration:0.2f animations:^{
            selection.frame = CGRectMake(selection.center.x - 250.0f, selection.center.y - 250.0f, 500.0f, 500.0f);
        } completion:^(BOOL finished) {
            [selection removeFromSuperview];
            [self.navigationController pushViewController:details animated:YES];
        }];
    }
}

- (void)showTimeoutAlert
{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:NSLocalizedString(@"Timeout", nil)
                          message:NSLocalizedString(@"Your connection is weak at the moment. Try again later.", nil)
                          delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"Ok", nil)
                          otherButtonTitles:nil];
    [alert show];
}

- (void)showErrorAlertWithStatus:(int)statusCode
{
    NSLog(@"[%@] Error with status code: %d", self.class, statusCode);
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:NSLocalizedString(@"Sorry :(", nil)
                          message:NSLocalizedString(@"Occured an error trying to retrieve shots. Please try again.", nil)
                          delegate:self
                          cancelButtonTitle:NSLocalizedString(@"Ok", nil)
                          otherButtonTitles:nil];
    [alert show];
}

- (void)loadFirstShots
{
    if (self.shotDAO.shots.count == 0) {
        [self.tableView triggerInfiniteScrolling];
    }
}

@end
