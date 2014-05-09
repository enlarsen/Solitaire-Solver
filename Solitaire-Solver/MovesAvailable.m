//
//  MovesAvailable.m
//  Solitaire-Solver
//
//  Created by Erik Larsen on 5/4/14.
//  Copyright (c) 2014 Erik Larsen. All rights reserved.
//

#import "MovesAvailable.h"
#import "Moves.h"
#import "Move.h"
#import "Stacks.h"

@interface MovesAvailable()

@property (nonatomic, strong) Stacks *stacks;

@end

@implementation MovesAvailable

#pragma mark - Properties

- (Moves *)interTableauMoves
{
    if(!_interTableauMoves)
    {
        _interTableauMoves = [[Moves alloc] init];
    }
    return _interTableauMoves;
}

- (Moves *)fromTalonMoves
{
    if(!_fromTalonMoves)
    {
        _fromTalonMoves = [[Moves alloc] init];
    }
    return _fromTalonMoves;
}

- (Moves *)toFoundationMoves
{
    if(!_toFoundationMoves)
    {
        _toFoundationMoves = [[Moves alloc] init];
    }
    return _toFoundationMoves;
}

-(Moves *)foundationToTableauMoves
{
    if(!_foundationToTableauMoves)
    {
        _foundationToTableauMoves = [[Moves alloc] init];
    }
    return _foundationToTableauMoves;
}

#pragma mark - init

- (instancetype)initWithStacks:(Stacks *)stacks
{
    self = [self init];
    if(self)
    {
        self.stacks = stacks;
    }
    return self;
}


- (void)updateMoves
{
    // TODO: run in global queue;

    self.interTableauMoves = [self.stacks findInterTableauMoves];
    self.fromTalonMoves = [self.stacks findTalonMoves];
    self.foundationToTableauMoves = [self.stacks findFoundationMoves];
    self.toFoundationMoves = [self.stacks findFoundationMoves];
}

@end
