//
//  ZFNumberBag.m
//  GridBoard
//
//  Created by Zachary Fleischman on 6/8/13.
//  Copyright (c) 2013 Zachary Fleischman. All rights reserved.
//

#import "ZFNumberBag.h"


@implementation ZFNumberBag

#pragma mark Class initializers
+ (NSNumber *)numberWithBool:(BOOL)value
{
    return [[ZFNumberBag alloc] initWithBool:value];
}
+ (NSNumber *)numberWithChar:(char)value
{
    return [[ZFNumberBag alloc] initWithChar:value];
}
+ (NSNumber *)numberWithDouble:(double)value
{
    return [[ZFNumberBag alloc] initWithDouble:value];
}
+ (NSNumber *)numberWithFloat:(float)value
{
    return [[ZFNumberBag alloc] initWithFloat:value];
}
+ (NSNumber *)numberWithInt:(int)value
{
    return [[ZFNumberBag alloc] initWithInt:value];
}
+ (NSNumber *)numberWithInteger:(NSInteger)value
{
    return [[ZFNumberBag alloc] initWithInteger:value];
}
+ (NSNumber *)numberWithLong:(long)value
{
    return [[ZFNumberBag alloc] initWithLong:value];
}
+ (NSNumber *)numberWithLongLong:(long long)value
{
    return [[ZFNumberBag alloc] initWithLongLong:value];
}
+ (NSNumber *)numberWithShort:(short)value
{
    return [[ZFNumberBag alloc] initWithShort:value];
}
+ (NSNumber *)numberWithUnsignedChar:(unsigned char)value
{
    return [[ZFNumberBag alloc] initWithUnsignedChar:value];
}
+ (NSNumber *)numberWithUnsignedInt:(unsigned int)value
{
    return [[ZFNumberBag alloc] initWithUnsignedInt:value];
}
+ (NSNumber *)numberWithUnsignedInteger:(NSUInteger)value
{
    return [[ZFNumberBag alloc] initWithUnsignedInteger:value];
}
+ (NSNumber *)numberWithUnsignedLong:(unsigned long)value
{
    return [[ZFNumberBag alloc] initWithUnsignedLong:value];
}
+ (NSNumber *)numberWithUnsignedLongLong:(unsigned long long)value
{
    return [[ZFNumberBag alloc] initWithUnsignedLongLong:value];
}
+ (NSNumber *)numberWithUnsignedShort:(unsigned short)value
{
    return [[ZFNumberBag alloc] initWithUnsignedShort:value];
}

#pragma mark Initializers

-(id)init
{
    if(self = [super init]) {
        _bag = [[NSMutableArray alloc] init];
        _pointer = 0;
    }
    return self;
}
- (id)initWithNumber:(NSNumber *)aNumber
{
    if(self = [self init]) {
        [self.bag addObject:aNumber];
    }
    return self;
}
- (id)initWithObject:(id)anObject
{
    if(self = [self init]) {
        [self.bag addObject:anObject];
    }
    return self;
}

- (id)initWithBool:(BOOL)value
{
    if (self = [self init]) {
        [self.bag addObject:[NSNumber numberWithBool:value]];
    }
    return self;
}
- (id)initWithChar:(char)value
{
    if (self = [self init]) {
        [self.bag addObject:[NSNumber numberWithChar:value]];
    }
    return self;
}
- (id)initWithDouble:(double)value
{
    if (self = [self init]) {
        [self.bag addObject:[NSNumber numberWithDouble:value]];
    }
    return self;
}
- (id)initWithFloat:(float)value
{
    if (self = [self init]) {
        [self.bag addObject:[NSNumber numberWithFloat:value]];
    }
    return self;
}
- (id)initWithInt:(int)value
{
    if (self = [self init]) {
        [self.bag addObject:[NSNumber numberWithInt:value]];
    }
    return self;
}
- (id)initWithInteger:(NSInteger)value
{
    if (self = [self init]) {
        [self.bag addObject:[NSNumber numberWithInteger:value]];
    }
    return self;
}
- (id)initWithLong:(long)value
{
    if (self = [self init]) {
        [self.bag addObject:[NSNumber numberWithLong:value]];
    }
    return self;
}
- (id)initWithLongLong:(long long)value
{
    if (self = [self init]) {
        [self.bag addObject:[NSNumber numberWithLongLong:value]];
    }
    return self;
}
- (id)initWithShort:(short)value
{
    if (self = [self init]) {
        [self.bag addObject:[NSNumber numberWithShort:value]];
    }
    return self;
}
- (id)initWithUnsignedChar:(unsigned char)value
{
    if (self = [self init]) {
        [self.bag addObject:[NSNumber numberWithUnsignedChar:value]];
    }
    return self;
}
- (id)initWithUnsignedInt:(unsigned int)value
{
    if (self = [self init]) {
        [self.bag addObject:[NSNumber numberWithUnsignedInt:value]];
    }
    return self;
}
- (id)initWithUnsignedInteger:(NSUInteger)value
{
    if (self = [self init]) {
        [self.bag addObject:[NSNumber numberWithUnsignedInteger:value]];
    }
    return self;
}
- (id)initWithUnsignedLong:(unsigned long)value
{
    if (self = [self init]) {
        [self.bag addObject:[NSNumber numberWithUnsignedLong:value]];
    }
    return self;
}
- (id)initWithUnsignedLongLong:(unsigned long long)value
{
    if (self = [self init]) {
        [self.bag addObject:[NSNumber numberWithUnsignedLongLong:value]];
    }
    return self;
}
- (id)initWithUnsignedShort:(unsigned short)value
{
    if (self = [self init]) {
        [self.bag addObject:[NSNumber numberWithUnsignedShort:value]];
    }
    return self;
}



