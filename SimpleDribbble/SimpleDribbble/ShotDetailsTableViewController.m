//  ShotDetailsTableViewController.m
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

#import "ShotDetailsTableViewController.h"

#define kShotTableViewCellHeight       225.0f
#define kShotPlayerTableViewCellHeight 80.0f

@interface ShotDetailsTableViewController ()

@end

@implementation ShotDetailsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back_button.png"] style:UIBarButtonItemStylePlain target:self action:@selector(popBack)];

    self.navigationItem.leftBarButtonItem = item;
    
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.allowsSelection = NO;
    self.tableView.alwaysBounceVertical = NO;
}

#pragma mark - Private methods

- (void)popBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    
    if (indexPath.row == 0) {
        ShotTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ShotTableViewCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
    
        cell.title.text = self.shot.title;
        cell.viewsCount.text = [self.shot.viewsCount stringValue];
        
        if (self.shot.image400Url != nil) {
            [cell.image setImageWithURL:[NSURL URLWithString:self.shot.image400Url] placeholderImage:[UIImage imageNamed:@"placeholder_details.png"] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        } else {
            [cell.image setImageWithURL:[NSURL URLWithString:self.shot.imageUrl] placeholderImage:[UIImage imageNamed:@"placeholder_details.png"] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        }
    
        return cell;
    } else if (indexPath.row == 1) {
        ShotPlayerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ShotPlayerTableViewCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        
        cell.playerName.text = self.shot.player.name;
        [cell.playerImage setImageWithURL:[NSURL URLWithString:self.shot.player.avatarUrl] placeholderImage:[UIImage imageNamed:@"no_player.png"] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
        return cell;
    } else {
        ShotDescriptionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ShotDescriptionTableViewCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        
        if (self.shot.descriptionText == nil) {
            self.shot.descriptionText = @"No description";
        }
        
        NSString *shotDescriptionHTML = [NSString stringWithFormat:@"<html> \n"
                                               "<head> \n"
                                               "<style type=\"text/css\"> \n"
                                               "body {font-family: \"%@\"; font-size: %@;}\n"
                                               "</style> \n"
                                               "</head> \n"
                                               "<body>%@</body> \n"
                                               "</html>", @"helvetica", [NSNumber numberWithInt:14], self.shot.descriptionText];
        [cell.shotDescription loadHTMLString:shotDescriptionHTML baseURL:nil];
        
        cell.shotDescription.delegate = self;
        cell.shotDescription.scrollView.scrollEnabled = NO;
        cell.shotDescription.scrollView.bounces = NO;
        
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
            return kShotTableViewCellHeight;
        case 1:
            return kShotPlayerTableViewCellHeight;
        default:
            return 0;
    }
}

- (void)webViewDidFinishLoad:(nonnull UIWebView *)webView
{
    // TODO: improve it!
    
    // update webview size
    CGRect newBounds = webView.bounds;
    newBounds.size.height = webView.scrollView.contentSize.height;
    webView.bounds = newBounds;
    
    // update cell size
    UITableViewCell *cell = (UITableViewCell *)webView.superview.superview;
    CGRect newFrame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, cell.frame.size.width, newBounds.size.height);
    cell.frame = newFrame;
 
    // scroll height calculated with all cells
    float scrollHeight = kShotTableViewCellHeight + kShotPlayerTableViewCellHeight + cell.frame.size.height;
    self.tableView.contentSize = CGSizeMake(self.tableView.contentSize.width, scrollHeight);
}

@end
