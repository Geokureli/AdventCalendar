package states;

import data.BitArray;
import haxe.Json;
import openfl.utils.Assets;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

import data.Calendar;
import data.Instrument;
import data.NGio;
import states.OgmoState;
import sprites.Thumbnail;
import sprites.TvBubble;
import sprites.NPC;
import sprites.Present;

typedef Message = { ?title:String, body:String }
typedef CrimeData = {
	instructions:Message,
	recap1      :Message,
	recap2      :Message,
	messages    :Array<Message>,
	accusation  :Message,
	stab        :Message,
	victory     :Message
}

class CabinState extends BaseState
{
	inline static var TREE_FADE_TIME = 3.0;
	
	inline static var MEDAL_0 = 58519;
	static inline var ADVENT_LINK:String = "https://www.newgrounds.com/portal/view/721061";
	
	static var presentPositions:Array<FlxPoint> = null;
	
	var tvTouch:FlxObject;
	var tvBubble:TvBubble;
	var fromOutside = false;
	var presents = new FlxTypedGroup<Present>();
	var thumbnail = new Thumbnail();
	var toOutside:FlxObject;
	var crimeState:Null<CrimeState> = null;
	var crimeData:CrimeData;
	var justOpenPresent = false;
	var tree:OgmoDecal;
	
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
			var volume = Calendar.today.song.volume;
			FlxG.sound.music.fadeIn(5, 0, volume == null ? 0.3 : volume);
			Instrument.setInitial();
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
		
