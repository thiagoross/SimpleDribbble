//  ShotUpdater.m
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

#import "ShotsUpdater.h"

@implementation ShotsUpdater

ShotsUpdater *_self = nil;

#pragma mark - Superclass methods

- (id)init
{
    self = [super init];
    if (self) {
        self.shots = [NSMutableArray new];
    }
    return self;
}

#pragma mark - Public methods

+ (id)sharedInstance
{
    if (!_self) {
        _self = [ShotsUpdater new];
    }
    return _self;
}

- (void)findShotsForPage:(int)pageNumber sender:(id<ShotsUpdaterDelegate>)sender updateOn:(UpdatePosition)position
{
    NSLog(@"[%@] Looking for shots in page '%d'", self.class, pageNumber);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager new];
    
    NSDictionary *parameters = @{@"page": [NSNumber numberWithInt:pageNumber]};
    
    [manager GET:kURLDribbblePopularShots parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         // Success
         if ([responseObject isKindOfClass:[NSDictionary class]]) {
             Page *page = [self convertToPage:responseObject];
             [self returnPage:page withStatus:(int)operation.response.statusCode to:sender updateOn:position];
             self.currentPage = page;
         } else {
             NSLog(@"[%@] Page received is not a dictionary!", self.class);
         }
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         // Failure
         if (error.code == NSURLErrorTimedOut) {
             [self returnPage:nil withStatus:408 to:sender updateOn:position];
         } else {
             [self returnPage:nil withStatus:(int)operation.response.statusCode to:sender updateOn:position];
         }
         
         NSLog(@"[%@] Error trying to find shots for page '%d'. %@", self.class, pageNumber, error);
     }];
}

#pragma mark - Private methods

- (Page *)convertToPage:(id)object
{
    Page *page = [[Page alloc] initWithDictionary:object error:nil];
    
    NSMutableArray *shots = [NSMutableArray new];
    for (id object in page.shots) {
        NSError *error = nil;
        Shot *shot = [[Shot alloc] initWithDictionary:object error:&error];
        
        if (error == nil && shot != nil) {
            [shots addObject:shot];
        }
    }
    
    page.shots = shots;
    
    return page;
}

- (void)returnPage:(Page *)page withStatus:(int)status to:(id)sender updateOn:(UpdatePosition)position
{
    if (position == UPDATE_ON_TOP && [sender respondsToSelector:@selector(updateOnTopShots:withStatus:)]) {
        if (page != nil) {
            [sender updateOnTopShots:[NSArray arrayWithArray:page.shots] withStatus:status];
        } else {
            [sender updateOnTopShots:nil withStatus:status];
        }
    } else if (position == UPDATE_ON_BOTTOM && [sender respondsToSelector:@selector(updateOnBottomShots:withStatus:)]) {
        if (page != nil) {
            [sender updateOnBottomShots:[NSArray arrayWithArray:page.shots] withStatus:status];
        } else {
            [sender updateOnBottomShots:nil withStatus:status];
        }
    } else {
        NSLog(@"[%@] Method shotsFound:withStatus:updateOn: is not implemented.", self.class);
    }
}

@end