#pragma mark Value

- (id)value
{
    return [self objectValue];
}
- (void)setValue:(id)value
{
    [self.bag replaceObjectAtIndex:self.pointer withObject:value];
}


#pragma mark Resetters

- (void)resetWithNumber:(NSNumber *)aNumber
{
    [self.bag removeAllObjects];
    [self beginPointer];
    [self.bag addObject:aNumber];
}
- (void)resetWithInt:(int)anInt
{
    [self resetWithNumber:[NSNumber numberWithInt:anInt]];
}
- (void)resetWithFloat:(float)aFloat
{
    [self resetWithNumber:[NSNumber numberWithFloat:aFloat]];
}
- (void)resetWithBool:(BOOL)aBOOL
{
    [self resetWithNumber:[NSNumber numberWithBool:aBOOL]];
}
- (void)resetWithObject:(id)anObject
{
    [self resetWithNumber:anObject];
}

#pragma mark Adders

- (void)addNumber:(NSNumber *)aNumber
{
    [self.bag addObject:aNumber];
}
- (void)addInt:(int)anInt
{
    [self.bag addObject:[NSNumber numberWithInt:anInt]];
}
- (void)addFloat:(float)aFloat
{
    [self.bag addObject:[NSNumber numberWithFloat:aFloat]];
}
- (void)addBool:(BOOL)aBOOL
{
    [self.bag addObject:[NSNumber numberWithBool:aBOOL]];
}
- (void)addObject:(id)anObject
{
    [self.bag addObject:anObject];
}


#pragma mark Value

- (NSNumber *)numberValue
{
    id thingy = [self objectValue];
    if ([thingy isKindOfClass:[NSNumber class]]) {
        return thingy;
    } else {
        return nil;
    }
}
- (id)objectValue
{
    return [self.bag objectAtIndex:self.pointer];
}

- (BOOL)boolValue
{
    return [[self numberValue] boolValue];
}
- (char)charValue
{
    return [[self numberValue] charValue];
}
- (NSDecimal)decimalValue
{
    return [[self numberValue] decimalValue];
}
- (double)doubleValue
{
    return [[self numberValue] doubleValue];
}
- (float)floatValue
{
    return [[self numberValue] floatValue];
}
- (int)intValue
{
    return [[self numberValue] intValue];
}
- (NSInteger)integerValue
{
    return [[self numberValue] integerValue];
}
- (long long)longLongValue
{
    return [[self numberValue] longLongValue];
}
- (long)longValue
{
    return [[self numberValue] longValue];
}
- (short)shortValue
{
    return [[self numberValue] shortValue];
}
- (unsigned char)unsignedCharValue
{
    return [[self numberValue] unsignedCharValue];
}
- (NSUInteger)unsignedIntegerValue
{
    return [[self numberValue] unsignedIntegerValue];
}
- (unsigned int)unsignedIntValue
{
    return [[self numberValue] unsignedIntValue];
}
- (unsigned long long)unsignedLongLongValue
{
    return [[self numberValue] unsignedLongLongValue];
}
- (unsigned long)unsignedLongValue
{
    return [[self numberValue] unsignedLongValue];
}
- (unsigned short)unsignedShortValue
{
    return [[self numberValue] unsignedShortValue];
}

