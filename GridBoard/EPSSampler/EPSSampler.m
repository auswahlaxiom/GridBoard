//
//  EPSSampler.m
//
//  Created by Peter Stuart on 02/10/13.
//  Copyright (c) 2013 Electric Peel Software. All rights reserved.
//

#import "EPSSampler.h"

#import <AssertMacros.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>

enum
{
	kMIDIMessage_NoteOn  = 0x9,
	kMIDIMessage_NoteOff = 0x8,
};

#define kMidiVelocityMinimum 0
#define kMidiVelocityMaximum 127

@interface EPSSampler ()

@property (readwrite) Float64 graphSampleRate;
@property (nonatomic, readwrite) AUGraph processingGraph;
@property (readwrite) AudioUnit samplerUnit;
@property (readwrite) AudioUnit ioUnit;

- (OSStatus)loadSynthFromPresetURL:(NSURL *)presetURL;
- (BOOL)createAUGraph;
- (void)configureAndStartAudioProcessingGraph:(AUGraph)graph;
- (void)stopAudioProcessingGraph;
- (void)restartAudioProcessingGraph;

@end

@implementation EPSSampler


#pragma mark - Public Methods

- (id)initWithPresetURL:(NSURL *)url audioSessionDelegate: (id<AVAudioSessionDelegate>)delegate
{
	self = [super init];
	if (self) {
        BOOL audioSessionActivated = [self setupAudioSessionWithDelegate:delegate];
        NSAssert (audioSessionActivated == YES, @"Unable to set up audio session.");
		[self createAUGraph];
		[self configureAndStartAudioProcessingGraph:self.processingGraph];
		[self loadSynthFromPresetURL:url];
	}
	
	return self;
}


- (void)startPlayingNote:(UInt32)note withVelocity:(double)velocity
{
	UInt32 noteNum    = note;
	UInt32 onVelocity = kMidiVelocityMinimum + (kMidiVelocityMaximum - kMidiVelocityMinimum) * velocity;
	
	UInt32 noteCommand = kMIDIMessage_NoteOn << 4 | 0;
	
	OSStatus result = noErr;
	require_noerr(result = MusicDeviceMIDIEvent(self.samplerUnit, noteCommand, noteNum, onVelocity, 0), logTheError);
	
logTheError:
	
	if (result != noErr)
	{
		NSLog(@"Unable to start playing the note. Error code: %d '%.4s'\n", (int)result, (const char *)&result);
	}
}


- (void)stopPlayingNote:(UInt32)note
{
	UInt32 noteNum     = note;
	UInt32 noteCommand = kMIDIMessage_NoteOff << 4 | 0;
	
	OSStatus result = noErr;
	
	require_noerr(result = MusicDeviceMIDIEvent(self.samplerUnit, noteCommand, noteNum, 0, 0), logTheError);
	
logTheError:
	
	if (result != noErr)
	{
		NSLog(@"Unable to stop playing the note. Error code: %d '%.4s'\n", (int)result, (const char *)&result);
	}
}


-(OSStatus) loadFromDLSOrSoundFont: (NSURL *)bankURL withPatch: (int)presetNumber
{
    OSStatus result = noErr;

    // fill out a bank preset data structure
    AUSamplerBankPresetData bpdata;
    bpdata.bankURL  = (__bridge CFURLRef) bankURL;
    bpdata.bankMSB  = kAUSampler_DefaultMelodicBankMSB;
    bpdata.bankLSB  = kAUSampler_DefaultBankLSB;
    bpdata.presetID = (UInt8) presetNumber;

    // set the kAUSamplerProperty_LoadPresetFromBank property
    result = AudioUnitSetProperty(self.samplerUnit,
                                  kAUSamplerProperty_LoadPresetFromBank,
                                  kAudioUnitScope_Global,
                                  0,
                                  &bpdata,
                                  sizeof(bpdata));

    // check for errors
    NSCAssert (result == noErr,
               @"Unable to set the preset property on the Sampler. Error code:%d '%.4s'",
               (int) result,
               (const char *)&result);

    return result;
}