		var treeDay = foreground.getObjectNameIndex("tree_", Calendar.day + 1);
		tree = foreground.getByName("tree_" + treeDay);
		if (tree != null)
		{
			tree.setBottomHeight(treeDay < 3 ? 8 : 10);
			tree.setMiddleWidth(25);
		}
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
			addHoverTextTo(arcade, "2018 Advent", openUrl.bind(ADVENT_LINK));
		}
		
		var arcade2 = foreground.getByName("arcade2");
		if (arcade2 != null)
		{
			arcade2.animation.curAnim.frameRate = 6;
			#if debug//disable for releases
			addHoverTextTo(arcade2, "Hominid Helpers", ()->openSubState(new AlienSubstate()));
			#end
		}
		
		var neon = foreground.getByName("neon");
		if (neon != null)
			neon.animation.curAnim.frameRate = 2;
		
		var fire = foreground.getByName("fire");
		if (fire != null)
			arcade.animation.curAnim.frameRate = 12;
		
		//Music Credit
		safeAddHoverText
			( "stereo"
			, "Music by " + Calendar.today.song.artist
			, openUrl.bind(Calendar.today.musicProfileLink)
			);
		
		initNPCs();
		
		if (Calendar.day == 12) // Murder Mystery
			initCrime();
	}
	
	private function initNPCs():Void
	{
		var cam = FlxG.camera;
		for (c in 0...Calendar.day)
		{
			var npc:NPC = new NPC
				( FlxG.random.float(cam.minScrollX + 20, cam.maxScrollX - 20)
				, FlxG.random.float(100, cam.maxScrollY - 20)
				);
			npc.updateSprite(c);
			npcs.add(npc);
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
			
			var props:OgmoDecalLayerData = null;
			for (layer in presentData.layers)
			{
				if (layer.name == "Foreground")
				{
					props = cast layer;
					break;
				}
			}
			if (props == null)
				throw "missing Props layer in present.json";
			
			presentPositions.resize(props.decals.length);
			
			for (decal in props.decals)
			{
				if (decal.texture.indexOf("medal") != -1)
				{
					final medalNum = Std.parseInt(decal.texture.split("medal").pop().split(".").shift());
					presentPositions[medalNum - 1] = new FlxPoint(decal.x, decal.y);
				}
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
		
		if (Calendar.day == 12 && crimeState != null)
			updateCrime(elapsed);
		
		if (Calendar.day > 9 && isBehindTree(player))
			tree.alpha -= elapsed / TREE_FADE_TIME;
		else
			tree.alpha += elapsed / TREE_FADE_TIME;
		
		//INTERACTABLES
		if (tvTouch.overlaps(playerHitbox) && player.interacting)
			tvBubble.play();
		
		if (player.overlaps(toOutside) #if debug || FlxG.keys.justPressed.C #end)
			FlxG.switchState(new OutsideState());
	}
	
	function isBehindTree(object:FlxObject):Bool
	{
		return object.y < tree.y
			&& object.x + object.width / 2 > tree.x
			&& object.x + object.width / 2 < tree.x + tree.width;
	}
	
	public function touchPresent(present:Present)
	{
		final day = present.curDay;
		
		if (Calendar.openedPres[day])
		{
			thumbnail.overlappin = true;
			thumbnail.newThumb(day);
			thumbnail.x = present.x + (present.width - thumbnail.width) / 2;
			thumbnail.y = present.y - thumbnail.height - 8;
		}
		
		// prevent double open since multiple inputs can trigger
		if (!justOpenPresent)
		{
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
		else
			justOpenPresent = false;
	}
	
	function openPresent(present:Present):Void
	{
		justOpenPresent = true;
		trace('opened: ' + present.curDay);
		
		if (present.curDay == Calendar.day || Calendar.isChristmas)
			NGio.unlockMedal(MEDAL_0 + Calendar.day);
		
		present.animation.play("opened");
		Calendar.saveOpenPresent(present.curDay);
		FlxG.sound.play("assets/sounds/presentOpen.mp3", 1);
		
		var onClose:()->Void = null;
		if (Calendar.day == 12 && present.curDay == 12 && crimeState == null && !Calendar.solvedMurder)
			onClose = startCrimeCutscene;
		
		openSubState(new GallerySubstate(present.curDay, onClose));
		
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
	
	function initCrime()
	{
		crimeData = cast Json.parse(openfl.Assets.getText("assets/data/crimeData.json"));
		
		if (Calendar.seenMurder)
		{
			npcs.members[11].kill();
			foreground.getByName("tree_11").visible = false;
			foreground.getByName("deadguy").visible = false;
			
			if (Calendar.solvedMurder)
			{
				foreground.getByName("knife").visible = false;
			}
			else if (Calendar.hasKnife)
			{
				if (!fromOutside)
					openSubState(DialogSubstate.fromMessage(crimeData.recap2));
				crimeState = Accusation;
				foreground.getByName("knife").visible = false;
			}
			else if (Calendar.interrogatedAll)
			{
				if (!fromOutside)
					openSubState(DialogSubstate.fromMessage(crimeData.recap1));
				crimeState = PickUpKnife;
			}
			else
			{
				if (!fromOutside)
					openSubState(DialogSubstate.fromMessage(crimeData.instructions));
				crimeState = Interrogation;
			}
			
			giveNpcCrimeDialog();
		}
		else
		{
			var deadguy = foreground.getByName("deadguy");
			deadguy.visible = false;
			foreground.getByName("crime").visible = false;
			foreground.getByName("knife").visible = false;
			foreground.getByName("tree_13").visible = false;
			var tree = foreground.getByName("tree_11");
			tree.setBottomHeight(10);
			var madnessNpc = npcs.members[11];
			madnessNpc.x = deadguy.x;
			madnessNpc.y = deadguy.y;
			madnessNpc.immovable = true;
			madnessNpc.active = false;
		}
	}
	
	function startCrimeCutscene():Void
	{
		thumbnail.alpha = 0;
		crimeState = LightsOff;
		cutsceneActive = true;
		foreground.active = false;
		cutsceneTimer = 0;
	}
	
	function updateCrime(elapsed:Float):Void
	{
		var isStateStart = cutsceneTimer == 0;
		cutsceneTimer += elapsed;
		var oldState = crimeState;
		switch(crimeState)
		{
			case LightsOff:
				if (isStateStart)
					FlxG.camera.fade(0.01, false);
				checkForNextState(1.0);
			case LightsOn:
				if (isStateStart)
				{
					FlxG.camera.fade(0.1, true);
					foreground.getByName("deadguy").visible = true;
					foreground.getByName("knife").visible = true;
					
					// remove madness guy
					npcs.members[11].kill();
				}
				checkForNextState(0.5);
			case NpcLook:
			
				if (isStateStart)
				{
					// show popup alert icons
					for (npc in npcs.members)
					{
						if (npc.alive)
						{
							var emotion = npc.setEmotion(Puzzled);
							foreground.add(emotion);
							foreground.members.remove(emotion);
							foreground.members.insert(foreground.members.indexOf(npc), emotion);
						}
					}
				}
				
				if (FlxG.random.bool(20))
					npcs.getRandom().facing ^= FlxObject.WALL;
				
				checkForNextState(1.0);
			case PanToBody:
				if(isStateStart)
				{
					var oldLerp = FlxG.camera.followLerp;
					FlxG.camera.followLerp = 60 / FlxG.updateFramerate;
					var target = foreground.getByName("deadguy");
					FlxTween.tween(FlxG.camera, { zoom:2 }, 0.25);
					FlxTween.tween
						( camFollow
						, { x:target.x + target.width / 2, y:target.y }
						, 0.25
						, { ease:FlxEase.quadInOut, onComplete:(_)->FlxG.camera.followLerp = oldLerp }
						);
				}
				
				checkForNextState(0.5);
			case ShowBody:
				if (isStateStart)
				{
					for (npc in npcs.members)
					{
						
						if (npc.alive)
						{
							var emotion = npc.setEmotion(Alerted);
							foreground.add(emotion);
							foreground.members.remove(emotion);
							foreground.members.insert(foreground.members.indexOf(npc), emotion);
						}
					}
				}
				checkForNextState(2.0);
			case PanFromBody:
				if (isStateStart)
				{
					var oldLerp = FlxG.camera.followLerp;
					FlxG.camera.followLerp = 60 / FlxG.updateFramerate;
					FlxTween.tween(FlxG.camera, { zoom:1 }, 0.5);
					FlxTween.tween
						( camFollow
						, { x:player.x, y:player.y - camOffset }
						, 0.5
						, { ease:FlxEase.quadInOut, onComplete:(_)->FlxG.camera.followLerp = oldLerp }
						);
				}
				checkForNextState(0.5);
			case NpcJump:
				
				checkForNextState(0.5);
			case Instructions:
				if (isStateStart)
				{
					Calendar.saveSeenMurder();
					foreground.getByName("deadguy").visible = false;
					foreground.getByName("crime").visible = true;
					foreground.getByName("tree_13").visible = true;
					foreground.getByName("tree_11").visible = false;
					openSubState(DialogSubstate.fromMessage(crimeData.instructions));
					crimeState = Interrogation;
				}
			case Interrogation:
				if (isStateStart)
				{
					foreground.active = true;
					cutsceneActive = false;
					thumbnail.alpha = 1;
					giveNpcCrimeDialog();
				}
				
				if (Calendar.interrogatedAll)
				{
					crimeState = PickUpKnife;
					cutsceneTimer = 0;
				}
			case PickUpKnife:
				if (isStateStart)
				{
					openSubState(DialogSubstate.fromMessage(crimeData.accusation));
					addHoverText("knife", "knife", pickUpKnife);
				}
			case Accusation:
		}
		if (crimeState != oldState)
			cutsceneTimer = 0;
	}
	
	function giveNpcCrimeDialog():Void
	{
		for (i in 0...npcs.members.length)
			addHoverTextTo(npcs.members[i], "talk", talkTo.bind(i));
	}
	
	function talkTo(npcIndex:Int)
	{
		openSubState(DialogSubstate.fromMessage
			( crimeData.messages[npcIndex]
			, !Calendar.interrogated[npcIndex]
			)
		);
		Calendar.saveInterrogated(npcIndex);
	}
	
	function pickUpKnife()
	{
		openSubState(DialogSubstate.fromMessage(crimeData.stab));
		var knife = foreground.getByName("knife");
		remove(infoBoxes[knife]);
		infoBoxes.remove(knife);
		knife.kill();
		add(player.giveKnife());
		Calendar.saveHasKnife();
		crimeState = Accusation;
		cutsceneTimer = 0;
	}
	
	inline function checkForNextState(limit:Float):Bool
	{
		var complete = cutsceneTimer > limit;
		if (complete)
			crimeState = CrimeState.createByIndex(crimeState.getIndex() + 1);
		return complete;
	}
}

enum CrimeState
{
	LightsOff;
	LightsOn;
	NpcLook;
	PanToBody;
	ShowBody;
	PanFromBody;
	NpcJump;//?
	Instructions;
	Interrogation;
	PickUpKnife;
	Accusation;
}