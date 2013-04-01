//
//  GridBrain.m
//  GridBoard
//
//  Created by Zachary Fleischman on 4/1/13.
//  Copyright (c) 2013 Zachary Fleischman. All rights reserved.
//

#import "GridBrain.h"

@interface GridBrain ()

@property (strong, nonatomic) NSArray *baseRow;

/* Array of arrays with each sub array representing the MIDI notes of the row it corresponds to
 */
@property (strong, nonatomic)NSMutableArray *rows;

@end

@implementation GridBrain

@synthesize key = _key, rows = _rows, chord = _chord, chordInKey = _chordInKey, rowInterval = _rowInterval, rowInKey = _rowInKey, baseRow = _baseRow, startRow = _startRow, numRows = _numRows;


-(id)init{
    if(self = [super init]) {
        //Default key is C Major
        _key = [NSArray arrayWithObjects:[NSNumber numberWithInt:0],
                    [NSNumber numberWithInt:2], [NSNumber numberWithInt:2],
                    [NSNumber numberWithInt:1], [NSNumber numberWithInt:2],
                    [NSNumber numberWithInt:2], [NSNumber numberWithInt:2],
                    [NSNumber numberWithInt:1], nil];
        //Default chord is the base note
        _chord = [NSArray arrayWithObject:[NSNumber numberWithInt:0]];
        //Chords will be forced to stay in key by default
        _chordInKey = [NSNumber numberWithBool:YES];
        //Default row interval is an octave
        _rowInterval = [NSNumber numberWithInt:3];
        //Rows stay in key by default
        _rowInKey = [NSNumber numberWithBool:YES];
        //Default starting row is 2 octaves below C0
        _startRow = [NSNumber numberWithInt:4];
        //Default number of rows to display is 6
        _numRows = [NSNumber numberWithInt:6];
        
        //Set up base row:
        NSMutableArray *mutableRow = [[NSMutableArray alloc] initWithCapacity:_key.count];
        int prevNote = [[_key objectAtIndex:0] intValue];
        [mutableRow addObject:[NSNumber numberWithInt:prevNote]];
        for(int i = 1; i < _key.count; i++) {
            prevNote += [[_key objectAtIndex:i] intValue];
            [mutableRow addObject:[NSNumber numberWithInt:prevNote]];
        }
        _baseRow = [mutableRow copy];
        
        [self rebuildRows];
    }
    return self;
}

-(void)setKey:(NSArray *)key {
    int root = [[key objectAtIndex:0] intValue];
    if(root > 11) {
        //normalize root to the lowest midi octave
        root = root % 12;
        NSMutableArray *normKey = [key mutableCopy];
        [normKey replaceObjectAtIndex:0 withObject:[NSNumber numberWithInt:root]];
        _key = [normKey copy];
    } else {
        _key = key;
    }
    [self resetBaseRow];
}

-(void)resetBaseRow {
    NSMutableArray *mutableRow = [[NSMutableArray alloc] initWithCapacity:self.key.count];
    int prevNote = [[self.key objectAtIndex:0] intValue];
    [mutableRow addObject:[NSNumber numberWithInt:prevNote]];
    for(int i = 1; i < self.key.count; i++) {
        prevNote += [[self.key objectAtIndex:i] intValue];
        [mutableRow addObject:[NSNumber numberWithInt:prevNote]];
    }
    self.baseRow = [mutableRow copy];
}

+(NSDictionary *)midiNotes {
    static NSDictionary *midiNotes = nil;
    if(!midiNotes) {
        NSArray *notes = [NSArray arrayWithObjects:@"C", @"C#", @"D", @"D#",
                          @"E", @"F", @"F#", @"G", @"G#", @"A", @"A#", @"B", nil];
        NSArray *midiKeys = [NSArray arrayWithObjects:[NSNumber numberWithInt:0],
                             [NSNumber numberWithInt:1], [NSNumber numberWithInt:2],
                             [NSNumber numberWithInt:3], [NSNumber numberWithInt:4],
                             [NSNumber numberWithInt:5], [NSNumber numberWithInt:6],
                             [NSNumber numberWithInt:7], [NSNumber numberWithInt:8],
                             [NSNumber numberWithInt:9], [NSNumber numberWithInt:10],
                             [NSNumber numberWithInt:11], nil];
        midiNotes = [NSDictionary dictionaryWithObjects:notes forKeys:midiKeys];
    }
    return midiNotes;
}

+(NSString *)nameForMidiNote:(int) note showOctave:(bool) octave {
    NSString *noteName = [[GridBrain midiNotes] objectForKey:[NSNumber numberWithInt:(note % 12)]];
    if(octave) {
        int midiOctave = -5; //notes 0 thru 11 are in the -5th octave as defined by MIDI
        midiOctave += note / 12;
        noteName = [noteName stringByAppendingString:[NSString stringWithFormat:@" %i", midiOctave]];
    }
    return noteName;
}

-(void)rebuildRows {
    self.rows = [[NSMutableArray alloc] initWithCapacity:([self.startRow intValue] + [self.numRows intValue])];
    //initialize with base row first
    [self.rows addObject:self.baseRow];
    
    NSMutableArray *notes = [[NSMutableArray alloc] initWithCapacity:self.key.count];
    for(int row = 1; row < [self.startRow intValue] + [self.numRows intValue]; row++) {
        if([self.rowInKey boolValue]) {
            NSArray *prevRow = [self.rows objectAtIndex:(row-1)];
            NSLog([prevRow description]);
            for(int i = 0; i < self.key.count; i++) {
                //grab the note from the row below;
                int base = [[prevRow objectAtIndex:i] intValue];
                int offset = 0; int offsetIndex = (i+1) % self.key.count;
                for(int j = 0; j < [self.rowInterval intValue]; j++) {
                    offset += [[self.key objectAtIndex:offsetIndex] intValue];
                    offsetIndex = (offsetIndex + 1) % self.key.count;
                }
                [notes addObject:[NSNumber numberWithInt:(base + offset)]];
            }
        } else {
            for(NSNumber *note in self.baseRow) {
                int noteWithOffset = [note intValue] + [self.rowInterval intValue] * row;
                [notes addObject:[NSNumber numberWithInt:noteWithOffset]];
            }
        }
        [self.rows addObject:[notes copy]];
        [notes removeAllObjects];
    }
}

-(NSArray *)notesForRow:(int)row {
    return [[self.rows objectAtIndex:row] copy];
}

-(NSArray *)notesForTouchAtXValue:(int)x YValue:(int)y {
    if(x > self.key.count || y > [self.startRow intValue] + [self.numRows intValue]) return nil;
    
    NSMutableArray *notes = [[NSMutableArray alloc] init];
    
    int base = [[[self.rows objectAtIndex:x] objectAtIndex:y] intValue];
    [notes addObject:[NSNumber numberWithInt:base]];
    if(self.chord.count > 1) {
        if([self.chordInKey boolValue]) {
            int offsetIndex = 0;
            for(int i = 1; i < self.chord.count; i++) {
                offsetIndex = (offsetIndex + [[self.chord objectAtIndex:i] intValue]) % self.key.count;
                base += [[self.key objectAtIndex:offsetIndex] intValue];
                
                [notes addObject:[NSNumber numberWithInt:base]];
            }
        } else {
            for(int i = 1; i < self.chord.count; i++) {
                base += [[self.chord objectAtIndex:i] intValue];
                [notes addObject:[NSNumber numberWithInt:base]];
            }
        }
    }
    return notes;
}

@end
