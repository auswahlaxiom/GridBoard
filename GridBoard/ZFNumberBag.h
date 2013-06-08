//
//  ZFNumberBag.h
//  GridBoard
//
//  Created by Zachary Fleischman on 6/8/13.
//  Copyright (c) 2013 Zachary Fleischman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZFNumberBag : NSObject

//Direct access to model
@property (strong, nonatomic) NSMutableArray *bag;
@property id value;

/*Initialize with value
 */
- (id)initWithNumber:(NSNumber *)aNumber;
- (id)initWithInt:(int)anInt;
- (id)initWithFloat:(float)aFloat;
- (id)initWithBool:(BOOL)aBOOL;
- (id)initWithObject:(id)anObject;

/*Add a value to the numberbag
 */
- (void)addNumber:(NSNumber *)aNumber;
- (void)addInt:(int)anInt;
- (void)addFloat:(float)aFloat;
- (void)addBool:(BOOL)aBOOL;
- (void)addObject:(id)anObject;

/*Remove all objects and add a value
 */
- (void)resetWithNumber:(NSNumber *)aNumber;
- (void)resetWithInt:(int)anInt;
- (void)resetWithFloat:(float)aFloat;
- (void)resetWithBool:(BOOL)aBOOL;
- (void)resetWithObject:(id)anObject;

/*Returns value at current pointer
 */
- (NSNumber *)numberValue;
- (int)intValue;
- (float)floatValue;
- (BOOL)boolValue;
- (id)objectValue;

/*Return and remove last value. Moves pointer to new end.
 */
- (NSNumber *)popNumber;
- (int)popInt;
- (float)popFloat;
- (BOOL)popBOOL;
- (id)popObject;

/*Advance pointer to end and return value
 */
- (NSNumber *)lastNumber;
- (int)lastInt;
- (float)lastFloat;
- (BOOL)lastBOOL;
- (id)lastObject;

/*Move pointer to beginning and return value
 */
- (NSNumber *)firstNumber;
- (int)firstInt;
- (float)firstFloat;
- (BOOL)firstBOOL;
- (id)firstObject;

/*Advances pointer and returns value
 */
- (NSNumber *)nextNumber;
- (int)nextInt;
- (float)nextFloat;
- (BOOL)nextBOOL;
- (id)nextObject;

/*Steps back pointer and returns value
 */
- (NSNumber *)previousNumber;
- (int)previousInt;
- (float)previousFloat;
- (BOOL)previousBOOL;
- (id)previousObject;

/*Sets pointer to random location and returns value
 */
- (NSNumber *)randomNumber;
- (int)randomInt;
- (float)randomFloat;
- (BOOL)randomBOOL;
- (id)randomObject;

/*Pointer manipulation
 */
- (NSUInteger)decrementPointer;
- (NSUInteger)incrementPointer;
- (NSUInteger)randomizePointer;
- (NSUInteger)beginPointer;
- (NSUInteger)endPointer;

/*NSArray Stuff
 */
- (NSUInteger)count;

@end
