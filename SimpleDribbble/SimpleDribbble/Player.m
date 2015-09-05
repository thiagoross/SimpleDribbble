//  Player.m
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

#import "Player.h"

@implementation Player

- (NSString *)description
{
    return [NSString stringWithFormat:@"{ id:\"%d\", name:%@, location:%@, followers_count:%@, draftees_count:%@, likes_count:%@, likes_received_count:%@, comments_count:%@, comments_received_count:%@, rebounds_count:%@, rebounds_received_count:%@, url:%@, avatar_url:%@, username:%@, twitter_screen_name:%@, website_url:%@, drafted_by_player:%@, shots_count:%@, following_count:%@, created_at:%@ }",
            self.itemId,
            self.name,
            self.location,
            self.followersCount,
            self.drafteesCount,
            self.likesCount,
            self.likesReceivedCount,
            self.commentsCount,
            self.commentsReceivedCount,
            self.reboundsCount,
            self.reboundsReceivedCount,
            self.url,
            self.avatarUrl,
            self.username,
            self.twitterScreenName,
            self.websiteUrl,
            self.draftedByPlayerId,
            self.shotsCount,
            self.followingCount,
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
