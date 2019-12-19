package sprites;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.text.FlxBitmapText;
import flixel.tweens.FlxTween;

import states.OgmoState;
import sprites.Font;

@:noCompletion
typedef OgmoValues =
{
    sorting:Sorting
}

interface ISortable { var sorting:Sorting; }

class TvBubble extends FlxSpriteGroup
    implements IOgmoEntity<OgmoValues>
    implements ISortable
{
    inline static var APPEAR_TIME = 1.0;
    inline static var HOLD_TIME = 2.0;
    inline static var TOTAL_TIME = APPEAR_TIME + HOLD_TIME;
    
    public var msg:String;
    var text(get, never):FlxBitmapText;
    inline function get_text():FlxBitmapText return cast members[1];
    public var sorting:Sorting;
    
    public function new (msg:String = "MESSAGE MISING")
    {
        super(14, 26);
        
        this.msg = msg;
        var bubble = new Sprite(0, 0, "assets/images/props/cabin/tv_bubble.png");
        add(bubble);
        
        var text = new FlxBitmapText(new NokiaFont());
        text.x = 1;
        text.y = 2;
        text.width = bubble.width - 3;
        text.text = "";
        text.color = 0xFFf02935;
        visible = false;
        add(text);
    }
    
    public function ogmoInit(data:OgmoEntityData<OgmoValues>, parent:OgmoEntityLayer)
    {
        x = data.x;
        y = data.y;
        sorting = data.values.sorting;
    }
    
    public function play():Void
    {
        if (visible == false)
        {
            visible = true;
            FlxTween.num(0, TOTAL_TIME / APPEAR_TIME, TOTAL_TIME,
                { onComplete: (_)->
                    {
                        visible = false;
                        text.text = " ";//"" doesn't work for some reason
                    }
                },
                (n:Float)->
                    text.text = StringTools.rtrim(msg.substr(0, Math.floor((n > 1 ? 1 : n) * msg.length)))
            );
        }
    }
}

enum abstract Sorting(String)
{
    var Top;
    var Y;
    var Bottom;
    var None;
}