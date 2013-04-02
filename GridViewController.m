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
@synthesize gridView = _gridView;


- (void)viewDidLoad
{
    [super viewDidLoad];
	self.brain = [[GridBrain alloc] init];
    self.gridView.rows = [self.brain.numRows intValue];
    self.gridView.columns = (self.brain.scale.count + 1);
    self.gridView.dataSource = self;
}

- (NSString *)stringForCellAtXValue:(int) x YValue:(int) y {
    NSArray *notes = [self.brain notesForRow:y];
    int note = [[notes objectAtIndex:x] intValue];
    return [GridBrain nameForMidiNote:note showOctave:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    //Only Landscape
    return ((interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (interfaceOrientation == UIInterfaceOrientationLandscapeRight));
}
@end
