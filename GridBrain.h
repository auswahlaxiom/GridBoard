//
//  GridBrain.h
//  GridBoard
//
//  Created by Zachary Fleischman on 4/1/13.
//  Copyright (c) 2013 Zachary Fleischman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GridBrain : NSObject

/* Array of NSNumbers specifying the scale
 * The first number should number of halfsteps the first note is from the last note.
 * Subsequent numbers specify the number of MIDI notes (half steps) each note is from the
 * previous. (e.g. Major: {1,2,2,1,2,2,2})
 */
@property (strong, nonatomic)NSArray *scale;

/* MIDI note number referring to where the scale will begin.
 * Will be normalized to the lowest possible number corresponding to that note.
 */
@property (strong, nonatomic)NSNumber *key;

/* Array of NSNumbers specifying if a note should be played as a chord
 * Behavior for !chordInKey (not default behavior)
 * The first number should always be zero, meaning the first note of the chord is the note
 * touched by the user. Subsequent numbers specify half steps from the previous note.
 * (e.g. Major chord: {0,4,3}, No chord: {0}, Octave: {0,12})
 */
@property (strong, nonatomic)NSArray *chord;

/* Boolean Value
 * True means chords will be in key, meaning instead of the number of halfsteps from the
 * previous, the numbers now specify the number of notes in the scale from the previous.
 * (e.g. Major chord: {0,2,2}, Octave: {0,8})
 */
@property (strong, nonatomic)NSNumber *chordInKey;

/* Row interval specifies how many halfsteps higher each note is from the one below it.
 * Behavior for !rowInKey (not default behavior)
 * (e.g. Octave: 12, meaning the note above C0 would be C1)
 */
@property (strong, nonatomic)NSNumber *rowInterval;

/* Boolean value
 * True means the row inteval specifies the number of notes in the key each note is from
 * the note below it.
 * (e.g. Octave: 8, Perfect 3rd: 3, meaning the note above C0 would be F0)
 */
@property (strong, nonatomic)NSNumber *rowInKey;

/* Specifies the row at which the grid starts, 0 is lowest
 */
@property (strong, nonatomic)NSNumber *startRow;

/* Specifies number of rows to display
 */
@property (strong, nonatomic)NSNumber *numRows;

//Returns the name of a MIDI note.
+(NSString *)nameForMidiNote:(int) note showOctave:(bool) octave;

//Array of NSNumbers representing the MIDI notes that should be activated for a given grid position
// x is the column, y is the row. (0,0) is the lower left most grid location
-(NSArray *)notesForTouchAtXValue:(int) x YValue:(int) y;

//find where in the grid a note is
-(NSArray *)gridLocationOfNote:(int) note;

//Array of NSNumbers representing the MIDI notes at the given row
// The lowest row is row 0, row numbers increment up by 1.
-(NSArray *)notesForRow:(int) row;

@end
