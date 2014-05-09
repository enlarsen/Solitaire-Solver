//
//  Deck.h
//  Solitaire-Solver
//
//  Created by Erik Larsen on 5/2/14.
//  Copyright (c) 2014 Erik Larsen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Card;

@interface Deck : NSObject

@property (nonatomic, readonly) int count;

- (void)shuffle;
- (Card *)objectAtIndexedSubscript:(NSUInteger)index;
- (void)setObject:(Card *)card atIndexedSubscript:(NSUInteger)index;
- (instancetype)initAndShuffle;
- (Card *)deal;

@end
