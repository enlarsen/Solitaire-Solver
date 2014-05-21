//
//  GameState.m
//  Solitaire-Solver
//
//  Created by Erik Larsen on 5/6/14.
//  Copyright (c) 2014 Erik Larsen. All rights reserved.
//

#import "GameState.h"

@interface GameState()


@end


@implementation GameState

// key=move hash, value=board hash
- (NSMutableDictionary *)moves
{
    if(!_moves)
    {
        _moves = [[NSMutableDictionary alloc] init];
    }
    return _moves;
}

- (NSString *)description
{
    return [[NSString stringWithFormat:@"%@", self.moves] copy];
}

@end
