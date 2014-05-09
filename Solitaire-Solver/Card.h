//
//  Card.h
//  Solitaire-Solver
//
//  Created by Erik Larsen on 4/30/14.
//  Copyright (c) 2014 Erik Larsen. All rights reserved.
//

#import <Foundation/Foundation.h>

enum Cards {
	EMPTY = 0,
	ACE,
	TWO,
	THREE,
	FOUR,
	FIVE,
	SIX,
	SEVEN,
	EIGHT,
	NINE,
	TEN,
	JACK,
	QUEEN,
	KING
};

enum Suits {
	CLUBS = 0,
	DIAMONDS,
	SPADES,
	HEARTS,
	NONE = 255
};

@interface Card : NSObject

@property (nonatomic) unsigned char suit;
@property (nonatomic) unsigned char rank;
@property (nonatomic) unsigned char isOdd;
@property (nonatomic) unsigned char isRed;
@property (nonatomic) unsigned char foundation;
@property (nonatomic) unsigned char value;


- (void)clear;
- (void)set:(unsigned char)value;

@end
