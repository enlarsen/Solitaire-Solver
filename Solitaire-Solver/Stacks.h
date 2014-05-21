//
//  Stacks.h
//  Solitaire-Solver
//
//  Created by Erik Larsen on 5/2/14.
//  Copyright (c) 2014 Erik Larsen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Stack;
@class Moves;
@class Deck;
@class Move;

enum Piles {
	STOCK = 0,
	TABLEAU1,
	TABLEAU2,
	TABLEAU3,
	TABLEAU4,
	TABLEAU5,
	TABLEAU6,
	TABLEAU7,
	FOUNDATION1C,
	FOUNDATION2D,
	FOUNDATION3S,
	FOUNDATION4H
};

@interface Stacks : NSObject

@property (nonatomic, readonly) int count;
@property (nonatomic, readonly) int foundationValue;
@property (nonatomic, readonly) int maxFoundationValue;
@property (nonatomic, strong) Moves *moveHistory;
@property (nonatomic, strong) NSMutableDictionary *gameStateGraph;


- (Stack *)objectAtIndexedSubscript:(NSUInteger)index;
- (void)setObject:(Stack *)stack atIndexedSubscript:(NSUInteger)index;
- (void)enumerateTableausUsingBlock:(void (^)(Stack *stack, int index, BOOL *stop))block;
- (void)enumerateFoundationUsingBlock:(void (^)(Stack *stack, int index, BOOL *stop))block;
- (void)enumerateTableausInPairsUsingBlock:(void (^)(Stack *stack1, Stack *stack2,
                                                     int index1, int index2, BOOL *stop))block;
- (void)dealCards:(Deck *)deck;
- (Moves *)findAvailableMoves;
- (void)move:(Move *)move;
- (void)undoMove:(Move *)move;
- (NSString *)gameBoardHashKey;

- (Moves *)findTalonMoves;
- (Moves *)findFoundationToTableauMoves;
- (Moves *)findInterTableauMoves;
- (Moves *)findFoundationMoves;

- (BOOL)takeNextMoveOrUndo:(Moves *)moves;

- (BOOL)isGameWon;

- (void)resetTalon;

- (void)resetStacks;

@end
