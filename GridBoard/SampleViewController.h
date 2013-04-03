//
//  SampleViewController.h
//  GridBoard
//
//  Created by Zachary Fleischman on 4/3/13.
//  Copyright (c) 2013 Zachary Fleischman. All rights reserved.
//



#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>

@interface SampleViewController : UIViewController <AVAudioSessionDelegate>

@property (nonatomic, strong) IBOutlet UIButton *presetOneButton;
@property (nonatomic, strong) IBOutlet UIButton *presetTwoButton;
@property (nonatomic, strong) IBOutlet UIButton *lowNoteButton;
@property (nonatomic, strong) IBOutlet UIButton *midNoteButton;
@property (nonatomic, strong) IBOutlet UIButton *highNoteButton;
@property (nonatomic, strong) IBOutlet UILabel  *currentPresetLabel;

- (IBAction) loadPresetOne:(id)sender;
- (IBAction) loadPresetTwo:(id)sender;
- (IBAction) startPlayLowNote:(id)sender;
- (IBAction) stopPlayLowNote:(id)sender;
- (IBAction) startPlayMidNote:(id)sender;
- (IBAction) stopPlayMidNote:(id)sender;
- (IBAction) startPlayHighNote:(id)sender;
- (IBAction) stopPlayHighNote:(id)sender;

@end