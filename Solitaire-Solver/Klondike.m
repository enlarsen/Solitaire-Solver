//
//  Klondike.m
//  Solitaire-Solver
//
//  Created by Erik Larsen on 5/2/14.
//  Copyright (c) 2014 Erik Larsen. All rights reserved.
//

#import "Klondike.h"
#import "Deck.h"
#import "Stacks.h"
#import "Stack.h"
#import "Moves.h"
#import "Move.h"
#import "MovesAvailable.h"
#import "GameState.h"

@interface Klondike()

@property (nonatomic, strong) Deck *deck;
@property (nonatomic, strong) Stacks *stacks;
@property (nonatomic) long long gamesPlayed;
@property (nonatomic) int gamesWon;
@property (nonatomic) int drawCount;

@end

@implementation Klondike

#pragma mark - Properties

- (Deck *)deck
{
    if(!_deck)
    {
        _deck = [[Deck alloc] initAndShuffle];
    }
    return _deck;
}

- (Stacks *)stacks
{
    if(!_stacks)
    {
        _stacks = [[Stacks alloc] init];
    }
    return _stacks;
}




- (void)resetGame
{
    self.drawCount = 1;
    _stacks = nil;
    _deck = nil;

    [self.stacks resetStacks];
    [self.stacks dealCards:self.deck];

}

- (void)play
{
    Moves *moves;
    //    for(int i = 0; i < 100; i++)
    //    {
    [self resetGame];

    int passes = 0;

    while(YES)
    {
        while(![self.stacks isGameWon])
        {

            while(YES)
            {
                moves = [self.stacks findFoundationMoves];
                if(moves.count == 0)
                {
                    break;
                }
                for(Move *move in moves)
                {
                    [self.stacks move:move];
                }
            }

            moves = [self.stacks findInterTableauMoves];
            if(moves.count)
            {
                int moveIndex = arc4random_uniform(moves.count);
                [self.stacks move:moves[moveIndex]];
            }

            //            moves = [self.stacks findFoundationToTableauMoves];
            //            if(moves.count)
            //            {
            //                int moveIndex = arc4random_uniform(moves.count);
            //                [self.stacks move:moves[moveIndex]];
            //                [self.moveHistory add:moves[moveIndex]];
            //            }

            moves = [self.stacks findTalonMoves];
            if(moves.count)
            {
                int moveIndex = arc4random_uniform(moves.count);
                [self.stacks move:moves[moveIndex]];
            }
            else
            {
//                [self.stacks[STOCK] flipTopCard];
            }
            if(self.stacks[STOCK].upSize == 0)
            {
                [self.stacks resetTalon];
            }
            passes++;
            //        NSLog(@"Total moves: %d", self.moveHistory.count);
            //        NSLog(@"Talon up size: %d", self.stacks[STOCK].upSize);
 //           if(self.moveHistory.count > 300)
            {
                //                NSLog(@"Tried 1000 moves, unwinnable. Foundation value: %d",
                //                      [self.stacks foundationValue]);
                [self resetGame];
            }
 //           else
            {
                if(passes > 300)
                {
                    //                    NSLog(@"Made 1000 passes through move detection. Foundation value %d",
                    //                          [self.stacks foundationValue]);
                    [self resetGame];
                    passes = 0;
                }
            }
            self.gamesPlayed++;
            if(self.gamesPlayed % 100000 == 0)
            {
                NSLog(@"Played %lld", self.gamesPlayed);
            }
        }
        NSLog(@"Yay! Won a game. Played: %lld Won: %d", self.gamesPlayed, self.gamesWon);
    }
    //        if(moves.count)
    //        {
    //            NSLog(@"Before: %@", self.stacks);
    //            [self.stacks move:moves[0]];
    //            NSLog(@"Move: %@", moves[0]);
    //            NSLog(@"After: %@", self.stacks);
    //            [self.stacks undoMove:moves[0]];
    //            NSLog(@"After undo:%@", self.stacks);
    //        }
    
    //    }
    

}
/*
- (int)playNGames:(int)numberOfGames
{
    int wins = 0;
    Moves *moves;
    int maxFoundation = 0;


    for(int i = 0; i < numberOfGames; i++)
    {
        [self resetGame];
        int passes = 0;

        while(![self.stacks isGameWon])
        {

            while(YES)
            {
                moves = [self.stacks findFoundationMoves];
                if(moves.count == 0)
                {
                    break;
                }
                for(Move *move in moves)
                {
//                    NSLog(@"Foundation move: %@", move);
                    [self.stacks move:move];
                    [self.moveHistory add:move];
                }
            }

            moves = [self.stacks findInterTableauMoves];
            if(moves.count)
            {
                int moveIndex = arc4random_uniform(moves.count);
//                NSLog(@"Intertableau move: %@", moves[moveIndex]);

                [self.stacks move:moves[moveIndex]];
                [self.moveHistory add:moves[moveIndex]];
            }

            moves = [self.stacks findTalonMoves];
            if(moves.count)
            {
                int moveIndex = arc4random_uniform(moves.count);
//                NSLog(@"Talon move: %@", moves[moveIndex]);

                [self.stacks move:moves[moveIndex]];
                [self.moveHistory add:moves[moveIndex]];
            }
//            else
//            {
//                [self.stacks[STOCK] flip];
//            }
//            if(self.stacks[STOCK].upSize == 0)
//            {
//                [self.stacks resetTalon];
//            }
            passes++;
            if(self.moveHistory.count > 125)
            {
                break;
            }
            if(passes > 125)
            {
                break;
            }
        }
        if([self.stacks isGameWon])
        {
            wins++;
        }

        //        NSLog(@"%@", [self.stacks description]);
        if(maxFoundation < [self.stacks maxFoundationValue])
        {
            maxFoundation = [self.stacks maxFoundationValue];
        }

    }
    NSLog(@"Maximum foundation value: %d", maxFoundation);
    return wins;
} */

