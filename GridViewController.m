//
//  GridViewController.m
//  GridBoard
//
//  Created by Zachary Fleischman on 4/1/13.
//  Copyright (c) 2013 Zachary Fleischman. All rights reserved.
//

#import "GridViewController.h"

@interface GridViewController ()
@property (strong, nonatomic)NSMutableArray *activeNotes;
@end

@implementation GridViewController

@synthesize brain = _brain;
@synthesize gridView = _gridView;
@synthesize activeNotes = _activeNotes;


- (void)viewDidLoad
{
    [super viewDidLoad];
	self.brain = [[GridBrain alloc] init];
    self.gridView.rows = [self.brain.numRows intValue];
    self.gridView.columns = (self.brain.scale.count + 1);
    self.gridView.dataSource = self;
    self.activeNotes = [[NSMutableArray alloc] init];
}

- (NSString *)stringForCellAtXValue:(int) x YValue:(int) y {
    NSArray *notes = [self.brain notesForRow:(y + [self.brain.startRow intValue])];
    int note = [[notes objectAtIndex:x] intValue];
    return [GridBrain nameForMidiNote:note showOctave:YES];
}

//Music Stuff
-(void)notesOn:(NSArray *)notes {
    [self.activeNotes addObjectsFromArray:notes];
    NSMutableArray *gridActive = [self.gridView.activeNotes mutableCopy];
    
    for(NSNumber *note in notes) {
        for(NSValue *pointVal in [self.brain gridLocationOfNote:[note intValue]]) {
            [gridActive addObject:pointVal];
        }

        //TODO: ACTIVATE THE MIDI NOTE
        NSLog([NSString stringWithFormat:@"MIDI  on: %i", [note intValue]]);
    }
    self.gridView.activeNotes = gridActive;
}
-(void)notesOff:(NSArray *)notes {
    [self.activeNotes addObjectsFromArray:notes];
    NSMutableArray *gridActive = [self.gridView.activeNotes mutableCopy];

    for(NSNumber *note in notes) {
        [self.activeNotes removeObject:note];
        for(NSValue *pointVal in [self.brain gridLocationOfNote:[note intValue]]) {
            [gridActive removeObject:pointVal];
        }
        //TODO: DEACTIVATE THE MIDI NOTE
        NSLog([NSString stringWithFormat:@"MIDI off: %i", [note intValue]]);
    }
    self.gridView.activeNotes = gridActive;
}

//touch events
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    for(UITouch *touch in touches) {
        CGPoint gridLoc = [self gridLocationOfTouch:touch];
        [self notesOn:[self.brain notesForTouchAtXValue:(int)gridLoc.x YValue:(int)gridLoc.y]];
    }
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    for(UITouch *touch in touches) {
        CGPoint gridLoc = [self gridLocationOfTouch:touch];
        NSArray *newNotes = [self.brain notesForTouchAtXValue:(int)gridLoc.x YValue:(int)gridLoc.y];
        NSMutableArray *notesToTurnOn = [[NSMutableArray alloc] init];
        NSMutableArray *notesToTurnOff = [[NSMutableArray alloc] init];
        
        for(NSNumber *activeNote in self.activeNotes) {
            if(![newNotes containsObject:activeNote]){
                [notesToTurnOff addObject:activeNote];
            }
        }
        for(NSNumber *newNote in newNotes) {
            if(![self.activeNotes containsObject:newNote]) {
                [notesToTurnOn addObject:newNote];
            }
        }

        [self notesOn:notesToTurnOn];
        [self notesOff:notesToTurnOff];
    }
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    for(UITouch *touch in touches) {
        CGPoint gridLoc = [self gridLocationOfTouch:touch];
        [self notesOff:[self.brain notesForTouchAtXValue:(int)gridLoc.x YValue:(int)gridLoc.y]];
    }
}
-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    //same as touches ended?
    [self touchesEnded:touches withEvent:event];
}
-(CGPoint)gridLocationOfTouch:(UITouch *)touch {
    CGFloat height = self.gridView.bounds.size.height;
    CGFloat width = self.gridView.bounds.size.width;
    CGFloat vInterval = height / (float) self.gridView.rows;
    CGFloat hInterval = width / (float) self.gridView.columns;
    
    int xLoc = [touch locationInView:self.gridView].x / hInterval;
    int yLoc = self.gridView.rows - [touch locationInView:self.gridView].y / vInterval;
    return CGPointMake(xLoc, yLoc);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    //Only Landscape
    return ((interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (interfaceOrientation == UIInterfaceOrientationLandscapeRight));
}
@end
