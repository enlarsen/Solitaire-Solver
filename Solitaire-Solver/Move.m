//
//  Move.m
//  Solitaire-Solver
//
//  Created by Erik Larsen on 4/30/14.
//  Copyright (c) 2014 Erik Larsen. All rights reserved.
//

#import "Move.h"
#import "Card.h"

@implementation Move

- (instancetype)initWithMoveFrom:(unsigned char)from to:(unsigned char)to
                       withCount:(unsigned char)count
{
    self = [super init];
    if(self)
    {
        self.from = from;
        self.to = to;
        self.count = count;
        self.card = nil;
        self.flipped = NO;
    }
    return self;
}

- (instancetype)initWithMoveFrom:(unsigned char)from to:(unsigned char)to withCard:(Card *)card
{
    self = [self initWithMoveFrom:from to:to withCount:1];
    self.card = card;
    return self;
}

- (void)setMoveFrom:(unsigned char)from to:(unsigned char)to
          withCount:(unsigned char)count
{
    self.from = from;
    self.to = to;
    self.count = count;
    self.flipped = NO;
    self.card = nil;
}

- (void)setMoveFrom:(unsigned char)from to:(unsigned char)to withCard:(Card *)card
{
    [self setMoveFrom:from to:to withCount:1];
    self.card = card;
}

- (NSString *)moveHash
{
    return [[NSString stringWithFormat:@"%0.2d%0.2d%0.2d%0.2d",
            self.from, self.to, self.count, self.card.value] copy];
}

//- (id)copyWithZone:(NSZone *)zone
//{
//    Move *copy = [[[self class] allocWithZone:zone] init];
//
//    if(copy)
//    {
//        ((Move *)copy).card = self.card;
//        ((Move *)copy).from = self.from;
//        ((Move *)copy).to = self.to;
//        ((Move *)copy).count = self.count;
//    }
//    return copy;
//}

- (NSString *)description
{

    if(self.card)
    {
        return [NSString stringWithFormat:@"from: %d to: %d card: %@",
                self.from, self.to, self.card];

    }
    else
    {
        return [NSString stringWithFormat:@"from: %d to: %d count: %d",
            self.from, self.to, self.count];
    }
}

@end
