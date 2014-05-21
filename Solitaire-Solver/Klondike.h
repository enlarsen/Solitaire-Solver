//
//  Klondike.h
//  Solitaire-Solver
//
//  Created by Erik Larsen on 5/2/14.
//  Copyright (c) 2014 Erik Larsen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Klondike : NSObject

@property (nonatomic, assign) int states;

- (void)play;
//- (int)playNGames:(int)numberOfGames;
- (int)playNGamesCompletely:(int)numberOfGames;

@end
