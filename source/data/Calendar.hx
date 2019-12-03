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
    static public var data(default, null):ReadOnlyArray<ContentData>;
    static public var today(get, never):ContentData;
    static public var openedPres(default, null) = new BitArray();
    
    inline static function get_today() return data[day];
    
    static public function init(onComplete:Void->Void = null):Void
    {
        Assets.loadText("assets/data/content.json").onComplete(onContentLoad.bind(_, onComplete));
    }
    
    static function onDateReceived(date:Date):Void
    {
        isDecember = date.getMonth() == 11;
        
        if (date.getDate() < 26 && isDecember && date.getFullYear() == 2019)
        {
            isAdvent = true;
            day = date.getDate() - 1;
        }
    }
    
    static function onContentLoad(fileData:String, callback:Void->Void = null):Void
    {
        data = Json.parse(fileData);
        
        function initSaveAndEnd()
        {
            FlxG.save.bind("advent2019", "GeoKureli");
            if (FlxG.save.data.openedPres != null && Std.is(FlxG.save.data.openedPres, Int))
            {
                openedPres = FlxG.save.data.openedPres;
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
}

typedef RawContentData =
{
	final author   :String;
    final credit   :Null<String>;
	final fileExt  :Null<String>;
    final medal    :Int;
	final pos      :{ x:Int, y:Int }
	final frames   :Null<Int>;
	final tv       :Null<String>;
}

@:forward
abstract ContentData(RawContentData) from RawContentData
{
    public var credit(get, never):String;
    inline function get_credit() return this.credit != null ? this.credit : this.author;
    
    public var profileLink(get,never):String;
    inline function get_profileLink() return "https://" + this.author + ".newgrounds.com";
    
    inline public function getPath():String
    {
        return 'assets/images/artwork/${getFilename()}';
    }
    
   inline public function getThumbPath():String
    {
        return 'assets/images/thumbs/thumb-${getFilename()}';
    }
    
    inline public function getFilename():String
    {
        return this.author.toLowerCase() + "." + (this.fileExt == null ? "png" : this.fileExt);
    }
    
}