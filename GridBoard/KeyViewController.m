//
//  KeyViewController.m
//  Keys
//
//  Created by Zach Fleischman on 5/14/13.
//  Copyright (c) 2013 Zach Fleischman. All rights reserved.
//

#import "KeyViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "KeyActiveIndicator.h"
#import "GridSampler.h"


@interface KeyViewController ()

@property (strong, nonatomic) NSMutableArray *activeIndicators;
@property (strong, nonatomic) NSMutableArray *whiteKeys;
@property (strong, nonatomic) NSMutableArray *blackKeys;
@property (strong, nonatomic) NSMutableArray *keyLabels;

@property (strong, nonatomic) GridSampler *sampler;

@property int firstNoteActive;
+ (UIImage *)imageFromColor:(UIColor *)color;
@property (weak) UIPopoverController *configPopover;

@end

@implementation KeyViewController


#pragma mark - Initializers

- (id)init
{
    self = [super init];
    if (self) {
        self.firstNoteActive = -1;
    }
    return self;
}


- (id)initWithWhiteWidth: (int) wWidth blackWidth: (int)bWidth whiteHeightProportion: (float)wHeight blackHeightProportion: (float)bHeight octaves: (int)octy activeNotes: (NSArray *)actives displayingNoteNames: (BOOL)names {
    self = [super init];
    if (self) {
        self.firstNoteActive = -1;
        
        self.whiteWidth = [NSNumber numberWithInt:wWidth];
        self.blackWidth = [NSNumber numberWithInt:bWidth];
        self.whiteHeightProportion = [NSNumber numberWithFloat:wHeight];
        self.blackHeightProportion = [NSNumber numberWithFloat:bHeight];
        self.octaves = [NSNumber numberWithInt:octy];
        self.displayNoteNames = [NSNumber numberWithBool:names];
        
        //sort of a hack but its less code in the end
        for(NSNumber *num in actives) {
            UIButton *derpy = [[UIButton alloc] init];
            derpy.tag = [num intValue];
            [self buttonPressed:derpy];
        }
        
    }
    return self;
}


#pragma mark This is the data the user actually cares about

- (NSArray *)activeNotes {
    if(self.firstNoteActive == -1) return nil;
    NSMutableArray *notes = [[NSMutableArray alloc] init];
    for(int i = 0; i < 128; i++) {
        KeyActiveIndicator* anIndicator = [self.activeIndicators objectAtIndex:i];
        if([anIndicator isActive]) {
            [notes addObject:anIndicator];
        }
    }
    
    return notes;
}


#pragma mark Getters with default values

- (NSMutableArray*)activeIndicators
{
    if(_activeIndicators == nil) {
        _activeIndicators = [[NSMutableArray alloc] initWithCapacity:127];
        for(int i = 0; i < 128; i++) {
            [_activeIndicators addObject:[[KeyActiveIndicator alloc] init]];
        }
    }
    return _activeIndicators;
}


- (NSNumber*)whiteWidth
{
    if(_whiteWidth == nil) self.whiteWidth = [NSNumber numberWithInt:50];
    return _whiteWidth;
}


- (NSNumber *)blackWidth
{
    if(_blackWidth == nil) self.blackWidth = [NSNumber numberWithInt:30];
    return _blackWidth;
}


- (NSNumber *)whiteHeightProportion
{
    if(_whiteHeightProportion == nil) self.whiteHeightProportion = [NSNumber numberWithFloat:1.0/3.0];
    return _whiteHeightProportion;
}


- (NSNumber *)blackHeightProportion
{
    if(_blackHeightProportion == nil) self.blackHeightProportion = [NSNumber numberWithFloat:2.0/3.0];
    return _blackHeightProportion;
}


- (NSNumber *)octaves
{
    if(_octaves == nil) self.octaves = [NSNumber numberWithInt:10];
    return _octaves;
}


- (NSNumber *)displayNoteNames
{
    if(_displayNoteNames == nil) self.displayNoteNames = [NSNumber numberWithBool:YES];
    return _displayNoteNames;
}


+ (UIImage *) imageFromColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}


