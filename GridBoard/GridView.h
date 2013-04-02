//
//  GridView.h
//  GridBoard
//
//  Created by Zachary Fleischman on 4/1/13.
//  Copyright (c) 2013 Zachary Fleischman. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GridView; //forward reference so the protocal knows what a grid view is

@protocol GridViewDataSource
- (NSString *)stringForCellAtXValue:(int) x YValue:(int) y;
@end

@interface GridView : UIView

@property (nonatomic) id<GridViewDataSource> dataSource;
@property (nonatomic) int columns;
@property (nonatomic) int rows;
@property (nonatomic) NSArray *activeNotes;

@end
