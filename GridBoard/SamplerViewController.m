//
//  SamplerViewController.m
//  GridBoard
//
//  Created by Zachary Fleischman on 6/8/13.
//  Copyright (c) 2013 Zachary Fleischman. All rights reserved.
//

#import "SamplerViewController.h"
#import "GridSampler.h"


@interface SamplerViewController ()

@property (strong, nonatomic) GridSampler *sampler;
@property (strong, nonatomic) NSMutableSet *activeNotes;

@end

@implementation SamplerViewController


#pragma mark Public

- (void)loadPresetWithURL:(NSURL *)aURL
{
    [self.sampler loadSynthFromPresetURL:aURL];
}

- (NSSet *)currentNotes
{
    return [self.activeNotes copy];
}


#pragma mark -
#pragma mark Set up and tear down

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSURL *aupURL = [[NSBundle mainBundle] URLForResource:@"Trombone" withExtension:@"aupreset"];
    self.sampler = [[GridSampler alloc] initWithPresetURL:aupURL audioSessionDelegate:self];
    
    self.activeNotes = [[NSMutableSet alloc] init];
    
    [self registerForUIApplicationNotifications];
    
}


- (void)dealloc
{
    [self unregisterForNotifications];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 
#pragma mark Note Control

- (void)startPlayingNote:(NSNumber *)note withVelocity:(double)velocity
{
    //TODO: Add configurable property to allow users to reactivate notes that are already playing
    
    if (![self.activeNotes containsObject:note]) {
        [self.activeNotes addObject:note];
        [self.sampler startPlayingNote:[note unsignedIntegerValue] withVelocity:velocity];
    }
}
- (void)stopPlayingNote:(NSNumber *)note
{
    if ([self.activeNotes containsObject:note]) {
        [self.activeNotes removeObject:note];
        [self.sampler stopPlayingNote:[note unsignedIntegerValue]];
    }
}
- (void)stopPlayingAllNotes
{
    for (NSNumber *num in self.activeNotes) {
        [self.sampler stopPlayingNote:[num unsignedIntegerValue]];
    }
    [self.activeNotes removeAllObjects];
}


#pragma mark -
#pragma mark Audio session delegate

// Respond to an audio interruption, such as a phone call or a Clock alarm.
- (void) beginInterruption
{
    
    // Stop any notes that are currently playing.
    [self stopPlayingAllNotes];
    
    // Interruptions do not put an AUGraph object into a "stopped" state, so
    //    do that here.
    [self.sampler stopAudioProcessingGraph];
}


// Respond to the ending of an audio interruption.
- (void) endInterruptionWithFlags: (NSUInteger) flags
{
    
    NSError *endInterruptionError = nil;
    [[AVAudioSession sharedInstance] setActive: YES
                                         error: &endInterruptionError];
    if (endInterruptionError != nil) {
        
        NSLog (@"Unable to reactivate the audio session.");
        return;
    }
    
    if (flags & AVAudioSessionInterruptionFlags_ShouldResume) {
        
        
        //         In a shipping application, check here to see if the hardware sample rate changed from
        //         its previous value by comparing it to graphSampleRate. If it did change, reconfigure
        //         the ioInputStreamFormat struct to use the new sample rate, and set the new stream
        //         format on the two audio units. (On the mixer, you just need to change the sample rate).
        //
        //         Then call AUGraphUpdate on the graph before starting it.
        
        
        [self.sampler restartAudioProcessingGraph];
    }
}


#pragma mark - Application state management

// The audio processing graph should not run when the screen is locked or when the app has
//  transitioned to the background, because there can be no user interaction in those states.
//  (Leaving the graph running with the screen locked wastes a significant amount of energy.)
//
// Responding to these UIApplication notifications allows this class to stop and restart the
//    graph as appropriate.
- (void)registerForUIApplicationNotifications
{
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter addObserver: self
                           selector: @selector (handleResigningActive:)
                               name: UIApplicationWillResignActiveNotification
                             object: [UIApplication sharedApplication]];
    
    [notificationCenter addObserver: self
                           selector: @selector (handleBecomingActive:)
                               name: UIApplicationDidBecomeActiveNotification
                             object: [UIApplication sharedApplication]];
}


- (void)unregisterForNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                              forKeyPath:UIApplicationDidBecomeActiveNotification];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                              forKeyPath:UIApplicationWillResignActiveNotification];
    
}


- (void)handleResigningActive: (id) notification
{
    
    [self stopPlayingAllNotes];
    
    [self.sampler stopAudioProcessingGraph];
}


- (void)handleBecomingActive: (id) notification
{
    
    [self.sampler restartAudioProcessingGraph];
}

@end