#pragma mark Create the view!

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.whiteKeys = [[NSMutableArray alloc] init];
    self.blackKeys = [[NSMutableArray alloc] init];
    self.keyLabels = [[NSMutableArray alloc] init];
    
    //music!!!
    NSURL *aupURL = [[NSBundle mainBundle] URLForResource:@"Trombone" withExtension:@"aupreset"];
    self.sampler = [[GridSampler alloc] initWithPresetURL:aupURL audioSessionDelegate:self];
    
    
    // TODO: get soundfonts working
    /* 
    NSURL *sfURL = [[NSBundle mainBundle] URLForResource:@"Gorts_Filters" withExtension:@"SF2"];
    [self.sampler loadFromDLSOrSoundFont:sfURL withPatch:(int)10];
     */
    
    
    int octaves = 10; //create the maximum possible number of octaves first

    int asciiForA = 65;
	

    //initialize whites
    int midiOffset = 0;
    int octave = 0;
    for(int i = 0; i < octaves * 7; i++) {
        
        UIButton *key = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [key setBackgroundImage:[KeyViewController imageFromColor:[UIColor colorWithWhite:0.4 alpha:1.0]]
                       forState:UIControlStateHighlighted];
        int midiNote = midiOffset + octave * 12;
        key.tag = midiNote;
        key.layer.cornerRadius = 8.0;
        key.layer.masksToBounds = YES;
        key.layer.borderColor = [UIColor lightGrayColor].CGColor;
        key.layer.borderWidth = 1;
        
        [key    addTarget:self
                   action:@selector(buttonReleased:)
         forControlEvents:UIControlEventTouchUpInside];
        [key    addTarget:self
                   action:@selector(buttonPressed:)
         forControlEvents:UIControlEventTouchDown];
       
        [self.keyScrollView addSubview:key];
        [self.whiteKeys addObject:key];

        
        KeyActiveIndicator *activeIndicator = [[KeyActiveIndicator alloc] init];
        activeIndicator.note = midiNote;
        [self.keyScrollView addSubview:activeIndicator];
        [self.activeIndicators replaceObjectAtIndex:midiNote withObject:activeIndicator];
        
        if([self.displayNoteNames boolValue]) {
            int note = (asciiForA + (i+2) % 7);
            UILabel *label = [[UILabel alloc] init];
            label.text = [NSString stringWithFormat:@"%c %i", note, octave-2];
            [label setBackgroundColor:[UIColor clearColor]];
            [label setTextAlignment:NSTextAlignmentCenter];
            [label setAdjustsFontSizeToFitWidth:YES];
            
            [self.keyScrollView addSubview:label];
            [self.keyLabels addObject:label];
        }
        
        midiOffset += 2;
        if(midiOffset == 6) midiOffset = 5;
        if(midiOffset ==13) {midiOffset = 0;octave++;}

    }
    
    //initialize blacks
    midiOffset = 1;
    octave = 0;
    for(int i = 0; i < octaves; i++) {
        int position = 0;

        for(int j = 0; j < 5; j++) {
            UIButton *key = [UIButton buttonWithType:UIButtonTypeCustom];
            [key setBackgroundImage:[KeyViewController imageFromColor:[UIColor lightGrayColor]]
                              forState:UIControlStateNormal];
            [key setBackgroundImage:[KeyViewController imageFromColor:[UIColor colorWithWhite:0.4 alpha:1.0]]
                           forState:UIControlStateHighlighted];
            key.layer.cornerRadius = 8.0;
            key.layer.masksToBounds = YES;
            key.layer.borderColor = [UIColor lightGrayColor].CGColor;
            key.layer.borderWidth = 1;
            
            int midiNote = midiOffset + octave * 12;
            key.tag = midiNote;
            
            [key    addTarget:self
                       action:@selector(buttonReleased:)
             forControlEvents:UIControlEventTouchUpInside];
            [key    addTarget:self
                       action:@selector(buttonPressed:)
             forControlEvents:UIControlEventTouchDown];
            
            [self.keyScrollView addSubview:key];
            [self.blackKeys addObject:key];
            
            KeyActiveIndicator *activeIndicator = [[KeyActiveIndicator alloc] init];
            activeIndicator.note = midiNote;
            [self.keyScrollView addSubview:activeIndicator];
            
            //move
            [self.activeIndicators replaceObjectAtIndex:midiNote withObject:activeIndicator];
            
            position++;
            midiOffset += 2;
            if(position == 2) {position = 3; midiOffset++;}
            
        }
        midiOffset = 1;
        octave++;
    }
    
    //set up keys to display
    [self resizeKeys];
}


