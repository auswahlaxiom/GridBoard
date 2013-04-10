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

//this is 
@property int octaveJump;

@end

@implementation GridBrain

@synthesize scale = _scale, key = _key, rows = _rows, chord = _chord, chordInKey = _chordInKey, rowInterval = _rowInterval, rowInKey = _rowInKey, baseRow = _baseRow, startOctave = _startOctave, numRows = _numRows, octaveJump = _octaveJump;


-(id)init{
    if(self = [super init]) {
        //Default scale is Major
        _scale = [NSArray arrayWithObjects:[NSNumber numberWithInt:1],
                    [NSNumber numberWithInt:2], [NSNumber numberWithInt:2],
                    [NSNumber numberWithInt:1], [NSNumber numberWithInt:2],
                    [NSNumber numberWithInt:2], [NSNumber numberWithInt:2],
                    nil];
        //Default key is C
        _key = [NSNumber numberWithInt:0];
        
        //Default chord is the base note
        _chord = [NSArray arrayWithObjects:[NSNumber numberWithInt:0],[NSNumber numberWithInt:2],[NSNumber numberWithInt:2],
                  nil];
        //Chords will be forced to stay in key by default
        _chordInKey = [NSNumber numberWithBool:YES];
        
        //Default row interval is an octave
        _rowInterval = [NSNumber numberWithInt:3];
        //Rows stay in key by default
        _rowInKey = [NSNumber numberWithBool:YES];
        
        //Default starting row is 2 octaves below C0
        _startOctave = [NSNumber numberWithInt:3];
        //Default number of rows to display is 6
        _numRows = [NSNumber numberWithInt:6];
        
        //Set octave jump
        _octaveJump = 0;
        for(NSNumber *num in _scale) {
            _octaveJump += [num intValue];
        }
        
        //Set up base row:
        _baseRow = [self baseRowAdjustedForOctave:YES];
        
        [self rebuildRows];
    }
    return self;
}

-(void)setKey:(NSNumber *)key {
    int root = [key intValue];
    if(root > 11) {
        //normalize root to the lowest midi octave
        root = root % 12;
    }
    
    _key = [NSNumber numberWithInt:root];

    self.baseRow = [self baseRowAdjustedForOctave:YES];
    [self rebuildRows];
}

