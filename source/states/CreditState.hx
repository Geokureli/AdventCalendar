package states;

import flixel.FlxSprite;
import flixel.FlxG;
import sprites.Credits;
import flixel.FlxState;

class CreditState extends FlxState
{
    override function create()
    {
        super.create();
        
        var credits = new Credits();
        add(credits);
        credits.start(51);
        
        FlxG.sound.music.stop();
        FlxG.sound.play("assets/music/creditSong.mp3");
        
        var bottom = new FlxSprite();
    }
}