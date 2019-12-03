package sprites;

import flixel.FlxG;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxVector;
import flixel.math.FlxVelocity;
import flixel.util.FlxColor;
import flixel.system.FlxAssets.FlxGraphicAsset;

/**
 * ...
 * @author NInjaMuffin99
 */
class Player extends Character 
{
	
	private var C:Float = 0;
	public var stepSoundType:String;
	public var interacting:Bool;

	public function new(X = 0.0, Y = 0.0, ?curDay:Int = null ) 
	{
		super(X, Y);
		
		this.curDay = curDay;
		
		loadGraphic(AssetPaths.tankMan__png, true, 16, 16);
		
		resizeHitbox();
		
		if (curDay != null)
			updateSprite(curDay);
	}
	
	private var jumpBoost:Int = 0;
	private var justStepped:Bool = false;
	
	override public function update(elapsed:Float):Void 
	{
		
		if (FlxG.onMobile)
		{
			
			touchControls();
		}
		else
		{
			keyboardControls();
		}
		
		super.update(elapsed);
	}
	
	private function touchControls():Void
	{
		interacting = false;
		// basically means that the touchscreen is bein pressed right guys
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
			{
				var pos:FlxVector = touch.getWorldPosition();
				var maxDis = Math.max(Math.abs(pos.x - x), Math.abs(pos.y + 4 - y));
				trace(maxDis);
				interacting = maxDis < 24;
			}
			
			#if debug
			color = interacting ? FlxColor.BLACK : FlxColor.WHITE;
			#end
			
			if (touch.pressed)
			{
				bobShit();
				
				velocity.set(C);
				velocity.rotate(FlxPoint.weak(), FlxAngle.angleBetweenTouch(this, FlxG.touches.list[0], true));
				
			}
			else
			{
				jumpBoost = 0;
			}
		}
		
	}
	
	private function keyboardControls():Void
	{
		interacting = FlxG.keys.justPressed.SPACE;
		
		if (FlxG.keys.anyPressed([A, S, D, W, "UP", "DOWN", "LEFT", "RIGHT"]))
		{
			bobShit();
			
			var vertSlow:Float = 0.9;
			
			if (FlxG.keys.anyPressed(["S", "DOWN"]))
			{
				velocity.y = C * vertSlow;
			}
			if (FlxG.keys.anyPressed(["W", "UP"]))
			{
				velocity.y = -C * vertSlow;
			}
			if (FlxG.keys.anyPressed(["A", "LEFT"]))
			{
				velocity.x = -C;
			}
			if (FlxG.keys.anyPressed(["D", "RIGHT"]))
			{
				velocity.x = C;
			}
		}
		else
			jumpBoost = 0;
	}
	
	private function bobShit():Void
	{
		
		jumpBoost++;
		
		
		C = FlxMath.fastCos(8 * jumpBoost * FlxG.elapsed);
		
		if (C < 0)
		{
			if (!justStepped)
			{
				justStepped = true;
				if (stepSoundType != null)
					FlxG.sound.play("assets/sounds/walk_" + stepSoundType + FlxG.random.int(1, 3) + ".mp3", 0.2);
			}
			
			jumpBoost += 4;
			C = 0;
		}
		else
			justStepped = false;
		
		offset.y = (C * 1.3) + actualOffsetLOL;
		
		C *= speed;
	}
	
}