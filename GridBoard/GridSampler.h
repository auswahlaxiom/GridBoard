//
//  GridSampler.h
//
// Extracted from: https://developer.apple.com/library/ios/samplecode/LoadPresetDemo/Introduction/Intro.html#//apple_ref/doc/uid/DTS40011214
// tech-note: https://developer.apple.com/library/ios/samplecode/LoadPresetDemo/Introduction/Intro.html#//apple_ref/doc/uid/DTS40011214
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>
@interface GridSampler : NSObject

- (id)initWithPresetURL:(NSURL *)url audioSessionDelegate: (id<AVAudioSessionDelegate>)delegate;

-(OSStatus) loadFromDLSOrSoundFont: (NSURL *)bankURL withPatch: (int)presetNumber;

- (void)startPlayingNote:(UInt32)note withVelocity:(double)velocity;
- (void)stopPlayingNote:(UInt32)note;

- (void)stopAudioProcessingGraph;
- (void)restartAudioProcessingGraph;

- (AUGraph)processingGraph;

@end
