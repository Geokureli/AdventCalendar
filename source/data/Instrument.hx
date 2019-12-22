package data;

import flixel.FlxG;
import flixel.system.FlxSound;
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
    static var owned:Array<InstrumentType> = [];
    static var soundPath:String;
    static var root:Int;
    static var scale:Array<Int>;
    static var sustainMode:Bool;
    static var singleNoteMode:Bool;
    static var volume:Float;
    static var currentNote:Null<Int> = null;
    static var activeNotes:Array<FlxSound> = [];
    
    static public function setInitial():Void
    {
        DrumKit.setInitial();
        if (FlxG.save.data.hasGlock)
            owned.push(Glockenspiel);
        
        if (FlxG.save.data.hasFlute)
            owned.push(Flute);
        
        if (FlxG.save.data.hasDrums)
            owned.push(Drums);
        
        if (FlxG.save.data.hasPiano)
            owned.push(Piano);
        
        if (FlxG.save.data.instrument != null)
            type = InstrumentType.createByIndex(FlxG.save.data.instrument);
        else if (FlxG.save.data.hasGlock)
            type = Glockenspiel;
        
        setKeyFromString(Calendar.today.song.key);
    }
    
    static public function press(note:Int):Void
    {
        if (singleNoteMode && currentNote != note && activeNotes[currentNote] != null)
        {
            var sound = activeNotes[currentNote];
            sound.fadeOut(0.1, 0, (_)->sound.kill());
        }
        
        currentNote = note;
        
        var soundName = switch (type)
        {
            case Drums: DrumKit.getSoundName(note);
            default: notes[root + note];
        }
        
        if (soundName != null)
            activeNotes[note] = FlxG.sound.play(soundPath + soundName + '.mp3', volume);
    }
    
    static public function release(note:Int):Void
    {
        if (activeNotes[note] != null)
        {
            final sound = activeNotes[note];
            activeNotes[note] = null;
            
            if (singleNoteMode && note == currentNote)
            {
                currentNote = null;
                var lastPressed = getLastPressed();
                if (lastPressed != -1)
                    press(lastPressed);
            }
            
            if (sustainMode && sound != null)
                sound.fadeOut(0.1, 0, (_)->sound.kill());
        }
    }
    
    inline static function getLastPressed():Int
    {
        var lastPressed = -1;
        for (i in 0...activeNotes.length)
        {
            if (activeNotes[i] != null && (lastPressed == -1 || activeNotes[i].time < activeNotes[lastPressed].time))
                lastPressed = i;
        }
        return lastPressed;
    }
    
    inline static function set_type(value:Null<InstrumentType>)
    {
        sustainMode = false;
        singleNoteMode = false;
        volume = 0.5;
        switch (value)
        {
            case null:"";
            case Glockenspiel: 
                soundPath = PATH + "glockenspiel/";
            case Flute:
                soundPath = PATH + "flute/";
                sustainMode = true;
                singleNoteMode = true;
            case Drums:
                soundPath = PATH + "drums/";
                volume = 1.0;
            case Piano:
                soundPath = PATH + "piano/";
                // sustainMode = true;
                volume = 1.0;
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
    
    static public function add(type:InstrumentType)
    {
        owned.push(type);
        switch(type)
        {
            case Glockenspiel: FlxG.save.data.hasGlock = true;
            case Flute: FlxG.save.data.hasFlute = true;
            case Drums: FlxG.save.data.hasDrums = true;
            case Piano: FlxG.save.data.hasPiano = true;
        }
        FlxG.save.flush();
        Instrument.type = type;
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
    Drums;
    Piano;
}