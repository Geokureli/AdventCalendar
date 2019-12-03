package states;

import io.newgrounds.NG;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;

import data.Calendar;
import data.NGio;
import states.OgmoState;
import sprites.Thumbnail;
import sprites.TvBubble;
import sprites.Present;

class CabinState extends BaseState
{
	inline static var MEDAL_0 = 58519;
	
	var tvTouch:FlxObject;
	var tvBubble:TvBubble;
	var fromOutside = false;
	var presents = new FlxTypedGroup<Present>();
	var thumbnail = new Thumbnail();
	
	override public function new (fromOutside = false)
	{
		this.fromOutside = fromOutside;
		super();
	}
	
	override function create()
	{
		super.create();
		
		initPresents();
	}
	
	override function loadLevel():Void
	{
		parseLevel(getLatestLevel("cabin"));
		
		// FlxG.debugger.drawDebug = true;
	}
	
	override function initEntities()
	{
		super.initEntities();
		
		var tree:FlxSprite = null;
		var day = Calendar.day + 1;
		while(day > 0 && tree == null)
		{
			tree = foreground.getByName('tree_$day');
			day--;
		}
		day++; 
		
		if (tree != null)
		{
			if (day < 3)
			{
				tree.height = 34;
				tree.y += tree.frameHeight - tree.height - 16;
				tree.offset.y += tree.frameHeight - tree.height - 16;
			}
			else
			{
				tree.height = 40;
				tree.y += tree.frameHeight - tree.height - 10;
				tree.offset.y += tree.frameHeight - tree.height - 10;
			}
		}
		
		if (fromOutside)
		{
			var floor:FlxSprite = background.getByName("floor");
			player.x = floor.width - player.width;
			player.y = 78 + (floor.height - 78) / 2;
		}
		
		var tv:FlxSprite = foreground.getByName("tv");
		tvBubble = props.getByName("TvBubble");
		tvBubble.msg = Calendar.today.tv;
		tvTouch = new FlxObject(tv.x - 3, tv.y, tv.width + 3, tv.height + 3);
	}
	
	override function initCamera()
	{
		super.initCamera();
		
		camera.focusOn(player.getPosition());
	}
	
	function initPresents():Void
	{
		trace("num presents: " + Calendar.day + 1);
		
		for (p in 0...Calendar.day + 1)
		{
			final pos = Calendar.data[p].pos;
			var present:Present = new Present(pos.x / 2, pos.y / 2, p);
			if (Calendar.openedPres[p])
				present.animation.play("opened");
			
			presents.add(present);
			colliders.add(present);
			foreground.add(present);
		}
	}
	
	override function update(elapsed:Float)
	{
		var touchingPresent:Present;
		FlxG.overlap(playerHitbox, presents,
			(_, present)->
			{
				if (touchingPresent == null)
				{
					touchingPresent = present;
					touchPresent(present);
				}
			}
		);
		
		super.update(elapsed);
		
		if (tvTouch.overlaps(playerHitbox) && FlxG.keys.justPressed.SPACE)
			tvBubble.play();
		
		if (player.x > FlxG.camera.maxScrollX #if debug || FlxG.keys.justPressed.O #end)
			FlxG.switchState(new OutsideState());
	}
	
	inline public function touchPresent(present:Present)
	{
		final day =- present.curDay;
		
		if (Calendar.openedPres[day])
		{
			thumbnail.overlappin = true;
			thumbnail.setPosition(present.x - 20, present.y - thumbnail.height - 8);
			thumbnail.newThumb(day);
		}
		
		if (FlxG.onMobile)
		{
			for (touch in FlxG.touches.justStarted())
			{
				if (touch.overlaps(present) || touch.overlaps(thumbnail))
					openPresent(present);
			}
		}
		else if (FlxG.keys.justPressed.SPACE)
			openPresent(present);
	}
	
	function openPresent(present:Present):Void
	{
		trace('opened: ' + present.curDay);
		
		if (NGio.isLoggedIn && present.curDay == Calendar.day)
		{
			trace("unlocking " + (MEDAL_0 + Calendar.day));
			var medal = NG.core.medals.get(MEDAL_0 + Calendar.day);
			if (!medal.unlocked)
				medal.sendUnlock();
			else
				trace("already unlocked");
		}
		
		present.animation.play("opened");
		Calendar.saveOpenPresent(present.curDay);
		FlxG.sound.play("assets/sounds/presentOpen.mp3", 1);
		openSubState(new GallerySubstate(present.curDay));
		
		var presCount:Int = 0;
		for (i in 0...Calendar.openedPres.getLength())
		{
			if (Calendar.openedPres[i])
				presCount += 1;
		}
		
		if (presCount == 25)
		{
			// triggerCutscene();
			Calendar.resetOpenedPresents();
		}
	}
}