- (void)resizeKeys
{
    //questionable
    CGFloat height = self.view.frame.size.height;
    NSLog(@"height: %f", height);
    
    CGFloat whiteWidth = [self.whiteWidth floatValue];
    CGFloat whiteHeight = height * [self.whiteHeightProportion floatValue];
    
    CGFloat blackWidth = [self.blackWidth floatValue];
    CGFloat blackHeight = whiteHeight * [self.blackHeightProportion floatValue];
    
    int octaves = [self.octaves intValue];
    
    [self.keyScrollView setContentSize:CGSizeMake(octaves * 7 * whiteWidth, height)];
    
    //white keys, indicators, and labels
    for(int i = 0; i < octaves * 7; i++) {
        UIButton *whiteKey = [self.whiteKeys objectAtIndex:i];
        [whiteKey setFrame:CGRectMake(i*whiteWidth, 0, whiteWidth, whiteHeight)];
        [whiteKey setHidden:NO];
        
        KeyActiveIndicator *activeIndicator = [self.activeIndicators objectAtIndex:whiteKey.tag];
        [activeIndicator setFrame:CGRectMake(whiteWidth*i+5, whiteHeight - whiteWidth, whiteWidth - 10, whiteWidth - 10)];
        [activeIndicator setNeedsDisplay];
        [activeIndicator setHidden:NO];
        
        UILabel *label = [self.keyLabels objectAtIndex:i];
        if([self.displayNoteNames boolValue]) {
            [label setFrame:CGRectMake(whiteWidth*i+5, whiteHeight - (whiteWidth + 30) / 2, whiteWidth-10, 20)];
            [label setHidden:NO];
        } else {
            [label setHidden:YES];
        }
    }
    
    //black keys, indicators
    int blackIndex = 0;
    for(int i = 0; i < octaves; i++) {
        int offset = i * whiteWidth * 7;
        int position = 0;
        
        for(int j = 0; j < 5; j++) {
            UIButton *blackKey = [self.blackKeys objectAtIndex:blackIndex];
            [blackKey setHidden:NO];
            blackIndex++;
            [blackKey setFrame:CGRectMake(whiteWidth * position + whiteWidth*2/3 + offset, 0, blackWidth, blackHeight)];
            
            KeyActiveIndicator *activeIndicator = [self.activeIndicators objectAtIndex:blackKey.tag];
            [activeIndicator setFrame:CGRectMake(whiteWidth * position + whiteWidth*2/3 + offset+2.5, blackHeight - blackWidth, blackWidth - 5, blackWidth - 5)];
            [activeIndicator setNeedsDisplay];
            [activeIndicator setHidden:NO];
            
            position++;
            if(position == 2) {position = 3;}
        }
    }
    
    //hide keys not in use
    for(int i = octaves * 7; i < self.whiteKeys.count; i++) {
        UIButton *whiteKey = [self.whiteKeys objectAtIndex:i];
        [whiteKey setHidden:YES];
        KeyActiveIndicator *activeIndicator = [self.activeIndicators objectAtIndex:whiteKey.tag];
        [activeIndicator setHidden:YES];
        
        UILabel *label = [self.keyLabels objectAtIndex:i];
        [label setHidden:YES];
    }
    for(int i = blackIndex; i < self.blackKeys.count; i++) {
        UIButton *blackKey = [self.blackKeys objectAtIndex:i];
        [blackKey setHidden:YES];
        KeyActiveIndicator *activeIndicator = [self.activeIndicators objectAtIndex:blackKey.tag];
        [activeIndicator setHidden:YES];
    }
    
}


#pragma mark Helper method

- (void)buttonReleased:(UIButton *)sender
{
    KeyActiveIndicator *indi = [self.activeIndicators objectAtIndex:sender.tag];
    indi.isActive = !indi.isActive;
    if(self.firstNoteActive == -1) {
        indi.isFirst = true;
        self.firstNoteActive = indi.note;
    } else {
        self.firstNoteActive = -1;
        for(int i = 0; i < 128; i++) {
            KeyActiveIndicator* anIndicator = [self.activeIndicators objectAtIndex:i];
            if([anIndicator isActive] && self.firstNoteActive == -1) {
                [anIndicator setIsFirst:true];
                self.firstNoteActive = anIndicator.note;
            } else {
                [anIndicator setIsFirst:false];
            }
        }
    }
    [self.sampler stopPlayingNote:sender.tag];

}


- (void)buttonPressed:(UIButton *)sender
{
    [self.sampler startPlayingNote:sender.tag withVelocity:0.7];

}


-(void)updateWithProperties:(NSDictionary *)properties
{
    if([properties objectForKey:@"whiteWidth"] != nil)
        self.whiteWidth = [properties objectForKey:@"whiteWidth"];
    if([properties objectForKey:@"blackWidth"] != nil)
        self.blackWidth = [properties objectForKey:@"blackWidth"];
    if([properties objectForKey:@"whiteHeight"] != nil)
        self.whiteHeightProportion = [properties objectForKey:@"whiteHeight"];
    if([properties objectForKey:@"blackHeight"] != nil)
        self.blackHeightProportion = [properties objectForKey:@"blackHeight"];
    if([properties objectForKey:@"octaves"])
        self.octaves = [properties objectForKey:@"octaves"];
    if([properties objectForKey:@"names"]) 
        self.displayNoteNames = [properties objectForKey:@"names"];
    
    
    
    [self resizeKeys];
}


- (IBAction)displayConfig:(id)sender
{
    if(self.configPopover)
        [self.configPopover dismissPopoverAnimated:YES];
    else
        [self performSegueWithIdentifier:@"Show Config" sender:sender];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"Show Config"]) {
        self.configPopover = [(UIStoryboardPopoverSegue *)segue popoverController];
        self.configger = segue.destinationViewController;
        self.configger.delegate = self;
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self resizeKeys];
}
#pragma mark -
#pragma mark Audio session delegate

// Respond to an audio interruption, such as a phone call or a Clock alarm.
- (void) beginInterruption
{
    
    // Stop any notes that are currently playing.
    for(NSNumber *num in self.activeNotes) {
        [self.sampler stopPlayingNote:[num integerValue]];
    }
    
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


@end