-(NSArray *)baseRowAdjustedForOctave: (bool)adjustOctave {
    NSMutableArray *mutableRow = [[NSMutableArray alloc] initWithCapacity:self.scale.count];
    
    //seed the previous note with the normalized root note of key
    int prevNote = [self.key intValue] % 12;
    //adjust if necessary
    if(adjustOctave) {
        
        prevNote += self.octaveJump * [self.startOctave intValue];
    }

    [mutableRow addObject:[NSNumber numberWithInt:prevNote]];
    for(int i = 1; i < self.scale.count; i++) {
        prevNote += [[self.scale objectAtIndex:i] intValue];
        [mutableRow addObject:[NSNumber numberWithInt:prevNote]];
    }

    int firstNote = [[mutableRow objectAtIndex:0] intValue];
    [mutableRow addObject:[NSNumber numberWithInt:(self.octaveJump + firstNote)]];
    return [mutableRow copy];
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
    self.rows = [[NSMutableArray alloc] initWithCapacity:([self.numRows intValue])];
    //initialize with base row first
    [self.rows addObject:self.baseRow];
    

    NSMutableArray *notes = [[NSMutableArray alloc] initWithCapacity:self.scale.count];
    for(int row = 1; row < [self.numRows intValue]; row++) {
        if([self.rowInKey boolValue]) {
            NSArray *prevRow = [self.rows objectAtIndex:(row-1)];

            for(int i = 0; i < self.scale.count; i++) {
                //grab the note from the row below;
                int base = [[prevRow objectAtIndex:i] intValue];
                //Begin tracking how large the offset will be
                int offset = 0; 
                //The offsets start one over from the note below. Each row moves the note over by the row interval
                int offsetIndex = (i+1 + (row-1) * [self.rowInterval intValue]) % self.scale.count;
                for(int j = 0; j < [self.rowInterval intValue]; j++) {
                    offset += [[self.scale objectAtIndex:offsetIndex] intValue];
                    offsetIndex = (offsetIndex + 1) % self.scale.count;
                }
                [notes addObject:[NSNumber numberWithInt:(base + offset)]];
            }
            //Add the final note in the "octave", which is the first note in the row and the total offset of the scale
            int firstNote = [[notes objectAtIndex:0] intValue];
            [notes addObject:[NSNumber numberWithInt:(self.octaveJump + firstNote)]];
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
    if(y >= self.rows.count || x > self.scale.count) return nil;
    
    NSMutableArray *notes = [[NSMutableArray alloc] init];
    
    int base = [[[self.rows objectAtIndex:y] objectAtIndex:x] intValue];
    [notes addObject:[NSNumber numberWithInt:base]];
    if(self.chord.count > 1) {
        if([self.chordInKey boolValue]) {
            NSArray *row = [self.rows objectAtIndex:y];
            //determine the number of octaves up the base note is
            int octavesUp = 0;
            //get index of where we are in scale
            int scaleIndex = [row indexOfObject:[NSNumber numberWithInt:base]];
            //add notes
            for(int i = 1; i < self.chord.count; i++) {
                scaleIndex = (scaleIndex + [[self.chord objectAtIndex:i] intValue]);
                if(scaleIndex > (row.count-1)) {
                    octavesUp++;
                    scaleIndex = (scaleIndex + 1) % row.count;
                }
                [notes addObject:[NSNumber numberWithInt:([[row objectAtIndex:scaleIndex] intValue] + octavesUp * self.octaveJump) ]];
            }
            
            
            //old version that didn't work quite right
            /*
            int scaleIndex = [self.baseRow indexOfObject:[NSNumber numberWithInt:normalizedBase]] + 1;
            for(int i = 1; i < self.chord.count; i++) {
                for(int j = 0; j < [[self.chord objectAtIndex:i] intValue]; j++) {
                    base += [[self.scale objectAtIndex:(scaleIndex + j) % self.scale.count] intValue];
                }
                [notes addObject:[NSNumber numberWithInt:base]];
                scaleIndex = (scaleIndex + [[self.chord objectAtIndex:i] intValue]) % self.scale.count;
            }
             */
            
            //this version binds it to the row, which isn't always the scale
            /*
            //add notes
            int scaleIndex = x;
            int rowIndex = y;
            NSArray *row = [self.rows objectAtIndex:rowIndex];
            for(int i = 1; i < self.chord.count; i++) {
                scaleIndex = (scaleIndex + [[self.chord objectAtIndex:i] intValue]);
                if(scaleIndex > (row.count-1)) {
                    rowIndex++;
                    row = [self.rows objectAtIndex:rowIndex];
                    scaleIndex = (scaleIndex + 1) % row.count;
                }
                [notes addObject:[NSNumber numberWithInt:([[row objectAtIndex:scaleIndex] intValue]) ]];
            }
             */
        } else {
            for(int i = 1; i < self.chord.count; i++) {
                base += [[self.chord objectAtIndex:i] intValue];
                [notes addObject:[NSNumber numberWithInt:base]];
            }
        }
    }
    return notes;
}

-(NSArray *)gridLocationOfNote:(int) note {
    int x, y;
    NSMutableArray *locs = [[NSMutableArray alloc] init];
    for(y = 0; y < self.rows.count; y++) {
        for(x = 0; x <= self.scale.count; x++) {
            if([[[self.rows objectAtIndex:y] objectAtIndex:x] intValue] == note) {
                [locs addObject:[NSValue valueWithCGPoint: CGPointMake(x, y)]];
            }
        }
    }
    return locs;
}

@end
