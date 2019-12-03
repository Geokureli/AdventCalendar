package sprites;

import flixel.tweens.FlxTween;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

class TvBubble extends FlxSpriteGroup
{
    inline static var APPEAR_TIME = 1.0;
    inline static var HOLD_TIME = 2.0;
    inline static var TOTAL_TIME = APPEAR_TIME + HOLD_TIME;
    
    public var msg:String;
    var text(get, never):FlxText;
    inline function get_text():FlxText return cast members[1];
    public function new (msg:String = null)
    {
        super(14, 26);
        
        this.msg = msg;
        var bubble = new Sprite(0, 0, "assets/images/props/cabin/tv_bubble.png");
        add(bubble);
        
        var text = new FlxText(2, -2, bubble.width - 3, "");
        @:privateAccess
        text._defaultFormat.leading = -1;
        text.color = 0xFFf02935;
        visible = false;
        add(text);
    }
    
    public function play():Void
    {
        if (visible == false)
        {
            visible = true;
            text.text = "";
            FlxTween.num(0, TOTAL_TIME / APPEAR_TIME, TOTAL_TIME, { onComplete: (_)->{ visible = false; } }, showPercent);
        }
    }
    
    public function showPercent(n:Float)
    {
        
        text.text = msg.substr(0, Math.floor((n > 1 ? 1 : n) * msg.length));
    }
}