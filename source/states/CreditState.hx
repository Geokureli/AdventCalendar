package states;

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
        
        FlxG.sound.music.stop();
        FlxG.sound.play("assets/music/Lennon_is_dead_hurray.mp3");
    }
}