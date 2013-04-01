//
//  GridViewController.h
//  GridBoard
//
//  Created by Zachary Fleischman on 4/1/13.
//  Copyright (c) 2013 Zachary Fleischman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GridBrain.h"

@interface GridViewController : UIViewController

@property (strong, nonatomic)GridBrain *brain;
@property (weak, nonatomic) IBOutlet UITextView *notesDisplay;
- (IBAction)notePressedEnd:(UITextField *)sender;
@property (weak, nonatomic) IBOutlet UILabel *notesPlayedLabel;

@end
