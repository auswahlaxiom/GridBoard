//
//  GridViewController.m
//  GridBoard
//
//  Created by Zachary Fleischman on 4/1/13.
//  Copyright (c) 2013 Zachary Fleischman. All rights reserved.
//

#import "GridViewController.h"

@interface GridViewController ()

@end

@implementation GridViewController

@synthesize brain = _brain;
@synthesize notesDisplay = _notesDisplay;


- (void)viewDidLoad
{
    [super viewDidLoad];
	self.brain = [[GridBrain alloc] init];
    [self printNotes];
    
}

-(void)printNotes {
    self.notesDisplay.text = @"";
    for(int i = [self.brain.startRow intValue] + [self.brain.numRows intValue] - 1; i != -1; i--) {
        NSString *notes = @"";
        for(int j = 0; j < [[self.brain notesForRow:i] count]; j++) {
            NSString *noteName = [GridBrain nameForMidiNote:[[[self.brain notesForRow:i] objectAtIndex:j] intValue] showOctave:YES];
            notes = [notes stringByAppendingString:[NSString stringWithFormat:@"%@ ", noteName]];
        }
        self.notesDisplay.text = [self.notesDisplay.text stringByAppendingString:[NSString stringWithFormat:@"%@\n", notes]];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    //Only Landscape
    return ((interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (interfaceOrientation == UIInterfaceOrientationLandscapeRight));
}

@end
