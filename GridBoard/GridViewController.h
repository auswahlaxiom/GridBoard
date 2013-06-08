//
//  GridViewController.h
//  GridBoard
//
//  Created by Zachary Fleischman on 4/1/13.
//  Copyright (c) 2013 Zachary Fleischman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>


#import "GridBrain.h"
#import "GridView.h"

@interface GridViewController : UIViewController <GridViewDataSource, AVAudioSessionDelegate>

@property (strong, nonatomic)GridBrain *brain;
@property (weak, nonatomic) IBOutlet GridView *gridView;

-(NSString *)stringForCellAtXValue:(int)x YValue:(int)y;

@end
