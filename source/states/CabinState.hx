package states;

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

import data.BitArray;
import data.Calendar;
import data.Instrument;
import data.NGio;
import states.OgmoState;
import sprites.Fire;
import sprites.TvBubble;
import sprites.NPC;
import sprites.Present;
import sprites.Prompt;

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
	
	static inline var ADVENT_LINK:String = "https://www.newgrounds.com/portal/view/721061";
	
	static var presentPositions:Array<FlxPoint> = null;
	static var backupPresentPositions:Array<FlxPoint> = null;
	
	var tvTouch:FlxObject;
	var tvBubble:TvBubble;
	var fromOutside = false;
	var presents = new FlxTypedGroup<Present>();
	var toOutside:FlxObject;
	var crimeState:Null<CrimeState> = null;
	var crimeData:CrimeData;
	var tree:OgmoDecal;
	
	override public function new (fromOutside = false)
	{
		this.fromOutside = fromOutside;
		super();
	}
	
	override function create()
	{
		super.create();
		
		if (FlxG.sound.music == null)
		{
			if (Calendar.isAdvent)
				playSong();
			else
				playSong(FlxG.random.int(0, 25));
				
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
		else
		{
			var sprite = player.showControls();
			if (sprite != null)
				add(sprite);
		}
		var tv:FlxSprite = foreground.getByName("tv");
		tv.animation.curAnim.frameRate = 6;
		tvBubble = cast props.getByName("TvBubble");
		if (Calendar.today.tv != null)
			tvBubble.msg = Calendar.today.tv.toUpperCase();
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
		
		background.safeSetAnimFrameRate("neon", 2);
		foreground.safeSetAnimFrameRate("fire", 12);
		var bigFlame = foreground.getByName("bigCandleFire");
		if (bigFlame != null)
		{
			bigFlame.animation.curAnim.frameRate = 6;
			bigFlame.y += 1000;
			bigFlame.offset.y += 1000;
		}
		
		var numFlames = Calendar.hanukkahDay + 1;
		for (flame in foreground.getAllWithName("smallCandleFire"))
		{
			if (numFlames > 0)
			{
				flame.animation.curAnim.frameRate = 6;
				flame.y += 1000;
				flame.offset.y += 1000;
				numFlames--;
			}
			else
				flame.kill();
		}
		
		var calendar = foreground.getByName("calendar");
		if (Calendar.isPast || Calendar.day + 1 == 25 || Calendar.isDebugDay)
		{
			var label = "Calendar";
			if (!Calendar.isPast && Calendar.day + 1 != 25)
				label += "\n(debug)";
			addHoverTextTo(calendar, label, ()->openSubState(new CalendarSubstate(onCalendarDateChange)));
		}
		else
			calendar.kill();
		
		var jukebox = foreground.getByName("jukebox");
		if (Calendar.isPast || Calendar.day + 1 == 25 || Calendar.isDebugDay)
		{
			var label = "Switch Music";
			if (!Calendar.isPast && Calendar.day + 1 != 25)
				label += "\n(debug)";
			addHoverTextTo(jukebox, label, changeMusic);
		}
		else
			jukebox.kill();
		
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
			addHoverTextTo(npc, npc.name);
		}
	}
	
	function initPresents():Void
	{
		trace("num presents: " + Calendar.day + 1);
		
		// Load present positions from presents.json OGMO level
		if(presentPositions == null)
		{
			presentPositions = [];
			backupPresentPositions = [];
			
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
					final medalSuffix = decal.texture.split("medal").pop().split(".").shift();
					if (medalSuffix == "_backup")
						backupPresentPositions.push(new FlxPoint(decal.x, decal.y));
					else
						presentPositions[Std.parseInt(medalSuffix) - 1] = new FlxPoint(decal.x, decal.y);
				}
			}
		}
		
		// put out a present for eadh day so far
		for (i in 0...Calendar.day + 1)
		{
			var present = new Present
				( presentPositions[i].x
				, presentPositions[i].y
				, i
				, Calendar.openedPres[i]
				);
			
			initArtPresent(present, Calendar.data[i].art, onPresentOpen.bind(present));
			
			presents.add(present);
			colliders.add(present);
			characters.add(present);
			foreground.add(present);
		}
		
		if (Calendar.today.extras != null)
		{
			for (i in 0...Calendar.today.extras.length)
			{
				var present = new Present
					( backupPresentPositions[i].x
					, backupPresentPositions[i].y
					, "backup"
					, 25 + i
					, Calendar.openedPres[i]
					);
				
				initArtPresent(present, Calendar.today.extras[i], onPresentOpen.bind(present));
				
				presents.add(present);
				colliders.add(present);
				characters.add(present);
				foreground.add(present);
			}
		}
	}
	
	override function update(elapsed:Float)
	{
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
		
		#if debug
		if (FlxG.keys.justPressed.N)
			triggerCutscene();
		#end
	}
	
	function isBehindTree(object:FlxObject):Bool
	{
		return object.y < tree.y
			&& object.x + object.width / 2 > tree.x
			&& object.x + object.width / 2 < tree.x + tree.width;
	}
	
	function onPresentOpen(present:Present):Void
	{
		// justOpenPresent = true;
		
		if (present.isDaily)
		{
			if (Calendar.allowDailyMedalUnlock(present.day))
				NGio.unlockMedal(NGio.MEDAL_0 + Calendar.day);
			
			if (Calendar.day == 12 && present.day == 12 && crimeState == null && !Calendar.solvedMurder)
				startCrimeCutscene();
			
		}
		
		var presCount:Int = 0;
		while (Calendar.openedPres[presCount])
			presCount++;
		
		trace(Calendar.openedPres.toString(), presCount);
		if (presCount == 29)
			triggerCutscene();
	}
	
	function changeMusic():Void
	{
		var day = ((FlxG.sound.music.ID + 1) % 5) * 5;
		
		playSong(day);
	}
	
	inline function playSong(?day:Int)
	{
		if (day == null)
			day = Calendar.day;
		
		FlxG.sound.playMusic(Calendar.data[day].getSongPath(), 0);
		var volume = Calendar.today.song.volume;
		FlxG.sound.music.fadeIn(5, 0, volume == null ? 0.3 : volume);
		FlxG.sound.music.ID = Math.floor(day / 5);
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
			
			addHoverTextTo(background.getByName("crimeOutline"), "Reset Murder?", resetCrimePrompt);
			
			giveNpcCrimeDialog();
		}
		else
		{
			var deadguy = foreground.getByName("deadguy");
			deadguy.visible = false;
			foreground.getByName("crime").visible = false;
			background.getByName("crimeOutline").visible = false;
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
	
	function resetCrimePrompt():Void
	{
		
		var prompt = new Prompt();
		add(prompt);
		prompt.setup
			( 'Reset murder?'
			, resetCrime
			, null
			, remove.bind(prompt)
			);
	}
	
	function resetCrime():Void
	{
		Calendar.resetMurder();
		FlxG.switchState(new CabinState());
	}
	
	function startCrimeCutscene():Void
	{
		crimeState = LightsOff;
		cutsceneActive = true;
		foreground.active = false;
		cutsceneTimer = 0;
		infoBoxGroup.visible = false;
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
					background.getByName("crimeOutline").visible = true;
					foreground.getByName("tree_13").visible = true;
					foreground.getByName("tree_11").visible = false;
					openSubState(DialogSubstate.fromMessage(crimeData.instructions));
					crimeState = Interrogation;
				}
			case Interrogation:
				if (isStateStart)
				{
					infoBoxGroup.visible = true;
					foreground.active = true;
					cutsceneActive = false;
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
	
	function onCalendarDateChange(date:Int)
	{
		NGio.unlockMedal(58547);
		Calendar.timeTravelTo(date);
		FlxG.switchState(new CabinState());
	}
	
	function triggerCutscene()
	{
		foreground.active = false;
		Calendar.resetOpenedPresents();
		NGio.unlockMedal(58546);
		FlxG.sound.music.stop();
		
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
		
		var menorah = foreground.getByName("menorah");
		setFire(menorah.x - 4, menorah.y - 40);
		new FlxTimer().start(0.5, (_)->setFire(220, 113));
		new FlxTimer().start(1.0, (_)->setFire(190, 100));
		new FlxTimer().start(1.5, (_)->add(new Fire()));
		new FlxTimer().start(2.0, (_)->FlxG.camera.fade(0xFFff0000, 3, false, FlxG.switchState.bind(new CreditState())));
	}
	
	function setFire(x, y)
	{
		var fire = new FlxSprite(x, y);
		fire.loadGraphic("assets/images/props/cabin/fire.png", true, 36, 24);
		fire.animation.add("anim", [for (i in 0...18) i], 12);
		fire.animation.play("anim");
		add(fire);
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