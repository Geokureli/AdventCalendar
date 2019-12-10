package states;

import haxe.Json;
import openfl.utils.Assets;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;

import data.Calendar;
import data.NGio;
import states.OgmoState;
import sprites.Thumbnail;
import sprites.TvBubble;
import sprites.NPC;
import sprites.Present;

class CabinState extends BaseState
{
	inline static var MEDAL_0 = 58519;
	static inline var ADVENT_LINK:String = "https://www.newgrounds.com/portal/view/721061";
	
	static var presentPositions:Array<FlxPoint> = null;
	
	var tvTouch:FlxObject;
	var tvBubble:TvBubble;
	var fromOutside = false;
	var presents = new FlxTypedGroup<Present>();
	var thumbnail = new Thumbnail();
	var toOutside:FlxObject;
	
	override public function new (fromOutside = false)
	{
		this.fromOutside = fromOutside;
		super();
	}
	
	override function create()
	{
		super.create();
		
		if (Calendar.isAdvent && FlxG.sound.music == null)
		{
			FlxG.sound.playMusic(Calendar.today.getSongPath(), 0);
			FlxG.sound.music.fadeIn(5, 0, 0.3);
		}
		
		initPresents();
	}
	
	override function loadLevel():Void
	{
		parseLevel(getLatestLevel("cabin"));
		
		// #if debug FlxG.debugger.drawDebug = true; #end
	}
	
	override function initEntities()
	{
		super.initEntities();
		
		add(thumbnail);
		
		var tree:OgmoDecal = null;
		var day = Calendar.day + 1;
		while(day > 0 && tree == null)
		{
			tree = foreground.getByName('tree_$day');
			day--;
		}
		day++; 
		
		if (tree != null)
			tree.setBottomHeight(day < 3 ? 8 : 10);
		
		toOutside = props.getByName("toOutside");
		if (fromOutside)
		{
			player.x = toOutside.x - player.width - 5;
			player.y = toOutside.y + toOutside.height / 2;
			player.facing = FlxObject.LEFT;
		}
		
		var tv:FlxSprite = foreground.getByName("tv");
		tv.animation.curAnim.frameRate = 6;
		tvBubble = cast props.getByName("TvBubble");
		tvBubble.msg = Calendar.today.tv;
		tvTouch = new FlxObject(tv.x - 3, tv.y, tv.width + 6, tv.height + 3);
		
		var arcade = foreground.getByName("arcade");
		if (arcade != null)
		{
			arcade.animation.curAnim.frameRate = 6;
			addInfoBoxTo(arcade, "2018 Advent", FlxG.openURL.bind(ADVENT_LINK));
		}
		
		var arcade2 = foreground.getByName("arcade2");
		if (arcade2 != null)
		{
			arcade2.animation.curAnim.frameRate = 6;
			addInfoBoxTo(arcade2, "Hominid Helpers", openSubState(new AlienSubstate()));
		}
		
		var neon = foreground.getByName("neon");
		if (neon != null)
			neon.animation.curAnim.frameRate = 2;
		
		var fire = foreground.getByName("fire");
		if (fire != null)
			arcade.animation.curAnim.frameRate = 12;
		
		//Music Credit
		safeAddInfoBox
			( "stereo"
			, "Music by " + Calendar.today.song.artist
			, FlxG.openURL.bind(Calendar.today.musicProfileLink)
			);
		
		initNPC();
	}
	
	private function initNPC():Void
	{
		var cam = FlxG.camera;
		for (c in 0...Calendar.day)
		{
			var npc:NPC = new NPC
				( FlxG.random.float(cam.minScrollX + 20, cam.maxScrollX - 20)
				, FlxG.random.float(100, cam.maxScrollY - 20)
				);
			npc.updateSprite(c);
			foreground.add(npc);
			colliders.add(npc);
			characters.add(npc);
		}
	}
	
	function initPresents():Void
	{
		trace("num presents: " + Calendar.day + 1);
		
		// Load present positions from presents.json OGMO level
		if(presentPositions == null)
		{
			presentPositions = [];
			
			var presentData:OgmoLevelData = cast Json.parse(Assets.getText("assets/data/levels/presents.json"));
			if (presentData == null)
				throw "missing presents.json";
			
			var props:OgmoEntityLayerData = null;
			for (layer in presentData.layers)
			{
				if (layer.name == "Props")
				{
					props = cast layer;
					break;
				}
			}
			if (props == null)
				throw "missing Props layer in present.json";
			
			for (entity in (cast props.entities:Array<OgmoEntityData<{id:String}>>))
			{
				if (entity.name == "Present" && entity.values.id == "")
					presentPositions.push(new FlxPoint(entity.x, entity.y));
			}
		}
		
		// put out a present for eadh day so far
		for (i in 0...Calendar.day + 1)
		{
			var present:Present = new Present(presentPositions[i].x, presentPositions[i].y, i);
			if (Calendar.openedPres[i])
				present.animation.play("opened");
			
			presents.add(present);
			colliders.add(present);
			characters.add(present);
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
		
		//INTERACTABLES
		if (tvTouch.overlaps(playerHitbox) && player.interacting)
			tvBubble.play();
		
		if (player.overlaps(toOutside) #if debug || FlxG.keys.justPressed.C #end)
			FlxG.switchState(new OutsideState());
	}
	
	inline public function touchPresent(present:Present)
	{
		final day = present.curDay;
		
		if (Calendar.openedPres[day])
		{
			thumbnail.overlappin = true;
			thumbnail.newThumb(day);
			thumbnail.x = present.x + (present.width - thumbnail.width) / 2;
			thumbnail.y = present.y - thumbnail.height - 8;
		}
		
		if (player.interacting)
			openPresent(present);
		else if (FlxG.onMobile)
		{
			for (touch in FlxG.touches.justStarted())
			{
				if (touch.overlaps(present) || touch.overlaps(thumbnail))
					openPresent(present);
			}
		}
	}
	
	function openPresent(present:Present):Void
	{
		trace('opened: ' + present.curDay);
		
		if (present.curDay == Calendar.day || Calendar.isChristmas)
			NGio.unlockMedal(MEDAL_0 + Calendar.day);
		
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