package sprites;

import flixel.FlxSprite;
import data.Calendar;
import data.Instrument;
import flixel.input.keyboard.FlxKey;
import flixel.FlxObject;
import flixel.FlxG;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxVector;
import flixel.math.FlxVelocity;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import flixel.input.gamepad.FlxGamepad;

/**
 * ...
 * @author NInjaMuffin99
 */
class Player extends Character 
{
	inline static var POP_DELAY_TIME = 2.0;
	inline static var POP_IN_OUT_TIME = 0.25;
	inline static var POP_IN_TIME = POP_DELAY_TIME + POP_IN_OUT_TIME;
	inline static var POP_HOLD_TIME = 3.0;
	inline static var POP_EXIT_TIME = POP_IN_TIME + POP_HOLD_TIME;
	inline static var POP_TOTAL_TIME = POP_EXIT_TIME + POP_IN_OUT_TIME;
	
	static var musicKeys:Array<Array<FlxKey>>
		//  whole        whole        half whole         whole         whole        half
		= [[E], [FOUR], [R], [FIVE], [T], [Y], [SEVEN], [U], [EIGHT], [I], [NINE], [O], [P]];
	
	public var stepSoundType:String;
	public var interacting = false;
	public var wasInteracting = false;
	public var knife(default, null):FlxSprite = null;
	public var knifeTimer(default, null) = 0.0;
	public var controls(default, null):FlxSprite = null;
	public var controlsTimer(default, null) = 0.0;
	
	var C:Float = 0;
	
	public function new(X = 0.0, Y = 0.0, ?curDay:Int = null ) 
	{
		super(X, Y);
		
		this.curDay = curDay;
		if (curDay != null)
			updateSprite(curDay);
		
		if (Calendar.hasKnife)
			giveKnife();
	}
	
	private var jumpBoost:Int = 0;
	private var justStepped:Bool = false;
	
	override public function update(elapsed:Float):Void 
	{
		interacting = false;
		
		if (FlxG.onMobile)
		{	
			touchControls();
		}
		else
		{
			var moving = keyboardControls();
			
			if (!moving)
			{
				var gamepad:FlxGamepad = FlxG.gamepads.lastActive;
				if (gamepad != null)
					moving = gamepadControls(gamepad);
			}
			
			if (!moving)
				jumpBoost = 0;
		}
		
		if (interacting && knife != null)
		{
			knife.visible = true;
			knife.animation.play("stab");
			knifeTimer = 0.5;
		}
		
		if (knifeTimer > 0)
		{
			knife.scale.x = (facing == FlxObject.RIGHT ? -1 : 1);
			knife.x = x + (facing == FlxObject.RIGHT ? 4 : -10);
			knife.y = y - 6;
			knifeTimer -= elapsed;
			if (knifeTimer <= 0)
				knife.visible = false;
		}
		
		if (controls != null && controlsTimer < POP_TOTAL_TIME)
			updateControlPop(elapsed);
		
		// prevents a bug on gamepads
		if (wasInteracting && interacting)
			interacting = false;
		else
			wasInteracting = interacting;
		
		super.update(elapsed);
		
		if (Instrument.type != null)
		{
			for (i in 0...musicKeys.length)
			{
				if (FlxG.keys.anyJustReleased(musicKeys[i]))
					Instrument.release(i);
				
				if (FlxG.keys.anyJustPressed(musicKeys[i]))
					Instrument.press(i);
			}
		}
	}
	
	inline function updateControlPop(elapsed:Float):Void
	{
		controls.x = x + (width - controls.width) / 2;
		controls.y = y - height / 2;
		
		var t = 0.0;
		if (controlsTimer > POP_EXIT_TIME)
			t = FlxEase.backOut(1 - (controlsTimer - POP_EXIT_TIME) / POP_IN_OUT_TIME);
		else if (controlsTimer > POP_IN_TIME)
			t = 1;
		else if (controlsTimer > POP_DELAY_TIME)
			t = FlxEase.backOut((controlsTimer - POP_DELAY_TIME) / POP_IN_OUT_TIME);
		
		controls.scale.set(t, t);
		
		controlsTimer += elapsed;
		if (controlsTimer > POP_TOTAL_TIME)
		{
			controls.kill();
			controls = null;
		}
	}
	
	private function touchControls():Void
	{
		// basically means that the touchscreen is bein pressed right guys
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
			{
				var pos:FlxVector = touch.getWorldPosition();
				var maxDis = Math.max(Math.abs(pos.x - x), Math.abs(pos.y + 4 - y));
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
	
	private function keyboardControls():Bool
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
			return true;
		}
		return false;
	}
	
	private function gamepadControls(gamepad:FlxGamepad):Bool
	{
		interacting = gamepad.anyJustPressed(["A"]) || FlxG.keys.justPressed.SPACE;
			
		if (gamepad.anyPressed(["DOWN", "DPAD_DOWN", "LEFT_STICK_DIGITAL_DOWN", "UP", "DPAD_UP", "LEFT_STICK_DIGITAL_UP", "LEFT", "DPAD_LEFT", "LEFT_STICK_DIGITAL_LEFT", "RIGHT", "DPAD_RIGHT", "LEFT_STICK_DIGITAL_RIGHT"]))
		{
			bobShit();
				
			var vertSlow:Float = 0.9;
				
			if (gamepad.anyPressed(["DOWN", "DPAD_DOWN", "LEFT_STICK_DIGITAL_DOWN"]))
			{
				velocity.y = C * vertSlow;
			}
			if (gamepad.anyPressed(["UP", "DPAD_UP", "LEFT_STICK_DIGITAL_UP"]))
			{
				velocity.y = -C * vertSlow;
			}
			if (gamepad.anyPressed(["LEFT", "DPAD_LEFT", "LEFT_STICK_DIGITAL_LEFT"]))
			{
				velocity.x = -C;
			}
			if (gamepad.anyPressed(["RIGHT", "DPAD_RIGHT", "LEFT_STICK_DIGITAL_RIGHT"]))
			{
				velocity.x = C;
			}
			return true;
		}
		return false;
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
	
	public function showControls():Null<FlxSprite>
	{
		if (FlxG.onMobile)
			return null;
		
		controls = new FlxSprite();
		controls.loadGraphic("assets/images/ui/ftue_arrow_keys.png", true, 31, 19);
		controls.animation.add("anim", [0,1,0,2,0,3,0,4], 4);
		controls.animation.play("anim");
		controls.offset.y = controls.height + height;
		controls.scale.set();
		return controls;
	}
	
	public function giveKnife()
	{
		knife = new FlxSprite();
		knife.loadGraphic("assets/images/knifeAnim.png", true, 15, 2);
		knife.animation.add("stab", [0,1,2,3], 20, false);
		knife.visible = false;
		return knife;
	}
}