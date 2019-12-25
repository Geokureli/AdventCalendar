package sprites;

import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

import data.Calendar;

/**
 * ...
 * @author NInjaMuffin99
 */
class Character extends Sprite 
{
	public var name(default, null):String;
	
	private var speed:Float = 95;
	private var actualOffsetLOL:Float = 12;
	private var rightOffset:Float = 4;
	private var leftOffset:Float = 8;
	
	override function set_facing(direction:Int):Int
	{
		var isFlip = facing != direction;
		super.set_facing(direction);
		
		if (isFlip)
			updateFacingOffset();
		
		return direction;
	}
	
	inline function updateFacingOffset():Void
	{
		offset.x = facing == FlxObject.RIGHT ? rightOffset : leftOffset;
	}
	
	public function new(?X:Float=0, ?Y:Float=0) 
	{
		super(X, Y);
		
		loadGraphic("assets/images/tankMan.png", true, 16, 16);
		animation.frameIndex = 0;
		
		setFacingFlip(FlxObject.LEFT, false, false);
		setFacingFlip(FlxObject.RIGHT, true, false);
		
		drag.x = drag.y = 2500;
		// offsets to the bottom, then shrinks the sprite
		offset.y = height - 4;
		width = 4;
		height = 4;
		facing = FlxObject.LEFT;
	}
	
	
	public function updateSprite(day:Int):Void
	{
		name = Calendar.data[day].char;
		
		if (day+1 == 9)
		{
			loadGraphic("assets/images/Daddy.png", false, 24, 24);
			actualOffsetLOL = 20;
			width = 8;
			height = 8;
			offset.y += 9;
			leftOffset = 12;
		}
		else if (day+1 == 24)
		{
			loadGraphic("assets/images/pump_and_skid.png", true, 16, 16);
			animation.add("anim", [0,1,2,3], 5);
			animation.play("anim");
			width = 10;
			height = 4;
			leftOffset = 3;
			rightOffset = 2;
		}
		else
		{
			if (day == 14)// Dec 15th: Zach and Chris
			{
				width = 10;
				leftOffset = 3;
				rightOffset = 2;
			}
			// already should have loaded the sprite data i think
			animation.frameIndex = day;
		}
		updateFacingOffset();
	}
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
		if (velocity.x > 0)
			facing = FlxObject.RIGHT;
		else if (velocity.x < 0)
			facing = FlxObject.LEFT;
	}
	
	public function setEmotion(emotion:Emotion, keep = false):FlxSprite
	{
		var emotionSprite = new FlxSprite().loadGraphic(cast emotion);
		
		emotionSprite.x = x;
		emotionSprite.y = y;
		FlxTween.tween(emotionSprite, { y: y - frameHeight - 10}, 0.25, { ease:FlxEase.backOut });
		if (!keep)
		{
			FlxTween.tween(emotionSprite, { y: y - 10 }, 0.25,
				{ ease:FlxEase.backIn, startDelay:1.25, onComplete:(_)->emotionSprite.kill() }
			);
		}
		
		return emotionSprite;
	}
}

enum abstract Emotion(String) to String
{
	var Alerted = "assets/images/alerted.png";
	var Puzzled = "assets/images/puzzled.png";
	var Dead = "assets/images/props/heaven/halo.png";
}