/*
- (int)playNGames:(int)numberOfGames
{
    int wins = 0;
    Moves *moves;
    int maxFoundation = 0;


    for(int i = 0; i < numberOfGames; i++)
    {
        [self resetGame];
        int passes = 0;

        while(![self.stacks isGameWon])
        {

            moves = [self.stacks findFoundationMoves];
            [moves addMoves:[self.stacks findInterTableauMoves]];
            [moves addMoves:[self.stacks findFoundationToTableauMoves]];
            [moves addMoves:[self.stacks findTalonMoves]];

            if(moves.count)
            {
                int moveIndex = arc4random_uniform(moves.count);

                [self addGameState:moves[moveIndex]];

                [self.stacks move:moves[moveIndex]];
                [self.moveHistory add:moves[moveIndex]];
            }
            else
            {
                // No moves, give up
                break;
            }

           passes++;
            if(self.moveHistory.count > 1000)
            {
                break;
            }
            if(passes > 1000)
            {
                break;
            }
        }
        if([self.stacks isGameWon])
        {
            wins++;
        }

        //        NSLog(@"%@", [self.stacks description]);
        if(maxFoundation < [self.stacks maxFoundationValue])
        {
            maxFoundation = [self.stacks maxFoundationValue];
        }
        // passes, maxFoundation, #gamestates, maxgamestatesvisitcount, #moves
        int maxGameStateVisitCount = 0;
        for(NSNumber *number in [self.gameStateGraph allValues])
        {
            if(maxGameStateVisitCount < [number intValue])
            {
                maxGameStateVisitCount = [number intValue];
            }
        }
//        printf("%d,%d,%lu,%d,%d\n", passes, [self.stacks maxFoundationValue],
//              (unsigned long)self.gameStateGraph.count, maxGameStateVisitCount, self.moveHistory.count);

    }
 //   NSLog(@"Maximum foundation value: %d", maxFoundation);
    return wins;
} */

- (int)playNGamesCompletely:(int)numberOfGames
{
    int wins = 0;
    Moves *moves;
    int maxFoundation = 0;
    self.states = 0;


    for(int i = 0; i < numberOfGames; i++)
    {
        [self resetGame];

        BOOL done = NO;

        while(![self.stacks isGameWon] && !done)
        {

            @autoreleasepool
            {

                moves = [self.stacks findFoundationMoves];
                [moves addMoves:[self.stacks findInterTableauMoves]];
                [moves addMoves:[self.stacks findFoundationToTableauMoves]];
                [moves addMoves:[self.stacks findTalonMoves]];

                if(moves.count)
                {
                    done = [self.stacks takeNextMoveOrUndo:moves];
                    self.states++;
                }
                else
                {
                    // No moves, give up
                    break;
                }
                if(self.stacks.gameStateGraph.count > 2500)
                {
                    break;
                }
            }

        }
        if([self.stacks isGameWon])
        {
            wins++;
        }

        //        NSLog(@"%@", [self.stacks description]);
        if(maxFoundation < [self.stacks maxFoundationValue])
        {
            maxFoundation = [self.stacks maxFoundationValue];
        }
        // passes, maxFoundation, #gamestates, maxgamestatesvisitcount, #moves
        //        printf("%d,%d,%lu,%d,%d\n", passes, [self.stacks maxFoundationValue],
        //              (unsigned long)self.gameStateGraph.count, maxGameStateVisitCount, self.moveHistory.count);
        
    }
    //   NSLog(@"Maximum foundation value: %d", maxFoundation);
    return wins;
}




@end
