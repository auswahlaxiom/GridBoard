//
//  GridConfigViewController.m
//  GridBoard
//
//  Created by Zachary Fleischman on 4/11/13.
//  Copyright (c) 2013 Zachary Fleischman. All rights reserved.
//

#import "GridConfigViewController.h"

@interface GridConfigViewController ()
@property (strong, nonatomic)NSArray *majorScale;
@property (strong, nonatomic)NSArray *minorScale;
@property (strong, nonatomic)NSArray *majorChordInKey;
@property (strong, nonatomic)NSArray *majorChordAbsolute;
@end

@implementation GridConfigViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	self.majorScale = [NSArray arrayWithObjects:[NSNumber numberWithInt:1],
                       [NSNumber numberWithInt:2], [NSNumber numberWithInt:2],
                       [NSNumber numberWithInt:1], [NSNumber numberWithInt:2],
                       [NSNumber numberWithInt:2], [NSNumber numberWithInt:2],
                       nil];
    self.minorScale = [NSArray arrayWithObjects:[NSNumber numberWithInt:2],
                       [NSNumber numberWithInt:2], [NSNumber numberWithInt:1],
                       [NSNumber numberWithInt:2], [NSNumber numberWithInt:2],
                       [NSNumber numberWithInt:1], [NSNumber numberWithInt:2],
                       nil];
    self.majorChordInKey = [NSArray arrayWithObjects:[NSNumber numberWithInt:0],
                       [NSNumber numberWithInt:2], [NSNumber numberWithInt:2],
                       nil];
    self.majorChordAbsolute = [NSArray arrayWithObjects:[NSNumber numberWithInt:0],
                            [NSNumber numberWithInt:4], [NSNumber numberWithInt:3],
                            nil];
    [self refreshUI];
    
}


- (void)refreshUI {
    self.keyLabel.text = [GridBrain nameForMidiNote:[[self.brain key] intValue] showOctave:NO];
    self.keySlider.value = self.brain.key.intValue;
    
    self.rowsLabel.text = [[self.brain numRows] stringValue];
    self.rowsSlider.value = self.brain.numRows.intValue;
    
    self.rowIntervalLabel.text = [[self.brain rowInterval] stringValue];
    self.rowIntervalSlider.value = self.brain.rowInterval.intValue;
    
    self.baseOctaveLabel.text = [[self.brain startOctave] stringValue];
    self.baseOctaveSlider.value = self.brain.startOctave.intValue;
    
    [self.chordInKeySwitch setOn:[[self.brain chordInKey] boolValue]];
    [self.rowInKeySwitch setOn:[[self.brain rowInKey] boolValue]];
    
    if ([self.brain.scale isEqualToArray:self.majorScale]) {
        self.scaleSegment.selectedSegmentIndex = 0;
    } else if ([self.brain.scale isEqualToArray:self.minorScale]) {
        self.scaleSegment.selectedSegmentIndex = 1;
    } else {
        self.scaleSegment.selectedSegmentIndex = 2;
    }
    
    self.scaleTextField.text = [self stringForNotes:self.brain.scale];
    
    if ([self.brain.chord  isEqualToArray:[NSArray arrayWithObject:[NSNumber numberWithInt:0]]]) {
        self.chordSegment.selectedSegmentIndex = 0;
    } else if ([self.brain.chordInKey boolValue]) {
        if ([self.brain.chord isEqualToArray:self.majorChordInKey]) {
            self.chordSegment.selectedSegmentIndex = 1;
        } else {
            self.chordSegment.selectedSegmentIndex = 2;
        }
    } else {
        if ([self.brain.chord isEqualToArray:self.majorChordAbsolute]) {
            self.chordSegment.selectedSegmentIndex = 1;
        } else {
            self.chordSegment.selectedSegmentIndex = 2;
        }
    }
    self.chordTextField.text = [self stringForNotes:self.brain.chord];
}


- (void)refreshGridView
{
    self.gridView.rows = [self.brain.numRows intValue];
    self.gridView.columns = (self.brain.scale.count + 1);
    [self.gridView setNeedsDisplay];
}


- (NSString *)stringForNotes:(NSArray *)notes
{
    NSString *customNotes = @"";
    for (NSNumber *num in notes) {
        customNotes = [customNotes stringByAppendingString:[NSString stringWithFormat:@"%i ", [num intValue]]];
    }
    return customNotes;
}


