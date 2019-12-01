package sprites;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

class TvBubble extends FlxSpriteGroup
{
    public function new (msgWidth = 120)
    {
        super(14, 26);
        
        add(new Sprite(0, 0, "assets/images/props/cabin/tv_bubble.png"));
        
        var msg = new FlxSprite(2, 2);
        msg.loadGraphic("assets/images/props/cabin/tv_message_0.png", true, msgWidth);
        var frames = [for (i in 0...msg.animation.frames) i];
        for (i in 0...16)
            frames.push(msg.animation.frames - 1);
        trace(frames, frames.length);
        msg.animation.add("anim", frames, 12, false);
        msg.animation.play("anim", msg.animation.frames - 1);
        visible = false;
        add(msg);
    }
    
    public function play():Void
    {
        var msg:FlxSprite = cast members[1];
        if (msg.animation.finished)
        {
            visible = true;
            msg.animation.play("anim");
        }
    }
    
    override function update(elapsed:Float)
    {
        super.update(elapsed);
        
        var msg:FlxSprite = cast members[1];
        if (msg.animation.finished)
            visible = false;
    }
}