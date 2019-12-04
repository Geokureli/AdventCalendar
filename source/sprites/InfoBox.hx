package sprites;

import flixel.math.FlxMath;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxBitmapText;
import flixel.text.FlxText;

class InfoBox extends FlxSpriteGroup
{
    inline static var BUFFER = 2;
    inline static var BOB_DIS = 4;
    inline static var BOB_PERIOD = 2.0;
    
    public var callback:Null<Void->Void>;
    public var timer = 0.0;
    
    public function new (?text:String, ?callback:Void->Void, x = 0.0, y = 0.0, border = 1)
    {
        super();
        this.callback = callback;
        
        this.x = x;
        this.y = y;
        if (text != null)
        {
            var info = new FlxBitmapText();
            info.autoSize = true;
            info.text = text;
            info.setBorderStyle(OUTLINE, FlxColor.BLACK, 1);
            // info.scale.set(0.5, 0.5);
            // info.updateHitbox();
            info.x -= info.width / 2;
            add(info);
        }
        
        alpha = 0;
        alive = false;
    }
    
    override function update(elapsed:Float)
    {
        super.update(elapsed);
        
        offset.y = Math.round(FlxMath.fastCos(timer / BOB_PERIOD * Math.PI) * BOB_DIS);
        timer += elapsed;
        
        if (alive && alpha < 1)
            alpha += elapsed;
        else if (!alive && alpha > 0)
            alpha -= elapsed;
    }
    
    public function interact():Void
    {
        if (callback != null)
            callback();
    }
}