- (void)stopAudioProcessingGraph
{
	OSStatus result = noErr;
    
	if (self.processingGraph) {
		result = AUGraphStop(self.processingGraph);
	}
    
	NSAssert(result == noErr, @"Unable to stop the audio processing graph. Error code: %d '%.4s'", (int)result, (const char *)&result);
}


- (void)restartAudioProcessingGraph
{
	OSStatus result = noErr;
    
	if (self.processingGraph) {
		result = AUGraphStart(self.processingGraph);
	}
    
	NSAssert(result == noErr, @"Unable to restart the audio processing graph. Error code: %d '%.4s'", (int)result, (const char *)&result);
}


#pragma mark -
#pragma mark Private Methods

- (BOOL)createAUGraph
{
	OSStatus result = noErr;
	AUNode   samplerNode, ioNode;

	AudioComponentDescription cd = {};

	cd.componentManufacturer = kAudioUnitManufacturer_Apple;
	cd.componentFlags        = 0;
	cd.componentFlagsMask    = 0;

	result = NewAUGraph(&_processingGraph);
	NSCAssert(result == noErr, @"Unable to create an AUGraph object. Error code: %d '%.4s'", (int)result, (const char *)&result);

	cd.componentType    = kAudioUnitType_MusicDevice;
	cd.componentSubType = kAudioUnitSubType_Sampler;

	result = AUGraphAddNode(self.processingGraph, &cd, &samplerNode);
	NSCAssert(result == noErr, @"Unable to add the Sampler unit to the audio processing graph. Error code: %d '%.4s'", (int)result, (const char *)&result);

	cd.componentType    = kAudioUnitType_Output;
	cd.componentSubType = kAudioUnitSubType_RemoteIO;

	result = AUGraphAddNode(self.processingGraph, &cd, &ioNode);
	NSCAssert(result == noErr, @"Unable to add the Output unit to the audio processing graph. Error code: %d '%.4s'", (int)result, (const char *)&result);

	result = AUGraphOpen(self.processingGraph);
	NSCAssert(result == noErr, @"Unable to open the audio processing graph. Error code: %d '%.4s'", (int)result, (const char *)&result);

	result = AUGraphConnectNodeInput(self.processingGraph, samplerNode, 0, ioNode, 0);
	NSCAssert(result == noErr, @"Unable to interconnect the nodes in the audio processing graph. Error code: %d '%.4s'", (int)result, (const char *)&result);

	result = AUGraphNodeInfo(self.processingGraph, samplerNode, 0, &_samplerUnit);
	NSCAssert(result == noErr, @"Unable to obtain a reference to the Sampler unit. Error code: %d '%.4s'", (int)result, (const char *)&result);

	result = AUGraphNodeInfo(self.processingGraph, ioNode, 0, &_ioUnit);
	NSCAssert(result == noErr, @"Unable to obtain a reference to the I/O unit. Error code: %d '%.4s'", (int)result, (const char *)&result);

	return YES;
}


