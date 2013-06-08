//
//  KeyConfigViewController.h
//  Keys
//
//  Created by Zach Fleischman on 5/15/13.
//  Copyright (c) 2013 Zach Fleischman. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ConfigViewController;

@protocol KeyConfigDelegate <NSObject>

-(void)updateWithProperties:(NSDictionary *)properties;

@end

@interface KeyConfigViewController : UITableViewController

@property (weak, nonatomic)id<KeyConfigDelegate> delegate;

- (IBAction)whiteWidth:(UISlider *)sender;
- (IBAction)whiteHeight:(UISlider *)sender;
- (IBAction)blackWidth:(UISlider *)sender;
- (IBAction)blackHeight:(UISlider *)sender;
- (IBAction)octaves:(UISlider *)sender;
- (IBAction)names:(UISwitch *)sender;

@end
