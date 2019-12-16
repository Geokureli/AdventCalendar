package data;

import flixel.FlxG;

class DrumKit
{
static var sounds:Array<DrumPiece> = 
[ snare     // E
, clap      // 4
, tom       // R
, hat       // 5
, bongo_1   // T
, bongo_3   // Y
, bongo_2   // 7
, kick      // U
, bells     // 8
, tambourine// I
, triangle  // 9
, stick     // O
, crash     // P
];
    
    static var piecesFound:BitArray = new BitArray();
    
    static public function setInitial():Void
    {
        piecesFound = FlxG.save.data.piecesFound;
    }
    
    static public function getSoundName(index:Int):Null<String>
    {
        // if (piecesFound[index])
            return sounds[index];
        // return null;
    }
}

enum abstract DrumPiece(String) to String
{
    var snare;     // E
    var clap;      // 4
    var tom;       // R
    var hat;       // 5
    var bongo_1;   // T
    var bongo_2;   // Y
    var bongo_3;   // 7
    var kick;      // U
    var bells;     // 8
    var tambourine;// I
    var triangle;  // 9
    var stick;     // O
    var crash;     // P
}