- (void) configureAndStartAudioProcessingGraph: (AUGraph) graph
{
    
    OSStatus result = noErr;
    UInt32 framesPerSlice = 0;
    UInt32 framesPerSlicePropertySize = sizeof (framesPerSlice);
    UInt32 sampleRatePropertySize = sizeof (self.graphSampleRate);
    
    result = AudioUnitInitialize (self.ioUnit);
    NSCAssert (result == noErr, @"Unable to initialize the I/O unit. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    // Set the I/O unit's output sample rate.
    result =    AudioUnitSetProperty (
                                      self.ioUnit,
                                      kAudioUnitProperty_SampleRate,
                                      kAudioUnitScope_Output,
                                      0,
                                      &_graphSampleRate,
                                      sampleRatePropertySize
                                      );
    
    NSAssert (result == noErr, @"AudioUnitSetProperty (set Sampler unit output stream sample rate). Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    // Obtain the value of the maximum-frames-per-slice from the I/O unit.
    result =    AudioUnitGetProperty (
                                      self.ioUnit,
                                      kAudioUnitProperty_MaximumFramesPerSlice,
                                      kAudioUnitScope_Global,
                                      0,
                                      &framesPerSlice,
                                      &framesPerSlicePropertySize
                                      );
    
    NSCAssert (result == noErr, @"Unable to retrieve the maximum frames per slice property from the I/O unit. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    // Set the Sampler unit's output sample rate.
    result =    AudioUnitSetProperty (
                                      self.samplerUnit,
                                      kAudioUnitProperty_SampleRate,
                                      kAudioUnitScope_Output,
                                      0,
                                      &_graphSampleRate,
                                      sampleRatePropertySize
                                      );
    
    NSAssert (result == noErr, @"AudioUnitSetProperty (set Sampler unit output stream sample rate). Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    // Set the Sampler unit's maximum frames-per-slice.
    result =    AudioUnitSetProperty (
                                      self.samplerUnit,
                                      kAudioUnitProperty_MaximumFramesPerSlice,
                                      kAudioUnitScope_Global,
                                      0,
                                      &framesPerSlice,
                                      framesPerSlicePropertySize
                                      );
    
    NSAssert( result == noErr, @"AudioUnitSetProperty (set Sampler unit maximum frames per slice). Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    
    if (graph) {
        
        // Initialize the audio processing graph.
        result = AUGraphInitialize (graph);
        NSAssert (result == noErr, @"Unable to initialze AUGraph object. Error code: %d '%.4s'", (int) result, (const char *)&result);
        
        // Start the graph
        result = AUGraphStart (graph);
        NSAssert (result == noErr, @"Unable to start audio processing graph. Error code: %d '%.4s'", (int) result, (const char *)&result);
        
        // Print out the graph to the console
        CAShow (graph);
    }
}



- (BOOL) setupAudioSessionWithDelegate: (id<AVAudioSessionDelegate>) delegate
{
    
    AVAudioSession *mySession = [AVAudioSession sharedInstance];
    
    // Specify that this object is the delegate of the audio session, so that
    //    this object's endInterruption method will be invoked when needed.
    [mySession setDelegate: delegate];
    
    // Assign the Playback category to the audio session. This category supports
    //    audio output with the Ring/Silent switch in the Silent position.
    NSError *audioSessionError = nil;
    [mySession setCategory: AVAudioSessionCategoryPlayback error: &audioSessionError];
    if (audioSessionError != nil) {NSLog (@"Error setting audio session category."); return NO;}
    
    // Request a desired hardware sample rate.
    self.graphSampleRate = 44100.0;    // Hertz
    
    [mySession setPreferredHardwareSampleRate: self.graphSampleRate error: &audioSessionError];
    if (audioSessionError != nil) {NSLog (@"Error setting preferred hardware sample rate."); return NO;}
    
    // Activate the audio session
    [mySession setActive: YES error: &audioSessionError];
    if (audioSessionError != nil) {NSLog (@"Error activating the audio session."); return NO;}
    
    // Obtain the actual hardware sample rate and store it for later use in the audio processing graph.
    self.graphSampleRate = [mySession currentHardwareSampleRate];
    
    return YES;
}


- (OSStatus)loadSynthFromPresetURL:(NSURL *)presetURL
{
	CFDataRef propertyResourceData = 0;
	Boolean   status;
	SInt32    errorCode = 0;
	OSStatus  result    = noErr;

	status = CFURLCreateDataAndPropertiesFromResource(
		kCFAllocatorDefault,
		(__bridge CFURLRef)presetURL,
		&propertyResourceData,
		NULL,
		NULL,
		&errorCode
		);

	NSAssert(status == YES && propertyResourceData != 0, @"Unable to create data and properties from a preset. Error code: %d '%.4s'", (int)errorCode, (const char *)&errorCode);

	CFPropertyListRef    presetPropertyList = 0;
	CFPropertyListFormat dataFormat         = 0;
	CFErrorRef           errorRef           = 0;
	presetPropertyList = CFPropertyListCreateWithData(
		kCFAllocatorDefault,
		propertyResourceData,
		kCFPropertyListImmutable,
		&dataFormat,
		&errorRef
		);

	if (presetPropertyList != 0) {
		result = AudioUnitSetProperty(
			self.samplerUnit,
			kAudioUnitProperty_ClassInfo,
			kAudioUnitScope_Global,
			0,
			&presetPropertyList,
			sizeof(CFPropertyListRef)
			);

		CFRelease(presetPropertyList);
	}

	if (errorRef) {
		CFRelease(errorRef);
	}

	CFRelease(propertyResourceData);

	return result;
}

@end