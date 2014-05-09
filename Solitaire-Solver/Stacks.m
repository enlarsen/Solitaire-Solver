//
//  Stacks.m
//  Solitaire-Solver
//
//  Created by Erik Larsen on 5/2/14.
//  Copyright (c) 2014 Erik Larsen. All rights reserved.
//

#import "Stacks.h"
#import "Stack.h"
#import "Move.h"
#import "Moves.h"
#import "Card.h"
#import "Deck.h"
#import "GameState.h"

static const int numberOfStacks = 12;
static const int numberofTableaus = TABLEAU7 - TABLEAU1 + 1;

@interface Stacks()

@property (strong, nonatomic) NSMutableArray *stacks;
@property (nonatomic) int numberOfCards;
@property (nonatomic) int maxFoundationValue;

@end

@implementation Stacks

- (NSMutableArray *)stacks
{
    if(!_stacks)
    {
        _stacks = [NSMutableArray new];
        for(int i = 0; i < numberOfStacks; i++)
        {
            Stack *stack = [[Stack alloc] init];
            [_stacks addObject:stack];
        }
        self.maxFoundationValue = 0;

    }
    return _stacks;
}

- (int)count
{
    return (int)self.stacks.count;
}

- (int)foundationValue
{
    __block int foundationTotal = 0;

    [self enumerateFoundationUsingBlock:^(Stack *stack, int index, BOOL *stop)
     {
         foundationTotal += stack.size;
     }];

    if(self.maxFoundationValue < foundationTotal)
    {
        self.maxFoundationValue = foundationTotal;
    }
    return foundationTotal;
}

- (Stack *)objectAtIndexedSubscript:(NSUInteger)index
{
    return self.stacks[index];
}

- (void)setObject:(Stack *)stack atIndexedSubscript:(NSUInteger)index
{
    self.stacks[index] = stack;
}

- (void)enumerateFoundationUsingBlock:(void (^)(Stack *stack, int index, BOOL *stop))block
{
    BOOL stop = NO;

    for(int i = FOUNDATION1C; i <= FOUNDATION4H; i++)
    {
        block(self.stacks[i], i, &stop);
        if(stop)
        {
            break;
        }
    }
}

- (void)enumerateTableausUsingBlock:(void (^)(Stack *stack, int index, BOOL *stop))block
{
    BOOL stop = NO;

    for(int i = TABLEAU1; i <= TABLEAU7; i++)
    {
        block(self.stacks[i], i, &stop);
        if(stop)
        {
            break;
        }
    }
}

- (void)enumerateTableausInPairsUsingBlock:(void (^)(Stack *stack1, Stack *stack2,
                                                     int index1, int index2, BOOL *stop))block
{
    // Call the block on all pairs of tableaus. This means that the
    // block doesn't have to test A ? B and B ? A (where ? is some
    // comparison) because the comparison will be used with A and B and
    // then later with B and A.
    BOOL *stop;

    for(int i = TABLEAU1; i <= TABLEAU7; i++)
    {
        for(int j = TABLEAU1; j <= TABLEAU7; j++)
        {
            if(i == j)
            {
                continue;
            }
            block(self.stacks[i], self.stacks[j], i, j, stop);
        }
    }
}


- (Moves *)findFoundationMoves
{
    Moves *moves = [[Moves alloc] init];
    Move *move = [[Move alloc] init];

    [self enumerateTableausUsingBlock:^(Stack *stack, int index, BOOL *stop)
    {
        if(stack.low.rank - self[stack.low.foundation].size == 1)
        {
            [move setMoveFrom:index
                 to:stack.low.foundation
                withCount:1];
            [moves add:move];
        }
    }];

    return moves;
}

- (Moves *)findInterTableauMoves
{
    Moves *moves = [[Moves alloc] init];
    [self enumerateTableausInPairsUsingBlock:^(Stack *stack1, Stack *stack2,
                                               int index1, int index2, BOOL *stop)
    {
        Move *move = [[Move alloc] init];

        for(int i = 0; i < stack1.upSize; i++)
        {
            if(stack2.low.rank - [stack1 up:i].rank == 1 && stack2.low.isRed != [stack1 up:i].isRed)
            {
                [move setMoveFrom:index1 to:index2 withCount:stack1.upSize - i];
                [moves add:move];
            }
        }

        // king to empty tableau
        if(stack1.high.rank == KING && stack2.size == 0 && stack1.downSize > 0)
        {
            [move setMoveFrom:index1 to:index2 withCount:stack1.upSize];
            [moves add:move];
        }
    }];

    return moves;
}

- (Moves *)findFoundationToTableauMoves
{
    Moves *moves = [[Moves alloc] init];

    [self enumerateFoundationUsingBlock:^(Stack *stackFrom, int indexFrom, BOOL *stopFrom)
    {
        Card *cardFrom = [stackFrom low];

        [self enumerateTableausUsingBlock:^(Stack *stackTo, int indexTo, BOOL *stopTo)
        {
            Card *cardTo = [stackTo low];
            if(cardFrom.rank - cardTo.rank == 1 && cardFrom.isRed != cardTo.isRed)
            {
                Move *move = [[Move alloc] initWithMoveFrom:cardFrom.foundation
                                    to:indexTo withCount:1];
                [moves add:move];
                *stopTo = YES; // break out, no need to continue
            }
        }];
    }];

    return moves;
}

