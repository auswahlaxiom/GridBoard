//
//  GridViewController.m
//  GridBoard
//
//  Created by Zachary Fleischman on 4/1/13.
//  Copyright (c) 2013 Zachary Fleischman. All rights reserved.
//

#import "GridViewController.h"
#import "GridConfigViewController.h"

//For debug from sample code
#import <AssertMacros.h>

// some MIDI constants:
enum {
	kMIDIMessage_NoteOn    = 0x9,
	kMIDIMessage_NoteOff   = 0x8,
};

@interface GridViewController ()
//Keep track of what notes are active, converted to points and passed to view for coloring
@property (strong, nonatomic)NSMutableArray *activeNotes;

//audio junk
@property (readwrite) Float64   graphSampleRate;
@property (readwrite) AUGraph   processingGraph;
@property (readwrite) AudioUnit samplerUnit;
@property (readwrite) AudioUnit ioUnit;

- (OSStatus)    loadSynthFromPresetURL:(NSURL *) presetURL;
- (void)        registerForUIApplicationNotifications;
- (BOOL)        createAUGraph;
- (void)        configureAndStartAudioProcessingGraph: (AUGraph) graph;
- (void)        stopAudioProcessingGraph;
- (void)        restartAudioProcessingGraph;
@end

@implementation GridViewController

@synthesize brain = _brain;
@synthesize gridView = _gridView;
@synthesize activeNotes = _activeNotes;

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString: @"Config"]) {
        GridConfigViewController *dest = (GridConfigViewController *)segue.destinationViewController;
        dest.brain = self.brain;
        dest.gridView = self.gridView;
    }
}


#pragma mark Note Control
-(void)notesOn:(NSArray *)notes {
    [self.activeNotes addObjectsFromArray:notes];
    NSMutableArray *gridActive = [self.gridView.activeNotes mutableCopy];
    
    for(NSNumber *note in notes) {
        for(NSValue *pointVal in [self.brain gridLocationOfNote:[note intValue]]) {
            [gridActive addObject:pointVal];
        }

        //ACTIVATE THE MIDI NOTE
        UInt32 noteNum = [note intValue];
        UInt32 onVelocity = 127;
        UInt32 noteCommand = 	kMIDIMessage_NoteOn << 4 | 0;
        
        OSStatus result = noErr;
        require_noerr (result = MusicDeviceMIDIEvent (self.samplerUnit, noteCommand, noteNum, onVelocity, 0), logTheError);
        
    logTheError:
        if (result != noErr) NSLog (@"Unable to start playing note %li. Error code: %d '%.4s'\n", noteNum, (int) result, (const char *)&result);
    }
    self.gridView.activeNotes = gridActive;
}
-(void)notesOff:(NSArray *)notes {
    [self.activeNotes addObjectsFromArray:notes];
    NSMutableArray *gridActive = [self.gridView.activeNotes mutableCopy];

    for(NSNumber *note in notes) {
        [self.activeNotes removeObject:note];
        for(NSValue *pointVal in [self.brain gridLocationOfNote:[note intValue]]) {
            [gridActive removeObject:pointVal];
        }
        //DEACTIVATE THE MIDI NOTE
        UInt32 noteNum = [note intValue];
        UInt32 noteCommand = 	kMIDIMessage_NoteOff << 4 | 0;
        
        OSStatus result = noErr;
        require_noerr (result = MusicDeviceMIDIEvent (self.samplerUnit, noteCommand, noteNum, 0, 0), logTheError);
        
    logTheError:
        if (result != noErr) NSLog (@"Unable to stop playing note %li. Error code: %d '%.4s'\n", noteNum, (int) result, (const char *)&result);
    }
    self.gridView.activeNotes = gridActive;
}

