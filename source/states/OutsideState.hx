package states;

import haxe.Json;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxMath;

import data.Calendar;
import data.DrumKit;
import data.Instrument;
import data.NGio;
import sprites.Present;
import sprites.Snow;
import states.CabinState;
import states.GallerySubstate;
import states.OgmoState;

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
		
		addInstrumentPresent("czyszy", Glockenspiel);
		addInstrumentPresent("colebob", Flute);
		addInstrumentPresent("carmet", Drums, onPickUpDrumSticks);
		addInstrumentPresent("albegian", Piano);
		
		addArtPresent("NickConter", 30);
		
		if (Calendar.day == 12)
			initCrime();
		
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
				
				var nameFound = Calendar.checkUnveiledArtist(name);
				while(!nameFound && ~/\d$/.match(name))
				{
					name = name.substr(0, name.length - 1);
					nameFound = Calendar.checkUnveiledArtist(name);
				}
				
				if (nameFound)
				{
					if (name == "RGPAnims")
					{
						var height = child.height;
						var suffix = Calendar.day == 24 ? "20" : Std.string(Calendar.day + 1);
						var path = '/assets/images/snowSprite/RGPAnims$suffix.png';
						if (openfl.Assets.exists(path))
						{
							child.loadGraphic(path);
							child.setBottomHeight(Std.int(child.height / 3));
						}
					}
					
					if (name == "Camuri")
						child.animation.curAnim.frameRate = 8;
					
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
	
	inline function addPresent(artist:String, opened = false, ?onOpen:()->Void):Present
	{
		var present:Present = cast foreground.getByName("present_" + artist);
		if (present != null)
		{
			present.setup(opened);
			present.immovable = true;
			colliders.add(present);
			if (onOpen == null)
				addHoverTextTo(present, onOpen);
		}
		return present;
	}
	
	function addArtPresent(artist:String, saveIndex:Int, ?onOpen:()->Void):Void
	{
		var present = addPresent(artist.toLowerCase(), Calendar.openedPres[saveIndex]);
		present.ID = saveIndex;
		initArtPresent
			( present
			, { artist:artist, antiAlias:false, fileExt:"png" }
			, onOpen
			);
	}
	
	// --- INSTRUMENTS
	
	function addInstrumentPresent(musician:String, type:InstrumentType, ?onOpen:()->Void):Void
	{
		var opened = Instrument.owns(type);
		var present = addPresent(musician, opened);
		if (present != null)
		{
			if (opened)
				addInstrument(present, type);
			else
			{
				addHoverTextTo(present, ()->
					{
						onInstrumentPresentOpen(present, type);
						
						if (onOpen != null)
							onOpen();
					}
				);
			}
		}
	}
	
	function onInstrumentPresentOpen(present:Present, type:InstrumentType):Void
	{
		present.open();
		remove(infoBoxes[present]);
		infoBoxes.remove(present);
		
		Instrument.add(type);
		NGio.unlockMedal(MUSIC_MEDAL);
		
		addInstrument(present, type);
	}
	
	function addInstrument(present:Present, type:InstrumentType)
	{
		var name = type.getName();
		var instrument = new FlxSprite
			( present.x + present.width / 2
			, present.y + present.height
			, 'assets/images/props/instruments/${name.toLowerCase()}.png'
			);
		background.add(instrument);
		addHoverTextTo(instrument, name, selectInstrument.bind(type));
		return instrument;
	}
	
	function selectInstrument(type:InstrumentType):Void
	{
		if (Instrument.type != type)
			Instrument.type = type;
	}
	
	function onPickUpDrumSticks():Void
	{
		initDrumKit();
		openSubState(
			new DialogSubstate
				( "You got drumsticks!"
				, "But is there anything\naround here to drum on?"
				)
		);
	}
	
	// --- CRIME
	
	function initCrime():Void
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
	
	function onKill():Void
	{
		var data:CrimeData = cast Json.parse(openfl.Assets.getText("assets/data/crimeData.json"));
		NGio.unlockMedal(KILLER_MEDAL);
		Calendar.saveSolvedMurder();
		foreground.getByName("killer").animation.play("bleed");
		openSubState(DialogSubstate.fromMessage(data.victory));
	}
}