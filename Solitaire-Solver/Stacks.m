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
@property (nonatomic, strong) dispatch_queue_t loopQueue;
@property (nonatomic, strong) dispatch_queue_t hashQueue;

@end

@implementation Stacks

#pragma mark - Properties

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

- (Moves *)moveHistory
{
    if(!_moveHistory)
    {
        _moveHistory = [[Moves alloc] init];

    }
    return _moveHistory;
}

- (NSMutableDictionary *)gameStateGraph
{
    if(!_gameStateGraph)
    {
        _gameStateGraph = [[NSMutableDictionary alloc] init];
    }
    return _gameStateGraph;
}


- (int)count
{
    return (int)self.stacks.count;
}

- (dispatch_queue_t)loopQueue
{
    if(!_loopQueue)
    {
        _loopQueue = dispatch_queue_create("com.enlarsen.loopQ", DISPATCH_QUEUE_CONCURRENT);
    }
    return _loopQueue;
}

- (dispatch_queue_t)hashQueue
{
    if(!_hashQueue)
    {
        _hashQueue = dispatch_queue_create("com.elarsen.hashQ", DISPATCH_QUEUE_SERIAL);
    }
    return _hashQueue;
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

- (void)resetStacks
{
    _moveHistory = nil;
    _gameStateGraph = nil;

}

#pragma mark - Allow array subscripting

- (Stack *)objectAtIndexedSubscript:(NSUInteger)index
{
    return self.stacks[index];
}

- (void)setObject:(Stack *)stack atIndexedSubscript:(NSUInteger)index
{
    self.stacks[index] = stack;
}

#pragma mark - Enumerate with blocks

- (void)enumerateFoundationUsingBlock:(void (^)(Stack *stack, int index, BOOL *stop))block
{
    BOOL stop = NO;

    for(int i = FOUNDATION1C; i <= FOUNDATION4H; i++)
    {
        if(self[i].size == 0)
        {
            continue;
        }
        block(self[i], i, &stop);
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
        block(self[i], i, &stop);
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
    BOOL stop = NO;

    for(int i = TABLEAU1; i <= TABLEAU7; i++)
    {
        for(int j = TABLEAU1; j <= TABLEAU7; j++)
        {
            if(i == j)
            {
                continue;
            }
            block(self[i], self[j], i, j, &stop);
            if(stop)
            {
                return;
            }
        }
    }
}

#pragma mark - Find moves

- (Moves *)findFoundationMoves
{
    Moves *moves = [[Moves alloc] init];
    Stacks __weak *weakSelf = self;

    [self enumerateTableausUsingBlock:^(Stack *stack, int index, BOOL *stop)
    {
        if(stack.low.rank - weakSelf[stack.low.foundation].size == 1)
        {
            Move *move = [[Move alloc] init];
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
    dispatch_group_t interTableauGroup = dispatch_group_create();
    dispatch_group_t synchronizationGroup = dispatch_group_create();
    dispatch_queue_t synchronizationQueue =
        dispatch_queue_create("com.enlarse.syncQ", DISPATCH_QUEUE_SERIAL);

    [self enumerateTableausInPairsUsingBlock:^(Stack *stack1, Stack *stack2,
                                               int index1, int index2, BOOL *stop)
    {
        dispatch_group_async(interTableauGroup, self.loopQueue,
       ^{
            for(int i = 0; i < stack1.upSize; i++)
            {
                if(stack2.low.isRed != [stack1 up:i].isRed && stack2.low.rank - [stack1 up:i].rank == 1)

                {
                    dispatch_group_async(synchronizationGroup, synchronizationQueue,
                   ^{
                        Move *move = [[Move alloc] init];
                        [move setMoveFrom:index1 to:index2 withCount:stack1.upSize - i];
                        [moves add:move];
                    });
                }
            }


            // king to empty tableau
            if(stack1.high.rank == KING && stack2.size == 0 && stack1.downSize > 0)
            {
                dispatch_group_async(synchronizationGroup, synchronizationQueue,
               ^{
                   Move *move = [[Move alloc] init];
                   [move setMoveFrom:index1 to:index2 withCount:stack1.upSize];
                   [moves add:move];

               });
            }
       });

    }];

    dispatch_group_wait(interTableauGroup, DISPATCH_TIME_FOREVER);
    dispatch_group_wait(synchronizationGroup, DISPATCH_TIME_FOREVER);

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
            if(cardTo && cardTo && (cardTo.rank - cardFrom.rank == 1) && (cardTo.isRed != cardFrom.isRed))
            {
                Move *move = [[Move alloc] initWithMoveFrom:cardFrom.foundation
                                    to:indexTo withCount:1];
                [moves add:move];
            }
        }];
    }];

    return moves;
}

// Moves from the entire talon stack to the tableaus (no turning cards)

- (Moves *)findTalonMoves
{
    Moves *moves = [[Moves alloc] init];

    for(int i = 0; i < self[STOCK].upSize; i++)
    {

        Card *talon = [self[STOCK] up:i];

        [self enumerateTableausUsingBlock:^(Stack *stack, int index, BOOL *stop)
        {
            if((stack.low.rank - talon.rank == 1 && stack.low.isRed != talon.isRed) ||
               (stack.size == 0 && talon.rank == KING))
            {
                Move *move = [[Move alloc] init];
                [move setMoveFrom:STOCK to:index withCard:talon];
                [moves add:move];
            }
        }];

        if(talon.rank - self[talon.foundation].size == 1)
        {
            Move *move = [[Move alloc] init];
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

#pragma mark - Move handling

- (void)move:(Move *)move
{

//    NSLog(@"\n+++++++++++++++++++++++++\nMove (before): %@\n%@\n",
//          move,
//          [self description]);

// Remember whether we moved a card from the down pile to the up so we can undo properly
    if(self[move.from].upSize - move.count == 0)
    {
        move.flipped = YES;
    }
    else
    {
        move.flipped = NO;
    }
    if(move.card)
    {
        [self.stacks[move.from] move:self.stacks[move.to] withCard:move.card];
    }
    else
    {
        if(move.from == 0)
        {
            NSLog(@"Bad move from talon with no card");
        }
        [self.stacks[move.from] move:self.stacks[move.to] withCount:move.count];
    }
    [self.moveHistory add:move];
//    NSLog(@"\nBoard hash: %@", [self gameBoardHashKey]);
//    NSLog(@"\n\nMove (after): \n%@+++++++++++++++++++++++++\n\n\n", [self description]);
}

- (void)undoMove:(Move *)move
{
//    NSLog(@"\n-------------------------\nUNDO Move (before): %@\n%@\n",
//          move,
//          [self description]);

    [self.stacks[move.to] undoMove:self.stacks[move.from] withCount:move.count flipped:move.flipped];

//    NSLog(@"\nBoard hash: %@", [self gameBoardHashKey]);
//    NSLog(@"\n\nUNDO Move (after): \n%@-------------------------\n\n\n", [self description]);
    [self.moveHistory removeLastObject];
}

- (BOOL)takeNextMoveOrUndo:(Moves *)moves
{
    NSString *boardHash = [self gameBoardHashKey];

//    if((self.gameStateGraph.count % 1000) == 0)
//    {
//        NSLog(@"gameStateGraph # of states: %lu", (unsigned long)self.gameStateGraph.count);
//    }
    GameState *gameState = self.gameStateGraph[boardHash];
    if(!gameState)
    {
        gameState = [[GameState alloc] init];

    }
    // First add all of the possible moves
    // TODO: collapse into one loop with following loop
    for(Move *move in moves)
    {
        NSString *moveHash = [move moveHash];
        if(!gameState.moves[moveHash])
        {
            gameState.moves[moveHash] = @0;
            self.gameStateGraph[boardHash] = gameState;
        }
    }

    for(Move *move in moves)
    {
        NSString *moveHash = [move moveHash];
        if(!gameState.moves[moveHash] || [gameState.moves[moveHash]  isEqual: @0])
        {
            [self move:move];
            NSString *newBoardHash = [self gameBoardHashKey];
            gameState.moves[moveHash] = @1;
            self.gameStateGraph[boardHash] = gameState;
            if(self.gameStateGraph[newBoardHash])
            {
                [self undoMove:move];
                continue;
            }
            else
            {
                return NO;
            }
        }
    }
    // no moves, undo

    Move *undoMove = [self.moveHistory lastObject];
    if(undoMove)
    {
        [self undoMove:undoMove];
    }
    else
    {
        return YES; // No more moves to undo, give up
    }
    return NO;
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
        [stack moveOneCardDownToUp];
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
    // Move to a private property for perf
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"high.value"
                                                 ascending:YES];
    NSRange tableauRange = NSMakeRange(TABLEAU1, numberofTableaus);

    NSArray *sortedArray = [[self.stacks subarrayWithRange:tableauRange] sortedArrayUsingDescriptors:@[sortDescriptor]];

    return sortedArray;
}

// Inefficient hash trades perf for human readability.

- (NSString *)gameBoardHashKey
{
    NSMutableString *gameBoardKey = [[NSMutableString alloc] init];
    NSMutableDictionary *stackHashKeys = [[NSMutableDictionary alloc] init];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t hashGroup = dispatch_group_create();

    [gameBoardKey appendFormat:@"%0.2d%0.2d%0.2d%0.2d", self[FOUNDATION1C].size,
                                            self[FOUNDATION2D].size,
                                            self[FOUNDATION3S].size,
                                            self[FOUNDATION4H].size];

//    NSArray *sortedTableau = [self tableausSortedByHighestCard];


    dispatch_apply(TABLEAU7 - TABLEAU1 + 1, queue, ^(size_t i) {
        NSString *result = [self[i + TABLEAU1] stackAsStringForHash];
        dispatch_group_async(hashGroup, self.hashQueue,
        ^{
            stackHashKeys[[NSNumber numberWithInt:i]] = result;
        });
    });

    dispatch_group_wait(hashGroup, DISPATCH_TIME_FOREVER);
    
    for(int i = TABLEAU1; i <= TABLEAU7; i++)
    {
            [gameBoardKey appendFormat:@"%@|",
                    stackHashKeys[[NSNumber numberWithInt:i - TABLEAU1]]];
    }

    return gameBoardKey;
}

- (void)resetTalon
{
    [self[STOCK] moveDownToUp];
}

- (NSString *)oldDescription
{
    NSMutableString *string = [[NSMutableString alloc] init];
    for(int i = 0; i < numberOfStacks; i++)
    {
        [string appendString:[self descriptionOfStack:i]];
    }
    return string;
}

- (NSString *)descriptionOfStack:(int)stack
{
    NSMutableString *string = [[NSMutableString alloc] init];

    [string appendFormat:@"\n%@\n=================\n%@\n", [Stacks stackNames][stack],
    self.stacks[stack]];
    return string;
}

- (NSString *)description
{
    NSMutableString *string = [[NSMutableString alloc] init];

    for(int i = 0; i < numberOfStacks; i++)
    {
        [string appendFormat:@"%@: ", [Stacks stackNames][i]];
        for(int j = 0; j < [self.stacks[i] upSize]; j++)
        {
            [string appendFormat:@"%@", [[self.stacks[i] up:j] description]];
        }
        if([self.stacks[i] downSize])
        {
            [string appendString:@"|"];
            for(int j = 0; j < [self.stacks[i] downSize]; j++)
            {
                [string appendFormat:@"%@", [[self.stacks[i] down:j] description]];
            }
        }
        [string appendString:@"\n"];
    }

    return string;
}

- (NSString *)debugDescription
{
    return [self description];
}

+ (NSArray *)stackNames
{
    return @[@"Stock (0)", @"Tableau 1", @"Tableau 2", @"Tableau 3", @"Tableau 4",
             @"Tableau 5", @"Tableau 6", @"Tableau 7", 
             @"Foundation 1 (8) (clubs)", @"Foundation 2 (9) (diamonds)",
             @"Foundation 3 (10) (spades)", @"Foundation 4 (11) (hearts)"];
}
@end
