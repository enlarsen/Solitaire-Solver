//
//  Move.h
//  Solitaire-Solver
//
//  Created by Erik Larsen on 4/30/14.
//  Copyright (c) 2014 Erik Larsen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Card;
@interface Move : NSObject //<NSCopying>

@property (nonatomic) unsigned char from;
@property (nonatomic) unsigned char to;
@property (nonatomic) unsigned char count;
@property (nonatomic) BOOL flipped;
@property (nonatomic, strong) Card *card;

- (instancetype)initWithMoveFrom:(unsigned char)from to:(unsigned char)to
                       withCount:(unsigned char)count;
- (instancetype)initWithMoveFrom:(unsigned char)from to:(unsigned char)to
                       withCard:(Card *)card;

- (void)setMoveFrom:(unsigned char)from to:(unsigned char)to
                        withCount:(unsigned char)count;
- (void)setMoveFrom:(unsigned char)from to:(unsigned char)to
                        withCard:(Card *)card;

- (NSString *)moveHash;

@end
