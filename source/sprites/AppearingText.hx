package sprites;

import sprites.Font;

import flixel.graphics.frames.FlxBitmapFont;
import flixel.text.FlxBitmapText;
import flixel.tweens.FlxTween;

@:forward
abstract AppearingText(FlxBitmapText) to FlxBitmapText
{
    inline public function new 
        ( msg:String
        , x = 0.0
        , y = 0.0
        , font:FlxBitmapFont = null
        )
    {
        this = new FlxBitmapText(font == null ? new NokiaFont() : font);
        this.x = x;
        this.y = y;
        this.text = msg;
    }
    
    public function appear(appearTime = 1.0, holdTime = 0.25, ?onComplete:()->Void)
    {
        final msg = this.text;
        this.text = " ";
        final length = msg.length;
        final callback = onComplete == null ? null : (_)->onComplete();
        FlxTween.num(0, (holdTime + appearTime) / appearTime, (holdTime + appearTime),
            { onComplete: callback },
            (n)->this.text = StringTools.rtrim(msg.substr(0, Math.floor((n > 1 ? 1 : n) * length)))
        );
    }
}