- (NSArray *)notesForString:(NSString *)string
{
    NSMutableArray *notes = [[NSMutableArray alloc] init];
    for (NSString *num in [string componentsSeparatedByString:@" "]) {
        [notes addObject:[NSNumber numberWithInt:[num intValue]]];
    }
    return notes;
}


- (IBAction)scaleSelector:(UISegmentedControl *)sender
{
    if (sender.selectedSegmentIndex == 0) {
        self.brain.scale = self.majorScale;
    } else if (sender.selectedSegmentIndex == 1) {
        self.brain.scale = self.minorScale;
    } else if (sender.selectedSegmentIndex == 2) {
        self.brain.scale = [self notesForString:self.scaleTextField.text];
    }
    [self refreshUI];
    [self refreshGridView];
}


- (IBAction)keyChanged:(UISlider *)sender
{
    int key = sender.value;
    self.brain.key = [NSNumber numberWithInt:key];
    self.keyLabel.text = [GridBrain nameForMidiNote:key showOctave:NO];
    [self refreshGridView];
}


- (IBAction)rowsChanged:(UISlider *)sender
{
    int rows = sender.value;
    self.brain.numRows = [NSNumber numberWithInt:rows];
    self.rowsLabel.text = [NSString stringWithFormat:@"%i", rows];
    [self refreshGridView];
}


- (IBAction)rowIntervalChanged:(UISlider *)sender
{
    int rowInterval = sender.value;
    self.brain.rowInterval = [NSNumber numberWithInt:rowInterval];
    self.rowIntervalLabel.text = [NSString stringWithFormat:@"%i", rowInterval];
    [self refreshGridView];
}


- (IBAction)rowInKeyChanged:(UISwitch *)sender
{
    self.brain.rowInKey = [NSNumber numberWithBool:sender.on];
    [self refreshGridView];
}


- (IBAction)baseOctaveChanged:(UISlider *)sender
{
    int startOctave = sender.value;
    self.brain.startOctave = [NSNumber numberWithInt:startOctave];
    self.baseOctaveLabel.text = [NSString stringWithFormat:@"%i", startOctave];
    [self refreshGridView];
}


- (IBAction)chordChanged:(UISegmentedControl *)sender
{
    if (sender.selectedSegmentIndex == 0) {
        self.brain.chord = [NSArray arrayWithObject:[NSNumber numberWithInt:0]];
    } else if ([self.brain.chordInKey boolValue]) {
        if (sender.selectedSegmentIndex == 1) {
            self.brain.chord = self.majorChordInKey;
        } else {
            self.brain.chord = [self notesForString:self.chordTextField.text];
        }
    } else {
        if (sender.selectedSegmentIndex == 1) {
            self.brain.chord = self.majorChordAbsolute;
        } else {
            self.brain.chord = [self notesForString:self.chordTextField.text];
        }
    }
    [self refreshUI];
    [self refreshGridView];
}


- (IBAction)chordInKeyChanged:(UISwitch *)sender
{
    self.brain.chordInKey = [NSNumber numberWithBool:sender.on];
    if ([self.brain.chordInKey boolValue]) {
        if ([self.brain.chord isEqualToArray:self.majorChordAbsolute]) {
            self.brain.chord = self.majorChordInKey;
        }
    } else {
        if ([self.brain.chord isEqualToArray:self.majorChordInKey]) {
            self.brain.chord = self.majorChordAbsolute;
        }
    }
    [self refreshUI];
    [self refreshGridView];
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if (textField == self.chordTextField) {
        self.brain.chord = [self notesForString:textField.text];
    } else if (textField == self.scaleTextField) {
        self.brain.scale = [self notesForString:textField.text];
    }
    [self refreshUI];
    [self refreshGridView];
    return NO;
}


- (void)viewDidUnload
{
    [self setScaleTextField:nil];
    [self setKeyLabel:nil];
    [self setRowsLabel:nil];
    [self setRowIntervalLabel:nil];
    [self setBaseOctaveLabel:nil];
    [self setChordTextField:nil];
    [self setRowInKeySwitch:nil];
    [self setChordInKeySwitch:nil];
    [self setScaleSegment:nil];
    [self setChordSegment:nil];
    [self setKeySlider:nil];
    [self setRowsSlider:nil];
    [self setRowIntervalSlider:nil];
    [self setBaseOctaveSlider:nil];
    [super viewDidUnload];
}
@end
