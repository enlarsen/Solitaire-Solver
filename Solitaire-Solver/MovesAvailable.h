//
//  MovesAvailable.h
//  Solitaire-Solver
//
//  Created by Erik Larsen on 5/4/14.
//  Copyright (c) 2014 Erik Larsen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Moves;
@class Stacks;

@interface MovesAvailable : NSObject

@property (nonatomic, strong) Moves *interTableauMoves;
@property (nonatomic, strong) Moves *fromTalonMoves;
@property (nonatomic, strong) Moves *toFoundationMoves;
@property (nonatomic, strong) Moves *foundationToTableauMoves;

- (instancetype)initWithStacks:(Stacks *)stacks;
- (void)updateMoves;

@end
