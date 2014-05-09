//
//  Stack.m
//  Solitaire-Solver
//
//  Created by Erik Larsen on 4/30/14.
//  Copyright (c) 2014 Erik Larsen. All rights reserved.
//

#import "Stack.h"
#import "Card.h"

@interface Stack()

@property (nonatomic, strong) NSMutableArray *down; // of Card
@property (nonatomic, strong) NSMutableArray *up; // of Card;
@property (nonatomic) int previousUpSize; // used for undoing the move

@end

@implementation Stack

- (NSMutableArray *)down
{
    if(!_down)
    {
        _down = [NSMutableArray new];

    }
    return _down;
}

- (NSMutableArray *)up
{
    if(!_up)
    {
        _up = [NSMutableArray new];
    }
    return _up;
}

- (void)addDown:(Card *)card
{
    [self.down addObject:card];
}

- (void)addUp:(Card *)card
{
    [self.up addObject:card];
}

- (void)flip
{
    if(self.size == 0)
    {
        return;
    }
    if(self.up.count > 0)
    {
        [self.down addObject:[self.up lastObject]];
        [self.up removeLastObject];
    }
    else
    {
        [self.up addObject:[self.down lastObject]];
        [self.down removeLastObject];
    }
}

- (void)moveDownToUp
{
    for(int i = 0; i < self.down.count; i++)
    {
        [self.up addObject:[self.down lastObject]];
        [self.down removeLastObject];
    }
}

- (void)move:(Stack *)to
{
    [to addUp:[self.up lastObject]];
    [self.up removeLastObject];
    self.previousUpSize = self.upSize; // Save this state in case of an undo
    if(self.upSize == 0)
    {
        [self flip];
    }
}

- (void)move:(Stack *)to withCount:(int)count
{
    if(self.size == 0)
    {
        return;
    }
    for(int i = (int)self.up.count - count; i < self.up.count; i++)
    {
        [to addUp:self.up[i]];
    }
    [self.up removeObjectsInRange:NSMakeRange(self.up.count - count, count)];
    self.previousUpSize = self.upSize; // Save this state in case of an undo
    if(self.upSize == 0)
    {
        [self flip];
    }

}

- (void)move:(Stack *)to withCard:(Card *)card
{
    NSUInteger index = [self.up indexOfObjectIdenticalTo:card];

    if(index == NSNotFound)
    {
        NSLog(@"Could not find card in stack from move:to:withCard");
    }
    [to addUp:card];
    [self.up removeObjectAtIndex:index];
}

- (void)undoMove:(Stack *)from
{
    if(self.previousUpSize == 0)
    {
        [self flip];
    }
    [from move:self];
}

- (void)undoMove:(Stack *)from withCount:(int)count
{
    if(self.previousUpSize == 0)
    {
        [self flip];
    }
    [from move:self withCount:count];
}

- (void)reset
{
    [self.up removeAllObjects];
    [self.down removeAllObjects];
}

- (int)size
{
    return (int)self.up.count + (int)self.down.count;
}

- (int)downSize
{
    return (int)self.down.count;
}

- (int)upSize
{
    return (int)self.up.count;
}

- (Card *)down:(int)index
{
    return (Card *)self.down[index];
}

- (Card *)up:(int)index
{
    return (Card *)self.up[index];
}

- (Card *)low
{
    return (Card *)[self.up lastObject];
}

- (Card *)high
{
    return (Card *)[self.up firstObject];
}

- (NSString *)stackAsStringForHash
{
    NSMutableString *string = [[NSMutableString alloc] init];

    for(int i = 0; i < self.upSize; i++)
    {
        [string appendFormat:@"%0.2d", ((Card *)self.up[i]).value];
    }

    return [string copy];
}

- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"<%@:%p%@>",
            [self class],
            self,
            @{@"up":_up,
              @"down":_down
              }];
}

- (NSString *)description
{
    NSMutableString *string = [[NSMutableString alloc] init];

    [string appendFormat:@"up: "];
    for(Card *card in self.up)
    {
        [string appendFormat:@"%@ ",[card description]];
    }
    [string appendFormat:@"\ndown: "];
    for(Card *card in self.down)
    {
        [string appendFormat:@"%@ ", [card description]];
    }

    return [string copy];

}

@end
