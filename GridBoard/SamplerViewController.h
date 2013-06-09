//
//  SamplerViewController.h
//  GridBoard
//
//  Created by Zachary Fleischman on 6/8/13.
//  Copyright (c) 2013 Zachary Fleischman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface SamplerViewController : UIViewController <AVAudioSessionDelegate>

- (NSSet *)currentNotes;

- (void)loadPresetWithURL:(NSURL *)aURL;

- (void)startPlayingNote:(NSNumber *)note withVelocity:(double)velocity;
- (void)stopPlayingNote:(NSNumber *)note;
- (void)stopPlayingAllNotes;

@end
