//
//  GridViewController.m
//  GridBoard
//
//  Created by Zachary Fleischman on 4/1/13.
//  Copyright (c) 2013 Zachary Fleischman. All rights reserved.
//

#import "GridViewController.h"
#import "GridConfigViewController.h"
#import "EPSSampler.h"

//For debug from sample code
#import <AssertMacros.h>


@interface GridViewController ()
//Keep track of what notes are active, converted to points and passed to view for coloring
@property (strong, nonatomic) NSMutableArray *activeNotes;

//Shiney new synthesizer
@property (strong, nonatomic) EPSSampler *sampler;

@end

@implementation GridViewController


#pragma mark -
#pragma mark Note Control

-(void)notesOn:(NSArray *)notes
{
    [self.activeNotes addObjectsFromArray:notes];
    NSMutableArray *gridActive = [self.gridView.activeNotes mutableCopy];
    
    for(NSNumber *note in notes) {
        for(NSValue *pointVal in [self.brain gridLocationOfNote:[note intValue]]) {
            [gridActive addObject:pointVal];
        }

        [self.sampler startPlayingNote:[note integerValue] withVelocity:0.7];
    }
    self.gridView.activeNotes = gridActive;
}


-(void)notesOff:(NSArray *)notes
{
    [self.activeNotes addObjectsFromArray:notes];
    NSMutableArray *gridActive = [self.gridView.activeNotes mutableCopy];

    for(NSNumber *note in notes) {
        [self.activeNotes removeObject:note];
        for(NSValue *pointVal in [self.brain gridLocationOfNote:[note intValue]]) {
            [gridActive removeObject:pointVal];
        }

        [self.sampler stopPlayingNote:[note integerValue]];
    }
    self.gridView.activeNotes = gridActive;
}


#pragma mark -
#pragma mark Private Methods

#pragma mark Touch Events

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for(UITouch *touch in touches) {
        CGPoint gridLoc = [self gridLocationOfTouch:touch];
        [self notesOn:[self.brain notesForTouchAtXValue:(int)gridLoc.x YValue:(int)gridLoc.y]];
    }
}


-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
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


-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    for(UITouch *touch in touches) {
        CGPoint gridLoc = [self gridLocationOfTouch:touch];
        [self notesOff:[self.brain notesForTouchAtXValue:(int)gridLoc.x YValue:(int)gridLoc.y]];
    }
}


-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    //same as touches ended?
    [self touchesEnded:touches withEvent:event];
}


-(CGPoint)gridLocationOfTouch:(UITouch *)touch
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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString: @"Config"]) {
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



#pragma mark -
#pragma mark Audio session control

// Respond to an audio interruption, such as a phone call or a Clock alarm.
- (void) beginInterruption
{
    
    // Stop any notes that are currently playing.
    [self notesOff:self.activeNotes];
    
    // Interruptions do not put an AUGraph object into a "stopped" state, so
    //    do that here.
    [self.sampler stopAudioProcessingGraph];
}


// Respond to the ending of an audio interruption.
- (void) endInterruptionWithFlags: (NSUInteger) flags
{
    
    NSError *endInterruptionError = nil;
    [[AVAudioSession sharedInstance] setActive: YES
                                         error: &endInterruptionError];
    if (endInterruptionError != nil) {
        
        NSLog (@"Unable to reactivate the audio session.");
        return;
    }
    
    if (flags & AVAudioSessionInterruptionFlags_ShouldResume) {
        

//         In a shipping application, check here to see if the hardware sample rate changed from
//         its previous value by comparing it to graphSampleRate. If it did change, reconfigure
//         the ioInputStreamFormat struct to use the new sample rate, and set the new stream
//         format on the two audio units. (On the mixer, you just need to change the sample rate).
//         
//         Then call AUGraphUpdate on the graph before starting it.

        
        [self.sampler restartAudioProcessingGraph];
    }
}


#pragma mark - Application state management

// The audio processing graph should not run when the screen is locked or when the app has
//  transitioned to the background, because there can be no user interaction in those states.
//  (Leaving the graph running with the screen locked wastes a significant amount of energy.)
//
// Responding to these UIApplication notifications allows this class to stop and restart the
//    graph as appropriate.
- (void) registerForUIApplicationNotifications
{
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter addObserver: self
                           selector: @selector (handleResigningActive:)
                               name: UIApplicationWillResignActiveNotification
                             object: [UIApplication sharedApplication]];
    
    [notificationCenter addObserver: self
                           selector: @selector (handleBecomingActive:)
                               name: UIApplicationDidBecomeActiveNotification
                             object: [UIApplication sharedApplication]];
}


- (void) handleResigningActive: (id) notification
{
    
    [self notesOff:self.activeNotes];

    [self.sampler stopAudioProcessingGraph];
}


- (void) handleBecomingActive: (id) notification
{
    
    [self.sampler restartAudioProcessingGraph];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSURL *aupURL = [[NSBundle mainBundle] URLForResource:@"Trombone" withExtension:@"aupreset"];
    self.sampler = [[EPSSampler alloc] initWithPresetURL:aupURL];
    
	self.brain = [[GridBrain alloc] init];
    self.gridView.rows = [self.brain.numRows intValue];
    self.gridView.columns = (self.brain.scale.count + 1);
    self.gridView.dataSource = self;
    self.activeNotes = [[NSMutableArray alloc] init];
    
    [self registerForUIApplicationNotifications];

}

@end
