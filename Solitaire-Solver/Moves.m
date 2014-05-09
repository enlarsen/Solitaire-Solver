//
//  Moves.m
//  Solitaire-Solver
//
//  Created by Erik Larsen on 5/2/14.
//  Copyright (c) 2014 Erik Larsen. All rights reserved.
//

// implements a collection of moves

#import "Moves.h"
#import "Move.h"

@interface Moves()

@property (strong, nonatomic) NSMutableArray *moves;

@end

@implementation Moves

- (NSMutableArray *)moves
{
    if(!_moves)
    {
        _moves = [NSMutableArray new];
    }
    return _moves;
}

- (int)count
{
    return (int)self.moves.count;
}

- (void)add:(Move *)move
{
    [self.moves addObject:[move copy]];
}

- (void)addMoves:(Moves *)moves
{
    if(moves)
    {
        [self.moves addObjectsFromArray:moves.moves];
    }
}

- (NSString *)description
{
    NSMutableString *string = [[NSMutableString alloc] init];

    for(Move *move in self.moves)
    {
        [string appendFormat:@"%@\n", [move description]];
    }
    return [string copy];
}

- (void)removeAllObjects
{
    [self.moves removeAllObjects];
}

- (void)removeLastObject
{
    [self.moves removeLastObject];
}

- (Move *)lastObject
{
    return [self.moves lastObject];
}

- (Move *)objectAtIndexedSubscript:(NSUInteger)index
{
    return self.moves[index];
}

- (void)setObject:(Move *)move atIndexedSubscript:(NSUInteger)index
{
    self.moves[index] = move;
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state
                                  objects:(id __unsafe_unretained[])buffer
                                    count:(NSUInteger)len
{
    return [self.moves countByEnumeratingWithState:state
                                           objects:buffer
                                             count:len];
}
@end