#pragma mark Touch Events
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    for(UITouch *touch in touches) {
        CGPoint gridLoc = [self gridLocationOfTouch:touch];
        [self notesOn:[self.brain notesForTouchAtXValue:(int)gridLoc.x YValue:(int)gridLoc.y]];
    }
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    for(UITouch *touch in touches) {
        CGPoint gridLoc = [self gridLocationOfTouch:touch];
        NSArray *newNotes = [self.brain notesForTouchAtXValue:(int)gridLoc.x YValue:(int)gridLoc.y];
        NSMutableArray *notesToTurnOn = [[NSMutableArray alloc] init];
        NSMutableArray *notesToTurnOff = [[NSMutableArray alloc] init];
        
        for(NSNumber *activeNote in self.activeNotes) {
            if(![newNotes containsObject:activeNote]){
                [notesToTurnOff addObject:activeNote];
            }
        }
        for(NSNumber *newNote in newNotes) {
            if(![self.activeNotes containsObject:newNote]) {
                [notesToTurnOn addObject:newNote];
            }
        }

        [self notesOn:notesToTurnOn];
        [self notesOff:notesToTurnOff];
    }
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    for(UITouch *touch in touches) {
        CGPoint gridLoc = [self gridLocationOfTouch:touch];
        [self notesOff:[self.brain notesForTouchAtXValue:(int)gridLoc.x YValue:(int)gridLoc.y]];
    }
}
-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    //same as touches ended?
    [self touchesEnded:touches withEvent:event];
}
-(CGPoint)gridLocationOfTouch:(UITouch *)touch {
    CGFloat height = self.gridView.bounds.size.height;
    CGFloat width = self.gridView.bounds.size.width;
    CGFloat vInterval = height / (float) self.gridView.rows;
    CGFloat hInterval = width / (float) self.gridView.columns;
    
    int xLoc = [touch locationInView:self.gridView].x / hInterval;
    int yLoc = self.gridView.rows - [touch locationInView:self.gridView].y / vInterval;
    return CGPointMake(xLoc, yLoc);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    //Only Landscape
    return ((interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (interfaceOrientation == UIInterfaceOrientationLandscapeRight));
}

#pragma mark GridDataSource
- (NSString *)stringForCellAtXValue:(int) x YValue:(int) y {
    NSArray *notes = [self.brain notesForRow:(y)];
    int note = [[notes objectAtIndex:x] intValue];
    return [GridBrain nameForMidiNote:note showOctave:YES];
}

#pragma mark -
#pragma mark Audio setup


// Create an audio processing graph.
- (BOOL) createAUGraph {
    
	OSStatus result = noErr;
	AUNode samplerNode, ioNode;
    
    // Specify the common portion of an audio unit's identify, used for both audio units
    // in the graph.
	AudioComponentDescription cd = {};
	cd.componentManufacturer     = kAudioUnitManufacturer_Apple;
	cd.componentFlags            = 0;
	cd.componentFlagsMask        = 0;
    
    // Instantiate an audio processing graph
	result = NewAUGraph (&_processingGraph);
    NSCAssert (result == noErr, @"Unable to create an AUGraph object. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
	//Specify the Sampler unit, to be used as the first node of the graph
	cd.componentType = kAudioUnitType_MusicDevice;
	cd.componentSubType = kAudioUnitSubType_Sampler;
	
    // Add the Sampler unit node to the graph
	result = AUGraphAddNode (self.processingGraph, &cd, &samplerNode);
    NSCAssert (result == noErr, @"Unable to add the Sampler unit to the audio processing graph. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
	// Specify the Output unit, to be used as the second and final node of the graph
	cd.componentType = kAudioUnitType_Output;
	cd.componentSubType = kAudioUnitSubType_RemoteIO;
    
    // Add the Output unit node to the graph
	result = AUGraphAddNode (self.processingGraph, &cd, &ioNode);
    NSCAssert (result == noErr, @"Unable to add the Output unit to the audio processing graph. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    // Open the graph
	result = AUGraphOpen (self.processingGraph);
    NSCAssert (result == noErr, @"Unable to open the audio processing graph. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    // Connect the Sampler unit to the output unit
	result = AUGraphConnectNodeInput (self.processingGraph, samplerNode, 0, ioNode, 0);
    NSCAssert (result == noErr, @"Unable to interconnect the nodes in the audio processing graph. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
	// Obtain a reference to the Sampler unit from its node
	result = AUGraphNodeInfo (self.processingGraph, samplerNode, 0, &_samplerUnit);
    NSCAssert (result == noErr, @"Unable to obtain a reference to the Sampler unit. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
	// Obtain a reference to the I/O unit from its node
	result = AUGraphNodeInfo (self.processingGraph, ioNode, 0, &_ioUnit);
    NSCAssert (result == noErr, @"Unable to obtain a reference to the I/O unit. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    return YES;
}


// Starting with instantiated audio processing graph, configure its
// audio units, initialize it, and start it.
- (void) configureAndStartAudioProcessingGraph: (AUGraph) graph {
    
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

#pragma mark Load AUPreset Functions
- (IBAction)loadPianoPreset:(id)sender {
    
	NSURL *presetURL = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Piano" ofType:@"aupreset"]];
	if (presetURL) {
		NSLog(@"Attempting to load preset '%@'\n", [presetURL description]);
	}
	else {
		NSLog(@"COULD NOT GET PRESET PATH!");
	}
    
	[self loadSynthFromPresetURL: presetURL];
}
- (IBAction)loadVibraphonePreset:(id)sender {
    
	NSURL *presetURL = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Vibraphone" ofType:@"aupreset"]];
	if (presetURL) {
		NSLog(@"Attempting to load preset '%@'\n", [presetURL description]);
	}
	else {
		NSLog(@"COULD NOT GET PRESET PATH!");
	}
    
	[self loadSynthFromPresetURL: presetURL];
}

// Load a synthesizer preset file and apply it to the Sampler unit
- (OSStatus) loadSynthFromPresetURL: (NSURL *) presetURL {
    
	CFDataRef propertyResourceData = 0;
	Boolean status;
	SInt32 errorCode = 0;
	OSStatus result = noErr;
	
	// Read from the URL and convert into a CFData chunk
	status = CFURLCreateDataAndPropertiesFromResource (
                                                       kCFAllocatorDefault,
                                                       (__bridge CFURLRef) presetURL,
                                                       &propertyResourceData,
                                                       NULL,
                                                       NULL,
                                                       &errorCode
                                                       );
    
    NSAssert (status == YES && propertyResourceData != 0, @"Unable to create data and properties from a preset. Error code: %d '%.4s'", (int) errorCode, (const char *)&errorCode);
   	
	// Convert the data object into a property list
	CFPropertyListRef presetPropertyList = 0;
	CFPropertyListFormat dataFormat = 0;
	CFErrorRef errorRef = 0;
	presetPropertyList = CFPropertyListCreateWithData (
                                                       kCFAllocatorDefault,
                                                       propertyResourceData,
                                                       kCFPropertyListImmutable,
                                                       &dataFormat,
                                                       &errorRef
                                                       );
    
    // Set the class info property for the Sampler unit using the property list as the value.
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
    
    if (errorRef) CFRelease(errorRef);
	CFRelease (propertyResourceData);
    
	return result;
}


// Set up the audio session for this app.
- (BOOL) setupAudioSession {
    
    AVAudioSession *mySession = [AVAudioSession sharedInstance];
    
    // Specify that this object is the delegate of the audio session, so that
    //    this object's endInterruption method will be invoked when needed.
    [mySession setDelegate: self];
    
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

//AUGraph control
// Stop the audio processing graph
- (void) stopAudioProcessingGraph {
    
    OSStatus result = noErr;
	if (self.processingGraph) result = AUGraphStop(self.processingGraph);
    NSAssert (result == noErr, @"Unable to stop the audio processing graph. Error code: %d '%.4s'", (int) result, (const char *)&result);
}

// Restart the audio processing graph
- (void) restartAudioProcessingGraph {
    
    OSStatus result = noErr;
	if (self.processingGraph) result = AUGraphStart (self.processingGraph);
    NSAssert (result == noErr, @"Unable to restart the audio processing graph. Error code: %d '%.4s'", (int) result, (const char *)&result);
}
#pragma mark -
#pragma mark Audio session delegate methods

// Respond to an audio interruption, such as a phone call or a Clock alarm.
- (void) beginInterruption {
    
    // Stop any notes that are currently playing.
    [self notesOff:self.activeNotes];
    
    // Interruptions do not put an AUGraph object into a "stopped" state, so
    //    do that here.
    [self stopAudioProcessingGraph];
}


// Respond to the ending of an audio interruption.
- (void) endInterruptionWithFlags: (NSUInteger) flags {
    
    NSError *endInterruptionError = nil;
    [[AVAudioSession sharedInstance] setActive: YES
                                         error: &endInterruptionError];
    if (endInterruptionError != nil) {
        
        NSLog (@"Unable to reactivate the audio session.");
        return;
    }
    
    if (flags & AVAudioSessionInterruptionFlags_ShouldResume) {
        
        /*
         In a shipping application, check here to see if the hardware sample rate changed from
         its previous value by comparing it to graphSampleRate. If it did change, reconfigure
         the ioInputStreamFormat struct to use the new sample rate, and set the new stream
         format on the two audio units. (On the mixer, you just need to change the sample rate).
         
         Then call AUGraphUpdate on the graph before starting it.
         */
        
        [self restartAudioProcessingGraph];
    }
}


#pragma mark - Application state management

// The audio processing graph should not run when the screen is locked or when the app has
//  transitioned to the background, because there can be no user interaction in those states.
//  (Leaving the graph running with the screen locked wastes a significant amount of energy.)
//
// Responding to these UIApplication notifications allows this class to stop and restart the
//    graph as appropriate.
- (void) registerForUIApplicationNotifications {
    
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


- (void) handleResigningActive: (id) notification {
    
    [self notesOff:self.activeNotes];

    [self stopAudioProcessingGraph];
}


- (void) handleBecomingActive: (id) notification {
    
    [self restartAudioProcessingGraph];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	self.brain = [[GridBrain alloc] init];
    self.gridView.rows = [self.brain.numRows intValue];
    self.gridView.columns = (self.brain.scale.count + 1);
    self.gridView.dataSource = self;
    self.activeNotes = [[NSMutableArray alloc] init];
    
    //Audio stuff:
    [self loadVibraphonePreset:self];
    [self initializeAudioSession];
    
    [self registerForUIApplicationNotifications];

}

- (id) initWithNibName: (NSString *) nibNameOrNil bundle: (NSBundle *) nibBundleOrNil {
    
    self = [super initWithNibName: nibNameOrNil bundle: nibBundleOrNil];
    
    // If object initialization fails, return immediately.
    if (!self) {
        return nil;
    }
    
    [self initializeAudioSession];
    
    return self;
}

-(void)initializeAudioSession {
    // Set up the audio session for this app, in the process obtaining the
    // hardware sample rate for use in the audio processing graph.
    BOOL audioSessionActivated = [self setupAudioSession];
    NSAssert (audioSessionActivated == YES, @"Unable to set up audio session.");
    
    // Create the audio processing graph; place references to the graph and to the Sampler unit
    // into the processingGraph and samplerUnit instance variables.
    [self createAUGraph];
    [self configureAndStartAudioProcessingGraph: self.processingGraph];
}


@end
