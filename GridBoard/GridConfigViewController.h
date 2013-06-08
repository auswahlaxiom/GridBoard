//
//  GridConfigViewController.h
//  GridBoard
//
//  Created by Zachary Fleischman on 4/11/13.
//  Copyright (c) 2013 Zachary Fleischman. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GridBrain.h"
#import "GridView.h"


@interface GridConfigViewController : UIViewController <UITextFieldDelegate>

//THIS IS VERY BAD!!!! but i need to get it done quick for demo on 4/12/2013
@property (weak, nonatomic) GridBrain *brain;
@property (weak, nonatomic) GridView *gridView;

- (IBAction)scaleSelector:(UISegmentedControl *)sender;
@property (weak, nonatomic) IBOutlet UISegmentedControl *scaleSegment;
@property (weak, nonatomic) IBOutlet UITextField *scaleTextField;

- (IBAction)keyChanged:(UISlider *)sender;
@property (weak, nonatomic) IBOutlet UILabel *keyLabel;
@property (weak, nonatomic) IBOutlet UISlider *keySlider;

- (IBAction)rowsChanged:(UISlider *)sender;
@property (weak, nonatomic) IBOutlet UILabel *rowsLabel;
@property (weak, nonatomic) IBOutlet UISlider *rowsSlider;

- (IBAction)rowIntervalChanged:(UISlider *)sender;
@property (weak, nonatomic) IBOutlet UILabel *rowIntervalLabel;
@property (weak, nonatomic) IBOutlet UISlider *rowIntervalSlider;

- (IBAction)rowInKeyChanged:(UISwitch *)sender;
@property (weak, nonatomic) IBOutlet UISwitch *rowInKeySwitch;

- (IBAction)baseOctaveChanged:(UISlider *)sender;
@property (weak, nonatomic) IBOutlet UILabel *baseOctaveLabel;
@property (weak, nonatomic) IBOutlet UISlider *baseOctaveSlider;

- (IBAction)chordChanged:(UISegmentedControl *)sender;
@property (weak, nonatomic) IBOutlet UISegmentedControl *chordSegment;
@property (weak, nonatomic) IBOutlet UITextField *chordTextField;

- (IBAction)chordInKeyChanged:(UISwitch *)sender;
@property (weak, nonatomic) IBOutlet UISwitch *chordInKeySwitch;

@end
