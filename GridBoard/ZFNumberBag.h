//
//  ZFNumberBag.h
//  GridBoard
//
//  Created by Zachary Fleischman on 6/8/13.
//  Copyright (c) 2013 Zachary Fleischman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZFNumberBag : NSNumber

//Direct access to model
@property (strong, nonatomic) NSMutableArray *bag;
@property NSUInteger pointer;
@property id value;

/*Class initializers
 */
+ (NSNumber *)numberWithBool:(BOOL)value;
+ (NSNumber *)numberWithChar:(char)value;
+ (NSNumber *)numberWithDouble:(double)value;
+ (NSNumber *)numberWithFloat:(float)value;
+ (NSNumber *)numberWithInt:(int)value;
+ (NSNumber *)numberWithInteger:(NSInteger)value;
+ (NSNumber *)numberWithLong:(long)value;
+ (NSNumber *)numberWithLongLong:(long long)value;
+ (NSNumber *)numberWithShort:(short)value;
+ (NSNumber *)numberWithUnsignedChar:(unsigned char)value;
+ (NSNumber *)numberWithUnsignedInt:(unsigned int)value;
+ (NSNumber *)numberWithUnsignedInteger:(NSUInteger)value;
+ (NSNumber *)numberWithUnsignedLong:(unsigned long)value;
+ (NSNumber *)numberWithUnsignedLongLong:(unsigned long long)value;
+ (NSNumber *)numberWithUnsignedShort:(unsigned short)value;

/*Initialize with value
 */
- (id)initWithNumber:(NSNumber *)aNumber;
- (id)initWithObject:(id)anObject;

- (id)initWithBool:(BOOL)value;
- (id)initWithChar:(char)value;
- (id)initWithDouble:(double)value;
- (id)initWithFloat:(float)value;
- (id)initWithInt:(int)value;
- (id)initWithInteger:(NSInteger)value;
- (id)initWithLong:(long)value;
- (id)initWithLongLong:(long long)value;
- (id)initWithShort:(short)value;
- (id)initWithUnsignedChar:(unsigned char)value;
- (id)initWithUnsignedInt:(unsigned int)value;
- (id)initWithUnsignedInteger:(NSUInteger)value;
- (id)initWithUnsignedLong:(unsigned long)value;
- (id)initWithUnsignedLongLong:(unsigned long long)value;
- (id)initWithUnsignedShort:(unsigned short)value;


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
- (id)objectValue;

- (BOOL)boolValue;
- (char)charValue;
- (NSDecimal)decimalValue;
- (double)doubleValue;
- (float)floatValue;
- (int)intValue;
- (NSInteger)integerValue;
- (long long)longLongValue;
- (long)longValue;
- (short)shortValue;
- (unsigned char)unsignedCharValue;
- (NSUInteger)unsignedIntegerValue;
- (unsigned int)unsignedIntValue;
- (unsigned long long)unsignedLongLongValue;
- (unsigned long)unsignedLongValue;
- (unsigned short)unsignedShortValue;

- (NSString *)descriptionWithLocale:(id)locale;
- (NSString *)stringValue;


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

/*NSNUmber/NSValue Stuff
 */
- (NSComparisonResult)compare:(NSNumber *)otherNumber;
- (BOOL)isEqualToNumber:(NSNumber *)number;
- (const char *)objCType;
- (void)getValue:(void *)value;


@end
