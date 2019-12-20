package states;

import data.Calendar;
import data.NGio;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.ui.FlxSpriteButton;
import flixel.util.FlxColor;
import flixel.input.gamepad.FlxGamepad;

/**
 * ...
 * @author pfft no one owns me
 */
class AlienSubstate extends FlxSubState 
{	
	private var chimney:FlxSprite;

	override public function create():Void 
	{
		var blackShit:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		blackShit.scrollFactor.set();
		blackShit.screenCenter();
		add(blackShit);

		trace('alien ayyy');
		var bg:FlxSprite = new FlxSprite().loadGraphic("assets/images/minigame/night.png");
		bg.scrollFactor.set();
		bg.setGraphicSize(0, FlxG.height);
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

		chimney = new FlxSprite(0, FlxG.height - 20).loadGraphic("assets/images/minigame/chimney.png");
		chimney.scrollFactor.set();
		chimney.screenCenter(X);
		add(chimney);

		chimney.drag.x = 20;

		super.create();
	}

	function spawnAliens():Void
	{
		
	}
	
	override public function update(elapsed:Float):Void 
	{
		keyboardControls();
		super.update(elapsed);
	}
	
	
	private function keyboardControls():Void
	{		
		if (FlxG.keys.anyJustPressed(["ESCAPE", "SPACE"]))
			close();
		
		// REPLACE THESE TO BE CLEANER LATER AND WITH MORE KEYS
		if (FlxG.keys.pressed.D)
		{
			chimney.velocity.x = 10;
		}
		if (FlxG.keys.pressed.W)
		{
			
		}	
		if (FlxG.keys.pressed.A)
		{
			chimney.velocity.x = 10;
		}
		if (FlxG.keys.pressed.S)
		{
			
		}
	}
	
	private function gamepadControls(gamepad:FlxGamepad):Void
	{
		//Close Substate
		if (gamepad.anyPressed(["B"]))
			close();
		
		if (gamepad.anyPressed(["DOWN", "DPAD_DOWN", "LEFT_STICK_DIGITAL_DOWN"]))
		{
			
		}
		if (gamepad.anyPressed(["UP", "DPAD_UP", "LEFT_STICK_DIGITAL_UP"]))
		{
			
		}	
		if (gamepad.anyPressed(["LEFT", "DPAD_LEFT", "LEFT_STICK_DIGITAL_LEFT"]))
		{
			
		}
		if (gamepad.anyPressed(["RIGHT", "DPAD_RIGHT", "LEFT_STICK_DIGITAL_RIGHT"]))
		{
			
		}
	}
}