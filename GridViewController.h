//
//  GridViewController.h
//  GridBoard
//
//  Created by Zachary Fleischman on 4/1/13.
//  Copyright (c) 2013 Zachary Fleischman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GridBrain.h"
#import "GridView.h"

@interface GridViewController : UIViewController <GridViewDataSource>

@property (strong, nonatomic)GridBrain *brain;
@property (weak, nonatomic) IBOutlet GridView *gridView;


@end
