//
//  KeyConfigViewController.m
//  Keys
//
//  Created by Zach Fleischman on 5/15/13.
//  Copyright (c) 2013 Zach Fleischman. All rights reserved.
//

#import "KeyConfigViewController.h"

@interface KeyConfigViewController ()

@end

@implementation KeyConfigViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)whiteWidth:(UISlider *)sender {
    NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:sender.value] forKey:@"whiteWidth"];
    [self.delegate updateWithProperties:dict];
}


- (IBAction)whiteHeight:(UISlider *)sender {
    NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:sender.value] forKey:@"whiteHeight"];
    [self.delegate updateWithProperties:dict];
}


- (IBAction)blackWidth:(UISlider *)sender {
    NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:sender.value] forKey:@"blackWidth"];
    [self.delegate updateWithProperties:dict];
}


- (IBAction)blackHeight:(UISlider *)sender {
    NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:sender.value] forKey:@"blackHeight"];
    [self.delegate updateWithProperties:dict];
}


- (IBAction)octaves:(UISlider *)sender {
    NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:(int)sender.value] forKey:@"octaves"];
    [self.delegate updateWithProperties:dict];
}


- (IBAction)names:(UISwitch *)sender {
    NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:sender.on] forKey:@"names"];
    [self.delegate updateWithProperties:dict];
}
@end
