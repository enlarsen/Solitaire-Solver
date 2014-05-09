//
//  main.m
//  Solitaire-Solver
//
//  Created by Erik Larsen on 5/4/14.
//  Copyright (c) 2014 Erik Larsen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Klondike.h"
#import <sys/time.h>

long long gamesPlayed = 0;
double conversion_factor;

void gameRunner(void);
void queueGames(dispatch_group_t gameGroup);

int main(int argc, const char * argv[])
{
    /*
    Klondike *klondike = [[Klondike alloc] init];
    int wins = 0;
    int count = 0;
    int gamesToPlayPerCall = 100000;

//    [klondike play];
    while(YES)
    {
        wins = [klondike playNGames:gamesToPlayPerCall];
        count++;
//        if(count % 100 == 0)
//        {
            NSLog(@"Played %d games", count * gamesToPlayPerCall);
//        }
    }

    exit(0);

*/

    /*

    NSRunLoop *runloop = [NSRunLoop currentRunLoop];


    NSUInteger cpus = [[NSProcessInfo processInfo] activeProcessorCount];
    @autoreleasepool
    {
        for(int i = 0; i < cpus; i++)
        {
            NSLog(@"Starting on cpu %d", i);
            gameRunner();
        }
        while(YES)
        {
            [runloop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
        }
    } */

    NSRunLoop *runloop = [NSRunLoop currentRunLoop];

    dispatch_group_t gameGroup = dispatch_group_create();

    queueGames(gameGroup);

    while(YES)
    {
        [runloop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
    }

    return 0;
}

void queueGames(dispatch_group_t gameGroup)
{
    for(int i = 0; i < 50; i++)
    {
        dispatch_group_async(gameGroup,
                             dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
        ^{
            gameRunner();
        });
    }
    dispatch_group_notify(gameGroup,
                          dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                          ^{
                              queueGames(gameGroup);

                          });

}

void gameRunner()
{
    Klondike *klondike = [[Klondike alloc] init];
    int gamesToPlay = 10;

    struct timeval start, end;
    gettimeofday(&start, NULL);
    int wins = [klondike playNGames:gamesToPlay];
    gettimeofday(&end, NULL);
    double duration = (end.tv_sec + end.tv_usec / 100000.0) -
        (start.tv_sec + start.tv_usec / 100000.0);

    dispatch_async(dispatch_get_main_queue(), ^
    {
        if(wins)
        {
            NSLog(@"Won %d games!", wins);
        }
        gamesPlayed++;
        NSLog(@"Played %lld games.", gamesPlayed * gamesToPlay);
        NSLog(@"Games per second: %f", (double)gamesToPlay/duration);

    });
}


/*
 
 dispatchasync
 {
    klondike
    dispatch async
    {
        klondike
    }
 
 }
 
 
 */
