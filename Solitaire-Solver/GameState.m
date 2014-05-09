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

- (NSMutableArray *)parents
{
    if(!_parents)
    {
        _parents = [[NSMutableArray alloc] init];
    }
    return _parents;
}

- (NSMutableArray *)children
{
    if(!_children)
    {
        _children = [[NSMutableArray alloc] init];
    }
    return _children;
}


- (instancetype)init
{
    self = [super init];
    if(self)
    {
        self.timesSeen = 0;
    }
    return self;
}

@end
