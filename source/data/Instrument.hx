package data;

import flixel.FlxG;

class Instrument
{
    inline static var PATH = "assets/sounds/";
    
    static var majorScale:Array<Int> = [0,2,4,5,7,9,11,12];
    static var minorScale:Array<Int> = [0,2,3,5,7,8,10,12];
    static var notes = 
    [ "6a", "6aS", "6b", "6c", "6cS", "6d", "6dS", "6e", "6f", "6fS", "6g", "6gS"
    , "7a", "7aS", "7b", "7c", "7cS", "7d", "7dS", "7e", "7f", "7fS", "7g", "7gS"
    ];
    static public var type(default, set):Null<InstrumentType> = null;
    static public var key(default, set):Key;
    static var soundPath:String;
    static var root:Int;
    static var scale:Array<Int>;
    
    static public function play(note:Int):Void
    {
        FlxG.sound.play(soundPath + '${notes[root + note]}.mp3');
    }
    
    inline static function set_type(value:InstrumentType)
    {
        soundPath = switch (value)
        {
            case null:"";
            case Glockenspiel: PATH + "glockenspiel/";
        }
        return Instrument.type = value;
    }
    
    inline static function set_key(value:Key):Key
    {
        var note:String;
        switch(value)
        {
            case Major(n):
                note = n;
                scale = majorScale;
            case Minor(n):
                note = n;
                scale = minorScale;
        }
        
        switch (note)
        {
            case "a"|"aS"|"b"|"c"|"cS"|"d"|"dS"|"e"|"f"|"fS"|"g"|"gS":
                root = notes.indexOf("6" + note);
            default:
                throw "invalid key";
        }
        return Instrument.key = key;
    }
    
    inline static public function setKeyFromString(key:String):Void
    {
        Instrument.key = getKeyFromString(key);
    }
    
    inline static public function getKeyFromString(key:String):Key
    {
        return switch(key.substr(-3))
        {
            case "Maj": Major(key.substr(0, -3));
            case "Min": Minor(key.substr(0, -3));
            case _: throw "unhandled key: " + key;
        }
    }
    
    inline static public function getKeyString():String
    {
        return keyToString(key);
    }
    
    inline static public function keyToString(key:Key):String
    {
        return switch(key)
        {
            case Major(note): note + "Maj";
            case Minor(note): note + "Min";
        }
    }
    
    static public function setInititial():Void
    {
        if (Calendar.hasGlock)
            type = Glockenspiel;
        
        setKeyFromString(Calendar.today.song.key);
    }
}

enum Key
{
    Major(note:String);
    Minor(note:String);
}

enum InstrumentType
{
    Glockenspiel;
}