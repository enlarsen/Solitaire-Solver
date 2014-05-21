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

- (void)moveOneCardDownToUp
{
    if(self.down.count > 0)
    {
        [self.up addObject:[self.down lastObject]];
        [self.down removeLastObject];
    }
}

- (void)moveOneCardUpToDown
{
    if(self.up.count > 0)
    {
        [self.down addObject:[self.up lastObject]];
        [self.up removeLastObject];
    }
}

// Either flips up the last card in the down stack or
// flips down the top up (and only) up card.
//- (void)flipTopCarda
//{
//    if(self.size == 0 || self.up.count > 1)
//    {
//        self.flipOnUndo = NO;
//        return;
//    }
//    if(self.up.count == 1)
//    {
//        self.flipOnUndo = YES;
//        [self.down addObject:[self.up lastObject]];
//        [self.up removeLastObject];
//        return;
//
//    }
//    if(self.down.count > 0)
//    {
//        self.flipOnUndo = YES;
//        [self.up addObject:[self.down lastObject]];
//        [self.down removeLastObject];
//    }
//}


- (void)moveDownToUp
{
    for(int i = 0; i < self.down.count; i++)
    {
        [self.up addObject:[self.down lastObject]];
        [self.down removeLastObject];
    }
}



// Should flip the card if necessary
- (Card *)removeTopCard
{
    return nil;
}

- (void)addCardToTop:(Card *)card
{

}

// Common routine that handles all of the moving of cards stack to stack

- (void)moveOrUndoMove:(Stack *)to
             withCount:(int)count
              undoMove:(BOOL)undoMove
                fliped:(BOOL)flipped
{
    if(undoMove && flipped)
    {
        [to moveOneCardUpToDown]; // Note that this is the to stack not the from stack
    }
    if(self.size == 0)
    {
        return;
    }
    for(int i = (int)self.up.count - count; i < self.up.count; i++)
    {
        [to addUp:self.up[i]];
    }
    if(self.up.count - count > self.up.count)
    {
        NSLog(@"Out of range!");
        return;
    }
    if(count > self.up.count)
    {
        NSLog(@"Out of range!");
        return;
    }
    [self.up removeObjectsInRange:NSMakeRange(self.up.count - count, count)];
    if(!undoMove && self.upSize == 0)
    {
        [self moveOneCardDownToUp];
    }

}

- (void)move:(Stack *)to
{
    [self moveOrUndoMove:to withCount:1 undoMove:NO fliped:NO];
    //    [to addUp:[self.up lastObject]];
    //    [self.up removeLastObject];
    //    if(to != self)
    //    {
    //        [self flipTopCard];
    //    }
}

- (void)move:(Stack *)to withCount:(int)count
{
    [self moveOrUndoMove:to withCount:count undoMove:NO fliped:NO];
}

// This method exists to allow transfering any card from the talon pile without
// flipping. Undo doesn't work here, though.

- (void)move:(Stack *)to withCard:(Card *)card
{
    NSUInteger index = [self.up indexOfObjectIdenticalTo:card];

    if(index == NSNotFound)
    {
        NSLog(@"Could not find card in stack from %s", __PRETTY_FUNCTION__);
    }
    [to addUp:card];
    [self.up removeObjectAtIndex:index];
}

- (void)undoMove:(Stack *)to flipped:(BOOL)flipped
{
    [self moveOrUndoMove:to withCount:1 undoMove:YES fliped:flipped];
}

- (void)undoMove:(Stack *)to withCount:(int)count flipped:(BOOL)flipped
{
    [self moveOrUndoMove:to withCount:count undoMove:YES fliped:flipped];
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
    if([string isEqualToString:@""])
    {
        return @"-";
    }
    else
    {
        return string;
    }
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
