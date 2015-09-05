//  Shot.h
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

#import "JSONModel.h"
#import "Player.h"

@interface Shot : JSONModel

@property int itemId;
@property NSString *title;
@property NSString *descriptionText;
@property NSNumber *width;
@property NSNumber *height;
@property NSNumber *likesCount;
@property NSNumber *commentsCount;
@property NSNumber *reboundsCount;
@property NSString *url;
@property NSString *shortUrl;
@property NSNumber *viewsCount;
@property NSNumber *reboundSourceId;
@property NSString *imageUrl;
@property NSString *imageTeaserUrl;
@property NSString *image400Url;
@property Player *player;
@property NSDate *createdAt;

@end