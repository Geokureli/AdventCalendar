package data;

import flixel.system.FlxSound;
import flixel.FlxG;
import flixel.util.FlxSignal;

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
    static public var onTypeChange = new FlxTypedSignal<(Null<InstrumentType>)->Void>();
    static var soundPath:String;
    static var root:Int;
    static var scale:Array<Int>;
    static var sustain:Float;
    static var singleNoteMode:Bool;
    static var activeNote:Null<FlxSound> = null;
    static var owned:Array<InstrumentType> = [];
    
    static public function press(note:Int):Void
    {
        if (singleNoteMode)
            release(note);
        
        var sound = FlxG.sound.play(soundPath + '${notes[root + note]}.mp3', 0.5);
        if (sustain >= 0)
            sound.fadeOut(sustain);
        if (singleNoteMode)
            activeNote = sound;
    }
    
    static function release(note:Int):Void
    {
        if (activeNote != null)
            activeNote.fadeOut(0.01);
    }
    
    static public function update(elapsed):Void
    {
        trace("update");
    }
    
    inline static function set_type(value:Null<InstrumentType>)
    {
        switch (value)
        {
            case null:"";
            case Glockenspiel: 
                soundPath = PATH + "glockenspiel/";
                sustain = -1;
                singleNoteMode = false;
            case Flute:
                soundPath = PATH + "flute/";
                sustain = 1.0;
                singleNoteMode = true;
        }
        
        if (Instrument.type != value)
        {
            if (FlxG.save.data.instrument != value.getIndex())
            {
                FlxG.save.data.instrument = value.getIndex();
                FlxG.save.flush();
            }
            Instrument.type = value;
            onTypeChange.dispatch(value);
        }
        
        return value;
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
    
    static public function setInitial():Void
    {
        if (FlxG.save.data.hasGlock)
            owned.push(Glockenspiel);
        
        if (FlxG.save.data.hasFlute)
            owned.push(Flute);
        
        if (FlxG.save.data.instrument != null)
            type = InstrumentType.createByIndex(FlxG.save.data.instrument);
        else if (FlxG.save.data.hasGlock)
            type = Glockenspiel;
        
        setKeyFromString(Calendar.today.song.key);
    }
    
    static public function addGlockenspiel()
    {
        owned.push(Glockenspiel);
        FlxG.save.data.hasGlock = true;
        FlxG.save.flush();
        type = Glockenspiel;
    }
    
    static public function addFlute()
    {
        owned.push(Flute);
        FlxG.save.data.hasFlute = true;
        FlxG.save.flush();
        type = Flute;
    }
    
    static public function owns(type:InstrumentType)
    {
        return owned.indexOf(type) != -1;
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
    Flute;
}