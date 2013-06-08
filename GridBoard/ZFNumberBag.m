//
//  ZFNumberBag.m
//  GridBoard
//
//  Created by Zachary Fleischman on 6/8/13.
//  Copyright (c) 2013 Zachary Fleischman. All rights reserved.
//

#import "ZFNumberBag.h"

@interface ZFNumberBag ()

@property NSUInteger pointer;

@end

@implementation ZFNumberBag


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
- (id)initWithInt:(int)anInt
{
    if(self = [self init]) {
        [self.bag addObject:[NSNumber numberWithInt:anInt]];
    }
    return self;
}
- (id)initWithFloat:(float)aFloat
{
    if(self = [self init]) {
        [self.bag addObject:[NSNumber numberWithFloat:aFloat]];
    }
    return self;
}
- (id)initWithBool:(BOOL)aBOOL
{
    if(self = [self init]) {
        [self.bag addObject:[NSNumber numberWithBool:aBOOL]];
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
- (int)intValue
{
    return [[self numberValue] intValue];
}
- (float)floatValue
{
    return [[self numberValue] floatValue];
}
- (BOOL)boolValue
{
    return [[self numberValue] boolValue];
}
- (id)objectValue
{
    return [self.bag objectAtIndex:self.pointer];
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
