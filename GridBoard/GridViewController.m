//
//  GridViewController.m
//  GridBoard
//
//  Created by Zachary Fleischman on 4/1/13.
//  Copyright (c) 2013 Zachary Fleischman. All rights reserved.
//

#import "GridViewController.h"
#import "GridConfigViewController.h"
#import "GridSampler.h"

//For debug from sample code
#import <AssertMacros.h>


@interface GridViewController ()

//Keep track of what notes are active, converted to points and passed to view for coloring
@property (strong, nonatomic) NSMutableSet *touches;
@property (strong, nonatomic) GridSampler *sampler;

@end

@implementation GridViewController


#pragma mark -
#pragma mark Note Control

- (void)notesOn:(NSSet *)notes
{
    NSMutableArray *gridActive = [self.gridView.activeSquares mutableCopy];
    
    for (NSNumber *note in notes) {
        for (NSValue *pointVal in [self.brain gridLocationOfNote:[note intValue]]) {
            [gridActive addObject:pointVal];
        }

        [self startPlayingNote:note withVelocity:0.7];
    }
    self.gridView.activeSquares = gridActive;
}


- (void)notesOff:(NSSet *)notes
{
    NSMutableArray *gridActive = [self.gridView.activeSquares mutableCopy];

    for (NSNumber *note in notes) {
        for (NSValue *pointVal in [self.brain gridLocationOfNote:[note intValue]]) {
            [gridActive removeObject:pointVal];
        }

        [self stopPlayingNote:note];
    }
    self.gridView.activeSquares = gridActive;
}


- (void)updateNotes
{
    NSMutableSet *newNotes = [[NSMutableSet alloc] init];
    for (NSValue *touch in self.touches) {
        CGPoint gridLoc = [touch CGPointValue];
        [newNotes addObjectsFromArray:[self.brain notesForTouchAtXValue:gridLoc.x YValue:gridLoc.y]];
    }
    
    if (![self.currentNotes isEqualToSet:newNotes]) {
        NSMutableSet *notesToTurnOff = [self.currentNotes mutableCopy];
        [notesToTurnOff minusSet:newNotes];
        
        [self notesOn:newNotes];
        [self notesOff:notesToTurnOff];
    }
}


#pragma mark -
#pragma mark Private Methods

#pragma mark Touch Events

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches) {
        CGPoint gridLoc = [self gridLocationOfTouch:touch];
        
        [self.touches addObject:[NSValue valueWithCGPoint:gridLoc]];
    }
    [self updateNotes];
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSMutableSet *newTouches = [[NSMutableSet alloc] initWithCapacity:[[event allTouches] count]];
    for (UITouch *touch in [event allTouches]) {
        CGPoint gridLoc = [self gridLocationOfTouch:touch];
        [newTouches addObject:[NSValue valueWithCGPoint:gridLoc]];
    }
    if (![self.touches isEqualToSet:newTouches]) {
        self.touches = newTouches;
        [self updateNotes];
    }
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches) {
        CGPoint gridLoc = [self gridLocationOfTouch:touch];

        [self.touches removeObject:[NSValue valueWithCGPoint:gridLoc]];
    }
    [self updateNotes];
}


- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
}


- (CGPoint)gridLocationOfTouch:(UITouch *)touch
{
    CGFloat height = self.gridView.bounds.size.height;
    CGFloat width = self.gridView.bounds.size.width;
    CGFloat vInterval = height / (float) self.gridView.rows;
    CGFloat hInterval = width / (float) self.gridView.columns;
    
    int xLoc = [touch locationInView:self.gridView].x / hInterval;
    int yLoc = self.gridView.rows - [touch locationInView:self.gridView].y / vInterval;
    return CGPointMake(xLoc, yLoc);
}


#pragma mark UIViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString: @"Config"]) {
        GridConfigViewController *dest = (GridConfigViewController *)segue.destinationViewController;
        dest.brain = self.brain;
        dest.gridView = self.gridView;
    }
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    //Only Landscape
    return ((interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (interfaceOrientation == UIInterfaceOrientationLandscapeRight));
}


#pragma mark -
#pragma mark GridDataSource

- (NSString *)stringForCellAtXValue:(int) x YValue:(int) y
{
    NSArray *notes = [self.brain notesForRow:(y)];
    int note = [[notes objectAtIndex:x] intValue];
    return [GridBrain nameForMidiNote:note showOctave:YES];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
	self.brain = [[GridBrain alloc] init];
    self.gridView.rows = [self.brain.numRows intValue];
    self.gridView.columns = (self.brain.scale.count + 1);
    self.gridView.dataSource = self;
    self.touches = [[NSMutableSet alloc] init];
}

@end