// Moves from the talon stack to the tableaus

- (Moves *)findTalonMoves
{
    Moves *moves = [[Moves alloc] init];
    Move *move = [[Move alloc] init];

    for(int i = 0; i < self[STOCK].upSize; i++)
    {

        Card *talon = [self[STOCK] up:i];

        [self enumerateTableausUsingBlock:^(Stack *stack, int index, BOOL *stop)
        {
            if((stack.low.rank - talon.rank == 1 && stack.low.isRed != talon.isRed) ||
               (stack.size == 0 && talon.rank == KING))
            {
                [move setMoveFrom:STOCK to:index withCard:talon];
                [moves add:move];
            }
        }];

        if(talon.rank - self[talon.foundation].size == 1)
        {
            [move setMoveFrom:STOCK to:talon.foundation withCard:talon];
            [moves add:move];
        }
    }

    return moves;


}


- (Moves *)findAvailableMoves
{
    Moves *moves = [[Moves alloc] init];

    Moves *foundationMoves = [self findFoundationMoves];
    [moves addMoves:foundationMoves];
//    NSLog(@"foundation moves: %@", foundationMoves);

    Moves *interTableauMoves = [self findInterTableauMoves];
    [moves addMoves:interTableauMoves];
//    NSLog(@"inter tableau moves: %@", interTableauMoves);

//    Moves *foundationToTableauMoves = [self findFoundationToTableauMoves];
//    [moves addMoves:foundationToTableauMoves];
//    NSLog(@"foundation to tableau moves: %@", foundationToTableauMoves);

    Moves *talonMoves = [self findTalonMoves];
    [moves addMoves:talonMoves];
//    NSLog(@"talon moves: %@", talonMoves);

    return moves;
}

- (BOOL)isGameWon
{
    return [self foundationValue] == self.numberOfCards;
}

- (void)move:(Move *)move
{
//    NSLog(@"\n++++++++++++ Move++++++++++++\n\tBefore:\nFrom: %@\nTo:%@",
//          [self descriptionOfStack:move.from],
//          [self descriptionOfStack:move.to]);

    if(move.card)
    {
        [self.stacks[move.from] move:self.stacks[move.to] withCard:move.card];
    }
    else
    {
        [self.stacks[move.from] move:self.stacks[move.to] withCount:move.count];
    }
//    NSLog(@"Board hash: %@", [self gameBoardHashKey]);
//    NSLog(@"\n\tAfter:\nFrom: %@\nTo:%@", [self descriptionOfStack:move.from],
//          [self descriptionOfStack:move.to]);
}

- (void)undoMove:(Move *)move
{
    [self.stacks[move.from] undoMove:self.stacks[move.to] withCount:move.count];
}

- (void)dealCards:(Deck *)deck
{
    self.numberOfCards = deck.count;

    for(int i = 0; i < numberOfStacks; i++)
    {
        [self.stacks[i] reset];
    }

    [self enumerateTableausUsingBlock:^(Stack *stack, int index, BOOL *stop)
    {
        for(int i = 0; i < index; i++)
        {
            [stack addDown:[deck deal]];
        }
        [stack flip];
    }];

    Card *card;

    // Deal the rest of the cards to the stock stack
    while((card = [deck deal]) != nil)
    {
        [self.stacks[STOCK] addUp:card];
    }
}

- (NSArray *)tableausSortedByHighestCard
{
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"high.value"
                                                 ascending:YES];
    NSRange tableauRange = NSMakeRange(TABLEAU1, numberofTableaus);

    NSArray *sortedArray = [[self.stacks subarrayWithRange:tableauRange] sortedArrayUsingDescriptors:@[sortDescriptor]];

    return sortedArray;
}

- (NSString *)gameBoardHashKey
{
    NSMutableString *gameBoardKey = [[NSMutableString alloc] init];

    [gameBoardKey appendFormat:@"%0.2d%0.2d%0.2d%0.2d", self[FOUNDATION1C].size,
                                            self[FOUNDATION2D].size,
                                            self[FOUNDATION3S].size,
                                            self[FOUNDATION4H].size];

    NSArray *sortedTableau = [self tableausSortedByHighestCard];
    for(Stack *stack in sortedTableau)
    {
        [gameBoardKey appendFormat:@"%@|", [stack stackAsStringForHash]];
    }

    return [gameBoardKey copy];
}

- (void)resetTalon
{
    [self[STOCK] moveDownToUp];
}

- (NSString *)description
{
    NSMutableString *string = [[NSMutableString alloc] init];
    for(int i = 0; i < numberOfStacks; i++)
    {
        [string appendString:[self descriptionOfStack:i]];
    }
    return [string copy];
}

- (NSString *)descriptionOfStack:(int)stack
{
    NSMutableString *string = [[NSMutableString alloc] init];

    [string appendFormat:@"\n%@\n=================\n%@\n", [Stacks stackNames][stack],
    self.stacks[stack]];
    return [string copy];
}

- (NSString *)debugDescription
{
    return [self description];
}

+ (NSArray *)stackNames
{
    return @[@"Stock", @"Tableau 1", @"Tableau 2", @"Tableau 3", @"Tableau 4",
             @"Tableau 5", @"Tableau 6", @"Tableau 7", 
             @"Foundation 1 (clubs)", @"Foundation 2 (diamonds)",
             @"Foundation 3 (spades)", @"Foundation 4 (hearts)"];
}
@end
