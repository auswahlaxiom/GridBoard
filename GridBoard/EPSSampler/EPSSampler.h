//
//  EPSSampler.h
//
//  Created by Peter Stuart on 02/10/13.
//  Copyright (c) 2013 Electric Peel Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>
@interface EPSSampler : NSObject

- (id)initWithPresetURL:(NSURL *)url audioSessionDelegate: (id<AVAudioSessionDelegate>)delegate;

-(OSStatus) loadFromDLSOrSoundFont: (NSURL *)bankURL withPatch: (int)presetNumber;

- (void)startPlayingNote:(UInt32)note withVelocity:(double)velocity;
- (void)stopPlayingNote:(UInt32)note;

- (void)stopAudioProcessingGraph;
- (void)restartAudioProcessingGraph;

- (AUGraph)processingGraph;

@end
