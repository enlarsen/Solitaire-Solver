//
//  Stack.h
//  Solitaire-Solver
//
//  Created by Erik Larsen on 4/30/14.
//  Copyright (c) 2014 Erik Larsen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Card;



@interface Stack : NSObject

- (void)addDown:(Card *)card;
- (void)addUp:(Card *)card;
- (void)flip;
- (void)move:(Stack *)to;
- (void)move:(Stack *)to withCount:(int)count;
- (void)move:(Stack *)to withCard:(Card *)card;
- (void)undoMove:(Stack *)from;
- (void)undoMove:(Stack *)from withCount:(int)count;
- (void)reset;
- (int)size;
- (int)downSize;
- (int)upSize;
- (Card *)down:(int)index;
- (Card *)up:(int)index;
- (Card *)low;
- (Card *)high;
- (NSString *)stackAsStringForHash;

- (void)moveDownToUp;

@end
