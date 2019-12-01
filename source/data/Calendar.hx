package data;

import haxe.Json;
import haxe.ds.ReadOnlyArray;
import openfl.utils.Assets;

class Calendar
{
    inline static var DEBUG_DAY:Null<Int>
        = 0;
        // = null;
    static public var day(default, null) = 25;
    static public var isAdvent(default, null) = false;
    static public var isDecember(default, null) = false;
    static public var data(default, null):ReadOnlyArray<ContentData>;
    
    static public function init(onComplete:Void->Void = null):Void
    {
        Assets.loadText("assets/data/content.json").onComplete(onLoad.bind(_, onComplete));
        if (DEBUG_DAY == null)
            NGio.checkNgDate(()->{ onDateReceived(NGio.ngDate); });
        else
        {
            day = DEBUG_DAY;
            isAdvent = true;
        }
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
    
    static function onLoad(fileData:String, callback:Void->Void = null):Void
    {
        data = Json.parse(fileData);
        if (callback != null)
            callback();
    }
    
    static public function getData(day:Int):Null<ContentData>
    {
        if (isAdvent && data.length > day)
            return data[day];
        return null;
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