//
//  GameState.h
//  Solitaire-Solver
//
//  Created by Erik Larsen on 5/6/14.
//  Copyright (c) 2014 Erik Larsen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameState : NSObject

@property (strong, nonatomic) NSMutableDictionary *moves; // key: move hash, value: board hash


@end