- (NSString *)descriptionWithLocale:(id)locale
{
    return [[self numberValue] descriptionWithLocale:locale];
}
- (NSString *)stringValue;
{
    return [[self numberValue] stringValue];
}


#pragma mark Pop

- (NSNumber *)popNumber
{
    [self endPointer];
    NSNumber *num = [[self numberValue] copy];
    [self.bag removeLastObject];
    [self decrementPointer];
    return num;
}
- (int)popInt
{
    int num = [[self popNumber] intValue];
    return num;
}
- (float)popFloat
{
    float num = [[self popNumber] floatValue];
    return num;
}
- (BOOL)popBOOL
{
    BOOL num = [[self popNumber] boolValue];
    return num;
}
- (id)popObject
{
    [self endPointer];
    id thing = [[self objectValue] copy];
    [self.bag removeLastObject];
    [self decrementPointer];
    return thing;
}


#pragma mark Last

- (NSNumber *)lastNumber
{
    [self endPointer];
    return [self numberValue];
}
- (int)lastInt
{
    return [[self lastNumber] intValue];
}
- (float)lastFloat
{
    return [[self lastNumber] floatValue];
}
- (BOOL)lastBOOL
{
    return [[self lastNumber] boolValue];
}
- (id)lastObject
{
    [self endPointer];
    return [self objectValue];
}


#pragma mark First

- (NSNumber *)firstNumber
{
    [self beginPointer];
    return [self numberValue];
}
- (int)firstInt
{
    return [[self firstNumber] intValue];
}
- (float)firstFloat
{
    return [[self firstNumber] floatValue];
}
- (BOOL)firstBOOL
{
    return [[self firstNumber] boolValue];
}
- (id)firstObject
{
    [self beginPointer];
    return [self objectValue];
}


#pragma mark Next

- (NSNumber *)nextNumber
{
    [self incrementPointer];
    return [self numberValue];
}
- (int)nextInt
{
    return [[self nextNumber] intValue];
}
- (float)nextFloat
{
    return [[self nextNumber] floatValue];
}
- (BOOL)nextBOOL
{
    return [[self nextNumber] boolValue];
}
- (id)nextObject
{
    return [self nextNumber];
}


#pragma mark Previous

- (NSNumber *)previousNumber
{
    [self decrementPointer];
    return [self numberValue];
}
- (int)previousInt
{
    return [[self previousNumber] intValue];
}
- (float)previousFloat
{
    return [[self previousNumber] floatValue];
}
- (BOOL)previousBOOL
{
    return [[self previousNumber] boolValue];
}
- (id)previousObject
{
    return [self numberValue];
}


#pragma mark Random

- (NSNumber *)randomNumber
{
    [self randomizePointer];
    return [self numberValue];
}
- (int)randomInt
{
    return [[self randomNumber] intValue];
}
- (float)randomFloat
{
    return [[self randomNumber] floatValue];
}
- (BOOL)randomBOOL
{
    return [[self randomNumber] boolValue];
}
- (id)randomObject
{
    return [self randomNumber];
}


#pragma mark -
#pragma mark NSArray

- (NSUInteger)count
{
    return [self.bag count];
}

#pragma mark NSNumber
- (NSComparisonResult)compare:(NSNumber *)otherNumber
{
    return [[self numberValue] compare:otherNumber];
}
- (BOOL)isEqualToNumber:(NSNumber *)number
{
    return [[self numberValue] isEqualToNumber:number];
}
- (const char *)objCType
{
    return [[self numberValue] objCType];
}
- (void)getValue:(void *)value
{
    [[self numberValue] getValue:value];
}

#pragma mark -
#pragma mark Pointer Manipulation

- (NSUInteger)decrementPointer
{
    if (self.pointer == 0) {
        [self endPointer];
    } else {
        self.pointer = self.pointer - 1;
    }
    return self.pointer;
}
- (NSUInteger)incrementPointer
{
    self.pointer = (self.pointer + 1) % [self count];
    return self.pointer;
}
- (NSUInteger)randomizePointer
{
    self.pointer = arc4random_uniform([self count]);
    return self.pointer;
}
- (NSUInteger)beginPointer
{
    self.pointer = 0;
    return self.pointer;
}
- (NSUInteger)endPointer
{
    if ([self count] == 0) {
        self.pointer = 0;
    } else {
        self.pointer = [self count] - 1;
    }
    return self.pointer;
}


@end
