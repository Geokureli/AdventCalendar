package data;

import flixel.FlxG;

class DrumKit
{
static var sounds:Array<String> = 
    [ "snare"     // E
    , "clap"      // 4
    , "tom"       // R
    , "hat"       // 5
    , "bongo_1"   // T
    , "bongo_3"   // Y
    , "bongo_2"   // 7
    , "kick"      // U
    , "bells"     // 8
    , "tambourine"// I
    , "triangle"  // 9
    , "stick"     // O
    , "crash"     // P
    ];
static var soundToPiece:Map<String, DrumPiece> = 
    [ "snare"     => snare
    , "clap"      => clap
    , "tom"       => tom
    , "hat"       => hat
    , "bongo_1"   => bongo
    , "bongo_3"   => bongo
    , "bongo_2"   => bongo
    , "kick"      => kick
    , "bells"     => bells
    , "tambourine"=> tambourine
    , "triangle"  => triangle
    // , "stick"     => null
    , "crash"     => crash
    ];



static var pieces:Array<DrumPiece> = 
    [ snare
    , clap
    , tom
    , hat
    , bongo
    , kick
    , bells
    , tambourine
    , triangle
    , crash
    ];
    
    static var piecesFound:BitArray = new BitArray();
    
    static public function setInitial():Void
    {
        piecesFound = FlxG.save.data.piecesFound;
    }
    
    static public function getSoundName(index:Int):Null<String>
    {
        var soundName = sounds[index];
        var msg = 'name: $soundName';
        if (soundToPiece.exists(soundName))
            msg += '[exists] piece:${soundToPiece[soundName]}'
                + 'index:${pieces.indexOf(soundToPiece[soundName])} '
                + piecesFound.toString();
        trace(msg);
        if (!soundToPiece.exists(soundName) || isPieceFound(soundToPiece[soundName]))
            return soundName;
        return null;
    }
    
    inline static public function isPieceFound(piece:DrumPiece):Bool
    {
        return piecesFound[pieces.indexOf(piece)];
    }
    
    inline static public function isAnyPieceFound():Bool
    {
        return (piecesFound:Int) > 0;
    }
    
    static public function pickUpPiece(piece:DrumPiece):Void
    {
        var index = pieces.indexOf(piece);
        if (index == -1)
            throw 'Invalid DrumPiece: $piece';
        
        piecesFound[index] = true;
        FlxG.save.data.piecesFound = (piecesFound:Int);
        FlxG.save.flush();
    }
}

enum abstract DrumPiece(String) to String
{
    var snare;
    var clap;
    var tom;
    var hat;
    var bongo;
    var kick;
    var bells;
    var tambourine;
    var triangle;
    var crash;
}