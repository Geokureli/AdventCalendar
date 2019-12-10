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
	override public function create():Void 
	{
		
		super.create();
	}
	
	override public function update(elapsed:Float):Void 
	{
		
		super.update(elapsed);
	}
	
	
	private function keyboardControls():Void
	{		
		if (FlxG.keys.anyJustPressed(["ESCAPE", "SPACE"]))
			close();
		
		// REPLACE THESE TO BE CLEANER LATER AND WITH MORE KEYS
		if (FlxG.keys.pressed.D)
		{
			
		}
		if (FlxG.keys.pressed.W)
		{
			
		}	
		if (FlxG.keys.pressed.A)
		{
			
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