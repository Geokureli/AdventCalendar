package states;

import states.CabinState;
import haxe.Json;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxMath;

import data.Calendar;
import data.Instrument;
import data.NGio;
import states.OgmoState;
import sprites.Snow;

class OutsideState extends BaseState
{
	inline static public var MUSIC_MEDAL = 58544;
	inline static public var KILLER_MEDAL = 58545;
	
	inline static var WIND = 1.8;
	inline static var CLOUD_BOB_DIS = 50;
	inline static var CLOUD1_PERIOD = 10.0 * WIND;
	inline static var CLOUD2_PERIOD = 15.0 * WIND;
	
	var tree:OgmoDecal;
	var gyrados:OgmoDecal;
	var cloud1:OgmoDecal;
	var cloud2:OgmoDecal;
	var gyradosTimer = 0.0;
	var cloudTimer = 0.0;
	var camLerp = 0.0;
	var camSnap = 0.0;
	var toCabin:FlxObject;
	
	override function loadLevel():Void
	{
		parseLevel(getLatestLevel("outside"));
		
		// #if debug FlxG.debugger.drawDebug = true; #end
	}
	
	override function initEntities()
	{
		super.initEntities();
		
		var sky = background.getByName("sky");
		sky.scrollFactor.set(0.05, 0.08);
		
		cloud2 = background.getByName("clouds2");
		cloud2.scrollFactor.set(0.1, 0);
		cloud2.alpha = 0.5;
		
		cloud1 = background.getByName("clouds1");
		cloud1.scrollFactor.set(0.2, 0);
		cloud1.alpha = 0.5;
		
		var mountains = background.getByName("mountains");
		mountains.scrollFactor.set(0.3, 0.3);
		
		var snow1 = background.getByName("snow1");
		snow1.scrollFactor.set(0.4, 0.4);
		
		var ground = background.getIndexNamedObject("ground", Calendar.day + 1);
		var shine = background.getByName("shine");
		ground.scrollFactor.set(0.6, 0.6);
		shine.scrollFactor.set(0.6, 0.6);
		shine.scrollFactor.x = ground.scrollFactor.x * 0.8;
		//shine.scrollFactor.y = ground.scrollFactor.y * 0.85;
		shine.animation.curAnim.frameRate = 1;
		
		gyrados = background.getByName("gyrados");
		gyrados.scrollFactor.set(0.6, 0.6);
		gyrados.alpha = 0;
		gyrados.animation.curAnim.frameRate = 2;
		
		var campfire = background.getByName("campfire");
		campfire.alpha = 1.0;
		campfire.scrollFactor.set(0.6, 0.6);
		campfire.animation.curAnim.frameRate = 2;
		
		var snow2 = background.getByName("snow2");
		snow2.scrollFactor.set(0.8, 0.8);
		
		toCabin = props.getByName("toCabin");
		//Reshape
		tree = foreground.getByName("tree");
		tree.setBottomHeight(20);
		
		var tank = foreground.getByName("snowTank");
		tank.setBottomHeight(Math.round(tank.height / 2));
		
		initSculptures();
		
		var glockPresent = foreground.getByName("present_czyszy");
		if (glockPresent != null)
		{
			glockPresent.animation.add("unopened", [0], false);
			glockPresent.animation.add("opened", [1], false);
			glockPresent.immovable = true;
			colliders.add(glockPresent);
			if (Instrument.owns(Glockenspiel))
			{
				glockPresent.animation.play("opened");
				var glockenspiel = addGlock(glockPresent);
			}
			else
			{
				glockPresent.animation.play("unopened");
				addHoverTextTo(glockPresent, onGlockPresentOpen.bind(glockPresent));
			}
		}
		
		var flutePresent = foreground.getByName("present_colebob");
		if (flutePresent != null)
		{
			flutePresent.animation.add("unopened", [0], false);
			flutePresent.animation.add("opened", [1], false);
			flutePresent.immovable = true;
			colliders.add(flutePresent);
			if (Instrument.owns(Flute))
			{
				flutePresent.animation.play("opened");
				var flute = addFlute(flutePresent);
			}
			else
			{
				flutePresent.animation.play("unopened");
				addHoverTextTo(flutePresent, onFlutePresentOpen.bind(flutePresent));
			}
		}
		
		if (Calendar.day == 12)
		{
			var killer = foreground.getByName("killer");
			killer.animation.add("idle", [0]);
			killer.animation.add("bleed", [1,2,3], 4);
			killer.animation.play("idle");
			colliders.add(killer);
			killer.immovable = true;
			if (Calendar.solvedMurder)
				killer.animation.play("bleed");
			else if (Calendar.hasKnife)
				addHoverTextTo(killer, "BrandyBuizel", onKill);
			else
				addHoverTextTo(killer, "BrandyBuizel");
		}
		
		add(new Snow());
	}
	
