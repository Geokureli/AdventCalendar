package states;

import flixel.util.FlxTimer;
import flixel.text.FlxText;
import data.Calendar;
import data.NGio;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxState;

class IntroState extends FlxState
{
    override public function create():Void
    {
        super.create();
        
        FlxG.camera.bgColor = FlxG.stage.color;
        var timer = new FlxTimer().start(20, showError);
        
        var callbacks = 2;
        function trigger() 
        {
            if (--callbacks == 0)
            {
                timer.cancel();
                onConnectResult();
            }
        }
        
        NGio.login(trigger);
        Calendar.init(trigger);
    }
    
    function onConnectResult():Void
    {
        if (NGio.isLoggedIn)
        {
            if (Calendar.isAdvent)
            {
                FlxG.sound.playMusic("assets/music/czyszy.mp3", 0);
                FlxG.sound.music.fadeIn(5, 0, 0.3);
            }
            // FlxG.switchState(new OutsideOgmoState());
            FlxG.switchState(new CabinState());
        }
        else
            showError();
    }
    
    function showError(_ = null)
    {
        var text = new FlxText("Could not connect to Newgrounds", 32);
        text.x = FlxG.width * 1.5;
        text.y = FlxG.height * 0.6;
        text.width = FlxG.width;
        text.alignment = CENTER;
        add(text);
    }
}