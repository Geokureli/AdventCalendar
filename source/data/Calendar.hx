package data;

import flixel.FlxG;
import haxe.Json;
import haxe.ds.ReadOnlyArray;
import openfl.utils.Assets;

class Calendar
{
    inline static var DEBUG_DAY:Int = 0;// 0 to disable debug feature
    static public var day(default, null) = 24;
    static public var isAdvent(default, null) = false;
    static public var isDecember(default, null) = false;
    static public var isChristmas(default, null) = false;
    static public var data(default, null):ReadOnlyArray<ContentData>;
    static public var today(get, never):ContentData;
    static public var openedPres(default, null) = new BitArray();
    static public var hasGlock(default, null) = false;
    
    inline static function get_today() return data[day];
    
    static public function init(callback:Void->Void = null):Void
    {
        data = Json.parse(Assets.getText("assets/data/content.json"));
        
        function initSaveAndEnd()
        {
            FlxG.save.bind("advent2019", "GeoKureli");
            if (FlxG.save.data.openedPres != null && Std.is(FlxG.save.data.openedPres, Int))
            {
                openedPres = FlxG.save.data.openedPres;
                hasGlock = FlxG.save.data.hasGlock;
                trace("loaded savefile: " + openedPres);
            }
            
            trace("day: " + day);
            if (callback != null)
                callback();
        }
        
        if (DEBUG_DAY == 0)
        {
            NGio.checkNgDate(()->{
                onDateReceived(NGio.ngDate);
                initSaveAndEnd();
            });
        }
        else
        {
            day = DEBUG_DAY - 1;
            isAdvent = true;
            isDecember = true;
            initSaveAndEnd();
        }
    }
    
    static function onDateReceived(date:Date):Void
    {
        isDecember = date.getMonth() == 11;
        isChristmas = date.getDate() == 25;
        
        if (date.getDate() < 26 && isDecember && date.getFullYear() == 2019)
        {
            isAdvent = true;
            day = date.getDate() - 1;
        }
    }
    
    static public function getData(day:Int):Null<ContentData>
    {
        if (isAdvent && data.length > day)
            return data[day];
        return null;
    }
    
    static public function saveOpenPresent(day:Int)
    {
        trace("saved: " + openedPres);
        openedPres[day] = true;
        FlxG.save.data.openedPres = (openedPres:Int);
        FlxG.save.flush();
    }
    
    static public function resetOpenedPresents()
    {
        openedPres.reset();
        FlxG.save.data.openedPres = 0;
        FlxG.save.flush();
    }
    
    static public function saveOpenGlock()
    {
        trace("pew pew");
        hasGlock = true;
        FlxG.save.data.hasGlock = hasGlock;
        FlxG.save.flush();
    }
}

typedef RawContentData =
{
	final author :String;
    final credit :Null<String>;
	final fileExt:Null<String>;
	final frames :Null<Int>;
	final tv     :Null<String>;
    final song   : { artist:String, ?id:Int }
}

@:forward
abstract ContentData(RawContentData) from RawContentData
{
    public var credit(get, never):String;
    inline function get_credit() return this.credit != null ? this.credit : this.author;
    
    public var profileLink(get,never):String;
    inline function get_profileLink() return "https://" + this.author + ".newgrounds.com";
    
    public var musicProfileLink(get,never):String;
    inline function get_musicProfileLink() return "https://" + this.song.artist + ".newgrounds.com";
    
    inline public function getArtPath():String
    {
        return 'assets/images/artwork/${getFilename()}';
    }
    
   inline public function getThumbPath():String
    {
        return 'assets/images/thumbs/thumb-${getFilename()}';
    }
    
   inline public function getSongPath():String
    {
        return 'assets/music/${this.song.artist.toLowerCase()}.mp3';
    }
    
    inline public function getFilename():String
    {
        return this.author.toLowerCase() + "." + (this.fileExt == null ? "png" : this.fileExt);
    }
    
}