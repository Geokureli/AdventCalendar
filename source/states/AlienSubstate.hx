package states;

import flixel.group.FlxGroup;
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
import sprites.Hominid;

/**
 * ...
 * @author pfft no one owns me
 */
class AlienSubstate extends FlxSubState 
{	
	private var chimney:FlxSprite;
	private var grpAliens:FlxSpriteGroup;
	private var blackLeft:FlxSprite;
	private var blackRight:FlxSprite;

	override public function create():Void 
	{

		blackLeft = new FlxSprite().makeGraphic(175 - 95, FlxG.height, FlxColor.BLACK);
		blackLeft.immovable = true;
		blackLeft.scrollFactor.set();
		blackLeft.elasticity = 0.9;

		blackRight = new FlxSprite(335 - 95).makeGraphic(175, FlxG.height, FlxColor.BLACK);
		blackRight.immovable = true;
		blackRight.scrollFactor.set();

		var bg:FlxSprite = new FlxSprite().loadGraphic("assets/images/minigame/night.png");
		bg.scrollFactor.set();
		bg.setGraphicSize(0, FlxG.height);
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

		grpAliens = new FlxSpriteGroup();
		add(grpAliens);

		chimney = new FlxSprite(0, FlxG.height - 20).loadGraphic("assets/images/minigame/chimney.png");
		chimney.scrollFactor.set();
		chimney.screenCenter(X);
		chimney.elasticity = 0.5;
		add(chimney);

		chimney.drag.x = 40;
		chimney.maxVelocity.x = 350;

		spawnAliens();


		add(blackRight);
		add(blackLeft);

		super.create();
	}

	function spawnAliens():Void
	{
		for (i in 0...FlxG.random.int(3, 8))
		{
			var alien:Hominid = new Hominid(FlxG.random.float(185, 300), 1);
			alien.scrollFactor.set();
			alien.acceleration.y = 10;
			alien.velocity.y = 60;
			grpAliens.add(alien);
		}
	}
	
	override public function update(elapsed:Float):Void 
	{
		keyboardControls();

		FlxG.collide(chimney, blackRight);
		FlxG.collide(chimney, blackLeft);
		super.update(elapsed);
	}
	
	private var chimSpeed:Float = 400;
	
	private function keyboardControls():Void
	{		
		if (FlxG.keys.anyJustPressed(["ESCAPE", "SPACE"]))
			close();
		
		if (!FlxG.keys.anyPressed(["A", "D"]))
		{
			chimney.acceleration.x = 0;
		}
		// REPLACE THESE TO BE CLEANER LATER AND WITH MORE KEYS
		if (FlxG.keys.pressed.D)
		{
			chimney.acceleration.x = chimSpeed;
		}
		if (FlxG.keys.justPressed.W)
		{
			spawnAliens();
		}	
		if (FlxG.keys.pressed.A)
		{
			chimney.acceleration.x = -chimSpeed;
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