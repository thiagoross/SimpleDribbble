//  Shot.m
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

#import "Shot.h"

@implementation Shot

- (NSString *)description
{
    return [NSString stringWithFormat:@"{ id:\"%d\", title:%@, description:%@, width:%@, height:%@, likes_count:%@, comments_count:%@, rebounds_count:%@, url:%@, short_url:%@, views_count:%@, rebound_source_id:%@, image_url:%@, image_teaser_url:%@, image_400_url:%@, created_at:%@ }",
                                        self.itemId,
                                        self.title,
                                        self.descriptionText,
                                        self.width,
                                        self.height,
                                        self.likesCount,
                                        self.commentsCount,
                                        self.reboundsCount,
                                        self.url,
                                        self.shortUrl,
                                        self.viewsCount,
                                        self.reboundSourceId,
                                        self.imageUrl,
                                        self.imageTeaserUrl,
                                        self.image400Url,
                                        self.createdAt];
}

+ (JSONKeyMapper *)keyMapper
{
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                      @"id":@"itemId",
                                                      @"description": @"descriptionText"
                                                      }];
}

+ (BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}

@end
