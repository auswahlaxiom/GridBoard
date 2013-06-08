//
//  KeyViewController.h
//  Keys
//
//  Created by Zach Fleischman on 5/14/13.
//  Copyright (c) 2013 Zach Fleischman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KeyConfigViewController.h"
@interface KeyViewController : UIViewController <KeyConfigDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *keyScrollView;
- (NSArray *)activeNotes;

@property (strong, nonatomic) NSNumber* whiteWidth;
@property (strong, nonatomic) NSNumber* blackWidth;

@property (strong, nonatomic) NSNumber* whiteHeightProportion;
@property (strong, nonatomic) NSNumber* blackHeightProportion;

@property (strong, nonatomic) NSNumber* octaves;

//Interpretted as boolean
@property (strong, nonatomic) NSNumber* displayNoteNames;
- (IBAction)displayConfig:(id)sender;

@property (weak, nonatomic) KeyConfigViewController *configger;
//delegate
-(void)updateWithProperties:(NSDictionary *)properties;


@end
