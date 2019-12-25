package states;

import flixel.util.FlxTimer;
import sprites.Snow;
import flixel.system.FlxSound;
import flixel.util.FlxSort;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;

import sprites.Credits;

class CreditState extends FlxState
{
    inline static var SPEED = 15;
    inline static var ACCEL_TIME = 2.0;
    
    var middles = new FlxTypedGroup<FlxSprite>();
    var credits:Credits;
    var curSpeed = 0.0;
    var totalElapsed = 0.0;
    var sound:FlxSound;
    var top:FlxSprite;
    var finished = false;
    
    override function create()
    {
        super.create();
        
        FlxG.sound.music.stop();
        sound = FlxG.sound.play("assets/music/creditSong.mp3");
        
        var bottom = new FlxSprite("assets/images/props/heaven/tree_bottom.png");
        bottom.y = FlxG.height - bottom.height;
        add(bottom);
        
        add(middles);
        var middle = new FlxSprite("assets/images/props/heaven/tree_tile.png");
        middles.add(middle);
        middle.y = bottom.y - middle.height;
        middle.x = bottom.x + (bottom.width - middle.width) / 2;
        
        var i = Math.ceil(FlxG.height / middle.height);
        var y = middle.y;
        while (i-- > 0)
        {
            middles.add(middle = new FlxSprite("assets/images/props/heaven/tree_tile.png"));
            y = middle.y = y - middle.height;
            middle.x = middles.members[0].x;
        }
        
        add(top = new FlxSprite("assets/images/props/heaven/tree_topper.png"));
        top.x = bottom.x + (bottom.width - top.width) / 2;
        top.visible = false;
        
        add(credits = new Credits());
        add(new Snow());
    }
    
    override function update(elapsed:Float)
    {
        super.update(elapsed);
        
        final duration = sound.length / 1000;
        elapsed = (sound.time / 1000) - totalElapsed;
        totalElapsed = sound.time / 1000;
        if (totalElapsed > duration || totalElapsed == 0)
        {
            if (!finished)
                new FlxTimer().start(5.0, (_)->{ FlxG.switchState(new HeavenState()); });
            return;
        }
        
        credits.updateCrawl(totalElapsed, duration);
        
        FlxG.camera.scroll.y -= curSpeed * elapsed;
        if (totalElapsed > duration - ACCEL_TIME)
        {
            if (curSpeed > 0)
                curSpeed -= SPEED / ACCEL_TIME * elapsed;
        }
        else if (curSpeed < SPEED)
            curSpeed += SPEED / ACCEL_TIME * elapsed;
        
        var bottomPiece = middles.members[0];
        var topPiece = middles.members[middles.members.length - 1];
        if (bottomPiece.y > FlxG.camera.scroll.y + FlxG.camera.height && !top.visible)
        {
            bottomPiece.y = topPiece.y - bottomPiece.height;
            middles.members.push(middles.members.shift());
            if (totalElapsed > duration - 15)
            {
                top.visible = true;
                topPiece = middles.members[middles.members.length - 1];
                top.y = topPiece.y - top.height + 12;
            }
        }
    }
}