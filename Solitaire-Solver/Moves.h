//
//  Moves.h
//  Solitaire-Solver
//
//  Created by Erik Larsen on 5/2/14.
//  Copyright (c) 2014 Erik Larsen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Move;

@interface Moves : NSObject <NSFastEnumeration>

@property (nonatomic, readonly) int count;

- (void)add:(Move *)move;
- (void)removeAllObjects;
- (void)removeLastObject;
- (Move *)lastObject;
- (Move *)objectAtIndexedSubscript:(NSUInteger)index;
- (void)setObject:(Move *)move atIndexedSubscript:(NSUInteger)index;
- (void)addMoves:(Moves *)moves;

@end
