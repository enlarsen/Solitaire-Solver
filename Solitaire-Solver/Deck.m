//
//  Deck.m
//  Solitaire-Solver
//
//  Created by Erik Larsen on 5/2/14.
//  Copyright (c) 2014 Erik Larsen. All rights reserved.
//

#import "Deck.h"
#import "Card.h"

static const int cardsInDeck = 52;

@interface Deck()

@property (strong, nonatomic) NSMutableArray *deck; // of Card
@property (nonatomic) int currentCard;

@end

@implementation Deck

- (int)count
{
    return (int)self.deck.count;
}

- (NSMutableArray *)deck
{
    if(!_deck)
    {
        _deck = [NSMutableArray new];
        for(int i = 0; i < cardsInDeck; i++)
        {
            Card *card = [[Card alloc] init];
            [card set:i];
            [self.deck addObject:card];
        }
        self.currentCard = 0;
        [self checkDeck];
    }
    return _deck;
}

- (instancetype)initAndShuffle
{
    self = [self init];
    if(self)
    {
        [self shuffle];
    }
    return self;
}

- (void)shuffle
{
    // Swap cards 269 times
    for(int x = 0; x < 269; x++)
    {
        int k = arc4random_uniform(cardsInDeck);
        int j = arc4random_uniform(cardsInDeck);

        Card *temp = self.deck[k];
        self.deck[k] = self.deck[j];
        self.deck[j] = temp;
    }
}

// Another shuffling algorithm

- (void)shuffle2
{
    Deck *temp = [[Deck alloc] init];

    [self.deck removeAllObjects];

    while(temp.count)
    {
        int index = arc4random_uniform((int)temp.count);
        [self.deck addObject:temp[index]];
        [temp.deck removeObjectAtIndex:index];
    }
}

- (void)shuffle3
{
    // Don't shuffle the deck. Used for profiling.
}

- (Card *)deal
{
    if(self.currentCard >= cardsInDeck)
    {
        return nil;
    }
    else
    {
        return self.deck[self.currentCard++];
    }
}

- (void)checkDeck
{
    for(int i = 0; i < cardsInDeck; i++)
    {
        for(int j = 0; j < cardsInDeck; j++)
        {

            if(i == j)
            {
                continue;
            }
            
            Card *card1 = self.deck[i];
            Card *card2 = self.deck[j];
            if(card1.value < 0 || card1.value >= cardsInDeck)
            {
                NSLog(@"Card %@ out of range", card1);
            }
            if(card2.value < 0 || card1.value >= cardsInDeck)
            {
                NSLog(@"Card %@ out of range", card2);
            }
            if(card1.value == card2.value)
            {
                NSLog(@"Two cards with the same value, card1=%@, card2=%@", card1, card2);
            }
        }
    }
}

- (Card *)objectAtIndexedSubscript:(NSUInteger)index
{
    return self.deck[index];
}

- (void)setObject:(Card *)move atIndexedSubscript:(NSUInteger)index
{
    self.deck[index] = move;
}

- (NSString *)description
{
    NSMutableString *string = [[NSMutableString alloc] init];

    for(Card *card in self.deck)
    {
        [string appendFormat:@"%@ ",[card description]];
    }

    return [string copy];
}

@end
