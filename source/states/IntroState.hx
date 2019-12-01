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
        
		NGio.login(onConnectResult);
		Calendar.init();
        
        new FlxTimer().start(20, showError);
    }
    
    function onConnectResult():Void
    {
        if (NGio.isLoggedIn)
            FlxG.switchState(new CabinState());
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