	function initSculptures():Void
	{
		for (child in foreground.members)
		{
			if (child.graphic != null && child.graphic.assetsKey.indexOf("snowSprite/") != -1)
			{
				var name = child.graphic.assetsKey.split("snowSprite/").pop();
				name = name.substr(0, name.length - 4);
				if (Calendar.checkUnveiledArtist(name))
				{
					colliders.add(child);
					child.immovable = true;
					child.setBottomHeight(Math.round(child.height / 2));
					addHoverTextTo(child, name, openUrl.bind('https://$name.newgrounds.com'));
				}
				else
					child.kill();
			}
		}
	}
	
	override function initCamera()
	{
		super.initCamera();
		
		FlxG.camera.bgColor = 0xFF15122d;
	}
	
	inline static var TREE_FADE_TIME = 3.0;
	inline static var GYRADOS_TIME = 2 * 60.0;
	inline static var MAX_CAM_OFFSET = 75;
	inline static var CAM_SNAP_OFFSET = 30;
	inline static var CAM_SNAP_TIME = 3.0;
	inline static var CAM_LERP_OFFSET = MAX_CAM_OFFSET - CAM_SNAP_OFFSET;
	
	override public function update(elapsed:Float):Void 
	{
		final top = tree.y - 35;
		final height = 50;
		final snapY = tree.y;
		// snap camera when above threshold
		if (player.y < snapY && camSnap < CAM_SNAP_OFFSET)
			camSnap += elapsed / CAM_SNAP_TIME * CAM_SNAP_OFFSET;
		else if (camOffset > 0)
			camSnap -= elapsed / CAM_SNAP_TIME * CAM_SNAP_OFFSET;
		// lerp camera in threshold
		camLerp = (height - (player.y - top)) / height * CAM_LERP_OFFSET;
		
		camOffset = camSnap + FlxMath.bound(camLerp, 0, CAM_LERP_OFFSET);
		super.update(elapsed);
		
		cloudTimer += elapsed;
		cloud1.x = Math.round(FlxMath.fastCos(cloudTimer / CLOUD1_PERIOD * Math.PI) * CLOUD_BOB_DIS) - CLOUD_BOB_DIS;
		cloud2.x = Math.round(FlxMath.fastCos(cloudTimer / CLOUD2_PERIOD * Math.PI) * -CLOUD_BOB_DIS) - CLOUD_BOB_DIS;
		
		if (player.overlaps(toCabin) #if debug || FlxG.keys.justPressed.C #end)
			FlxG.switchState(new CabinState(true));
		
		if (player.y < top || isBehindTree(player))
			tree.alpha -= elapsed / TREE_FADE_TIME;
		else
			tree.alpha += elapsed / TREE_FADE_TIME;
		
		if (player.y < top)
		{
			#if debug
			if (FlxG.keys.justPressed.G)
				gyradosTimer = GYRADOS_TIME;
			#end
			
			gyradosTimer += elapsed;
			if (gyradosTimer > GYRADOS_TIME)
				gyrados.alpha += elapsed;
		}
		else
			gyrados.alpha -= elapsed;
	}
	
	function isBehindTree(obj:FlxObject)
	{
		return (obj.y < tree.y - 15 && obj.x > tree.x && obj.x + obj.width < tree.x + tree.width)
			|| (obj.y < tree.y && obj.x > tree.x + 45 && obj.x + obj.width < tree.x + tree.width - 45);
	}
	
	function onGlockPresentOpen(present:OgmoDecal):Void
	{
		present.animation.play("opened");
		remove(infoBoxes[present]);
		infoBoxes.remove(present);
		
		Instrument.addGlockenspiel();
		NGio.unlockMedal(MUSIC_MEDAL);
		
		addGlock(present);
	}
	
	function onFlutePresentOpen(present:OgmoDecal):Void
	{
		present.animation.play("opened");
		remove(infoBoxes[present]);
		infoBoxes.remove(present);
		
		Instrument.addFlute();
		NGio.unlockMedal(MUSIC_MEDAL);
		
		addFlute(present);
	}
	
	function addGlock(present:OgmoDecal):FlxSprite
	{
		var glockenspiel = new FlxSprite
			( present.x + present.width / 2
			, present.y + present.height
			, "assets/images/props/outside/glockenspiel.png"
			);
		background.add(glockenspiel);
		addHoverTextTo(glockenspiel, "Glockenspiel", selectInstrument.bind(Glockenspiel));
		return glockenspiel;
	}
	
	function addFlute(present:OgmoDecal):FlxSprite
	{
		var flute = new FlxSprite
			( present.x + present.width / 2
			, present.y + present.height
			, "assets/images/props/outside/flute.png"
			);
		background.add(flute);
		addHoverTextTo(flute, "Flute", selectInstrument.bind(Flute));
		return flute;
	}
	
	function selectInstrument(type:InstrumentType):Void
	{
		if (Instrument.type != type)
			Instrument.type = type;
	}
	
	function onKill():Void
	{
		var data:CrimeData = cast Json.parse(openfl.Assets.getText("assets/data/crimeData.json"));
		NGio.unlockMedal(KILLER_MEDAL);
		Calendar.saveSolvedMurder();
		foreground.getByName("killer").animation.play("bleed");
		openSubState(new DialogSubstate(data.victory));
	}
}