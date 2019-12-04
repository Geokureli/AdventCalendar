package sprites;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.text.FlxBitmapText;
import flixel.tweens.FlxTween;

class TvBubble extends FlxSpriteGroup
{
    inline static var APPEAR_TIME = 1.0;
    inline static var HOLD_TIME = 2.0;
    inline static var TOTAL_TIME = APPEAR_TIME + HOLD_TIME;
    
    public var msg:String;
    var text(get, never):FlxBitmapText;
    inline function get_text():FlxBitmapText return cast members[1];
    public function new (msg:String = null)
    {
        super(14, 26);
        
        this.msg = msg;
        var bubble = new Sprite(0, 0, "assets/images/props/cabin/tv_bubble.png");
        add(bubble);
        
        var text = new FlxBitmapText(new Font());
        text.x = 2;
        text.y = 2;
        text.width = bubble.width - 3;
        text.text = "";
        text.color = 0xFFf02935;
        visible = false;
        add(text);
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

@:forward
abstract Font(FlxBitmapFont) to FlxBitmapFont
{
    static var instance:Font = null;
    public function new ()
    {
        if (instance == null)
        {
            var chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!#$%&*()-_+=[]',.|:?";
            
            var widths = 
            [
                6,6,6,6,6,6,6,6,3,5,7,5,8,7,7,6,7,6,5,7,6,7,8,7,7,6,	//UPPERCASE
                6,6,5,6,6,4,6,6,3,4,6,3,9,6,6,6,6,5,5,4,6,6,8,6,6,6,	//LOWERCASE
                6,4,6,6,6,6,6,6,6,6,									//DIGITS
                3,6,6,7,7,6,4,4,5,6,6,5,4,4,2,3,3,3,3,6					//SYMBOLS
            ];
            
            @:privateAccess
            instance = cast new FlxBitmapFont(FlxG.bitmap.add("assets/images/Nokia.png").imageFrame.frame);
            @:privateAccess
            instance.lineHeight = 9;
            instance.spaceWidth = 4;
            var frame:FlxRect;
            var x:Int = 0;
            for (i in 0...widths.length)
            {
                frame = FlxRect.get(x, 0, widths[i] - 1, instance.lineHeight);
                @:privateAccess
                instance.addCharFrame(chars.charCodeAt(i), frame, FlxPoint.weak(), widths[i]);
                x += widths[i];
            }
        }
        this = instance;
    }
}