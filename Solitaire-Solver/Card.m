//
//  Card.m
//  Solitaire-Solver
//
//  Created by Erik Larsen on 4/30/14.
//  Copyright (c) 2014 Erik Larsen. All rights reserved.
//

#import "Card.h"

@interface Card()


@end

@implementation Card


- (void)clear
{
    self.rank = EMPTY;
    self.suit = NONE;
}

- (void)set:(unsigned char)value
{
    self.value = value;
    self.rank = (value % 13) + 1;
    self.suit = value / 13;
    self.isRed = self.suit & 1;
    self.isOdd = self.rank & 1;
    self.foundation = self.suit + 8; // aka: + FOUNDATION1C
}

- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"<%@:%p%@>",
            [self class],
            self,
            @{@"value":@(_value),
              @"rank":@(_rank),
              @"suit":@(_suit),
              @"isRed":@(_isRed),
              @"isOdd":@(_isOdd),
              @"foundation":@(_foundation)}];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@%@",
            [Card rankStrings][self.rank],
            [Card validSuits][self.suit]];
}

+ (NSArray *)validSuits
{
    return @[@"♣", @"♦", @"♠", @"♥"];
}


+ (NSArray *)rankStrings
{
    return @[@"?", @"A", @"2", @"3", @"4", @"5", @"6",@"7",
             @"8", @"9", @"10", @"J", @"Q", @"K"];
}

@end
