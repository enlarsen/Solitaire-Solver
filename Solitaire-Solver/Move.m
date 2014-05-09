//
//  Move.m
//  Solitaire-Solver
//
//  Created by Erik Larsen on 4/30/14.
//  Copyright (c) 2014 Erik Larsen. All rights reserved.
//

#import "Move.h"

@implementation Move

- (instancetype)initWithMoveFrom:(unsigned char)from to:(unsigned char)to
                       withCount:(unsigned char)count
{
    self = [self init];
    self.from = from;
    self.to = to;
    self.count = count;
    self.card = nil;

    return self;
}

- (instancetype)initWithMoveFrom:(unsigned char)from to:(unsigned char)to withChard:(Card *)card
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
    self.card = nil;
}

- (void)setMoveFrom:(unsigned char)from to:(unsigned char)to withCard:(Card *)card
{
    [self setMoveFrom:from to:to withCount:1];
    self.card = card;
}

- (id)copyWithZone:(NSZone *)zone
{
    id copy = [[[self class] alloc] init];

    if(copy)
    {
        ((Move *)copy).card = self.card;
        ((Move *)copy).from = self.from;
        ((Move *)copy).to = self.to;
        ((Move *)copy).count = self.count;
    }
    return copy;
}

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
