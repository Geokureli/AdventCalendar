package states;

import sprites.Present;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.tile.FlxTilemap;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxSort;

import data.Calendar;
import data.DrumKit;
import data.Instrument;
import states.OgmoState;
import sprites.Button;
import sprites.InfoBox;
import sprites.MedalPopup;
import sprites.NPC;
import sprites.Player;
import sprites.Prompt;
import sprites.Sprite;
import sprites.TvBubble;

/**
 * ...
 * @author NInjaMuffin99
 */
class BaseState extends OgmoState 
{
	var camOffset = 0.0;
	var camFollow = new FlxObject();
	
	var player:Player;
	var playerHitbox:FlxObject;
	
	var colliders = new FlxGroup();
	var characters = new FlxGroup();
	var npcs = new FlxTypedGroup<NPC>();
	var touchable = new FlxTypedGroup<FlxObject>();
	var infoBoxes = new Map<FlxObject, InfoBox>();
	
	var geom:FlxTilemap;
	var props:OgmoEntityLayer;
	var foreground:OgmoDecalLayer;
	var background:OgmoDecalLayer;
	var medalAnim:MedalPopup;
	var instrument:FlxButton;
	var cutsceneActive = false;
	var cutsceneTimer = 0.0;
	
	override public function create():Void 
	{
		super.create();
		
		FlxG.mouse.visible = !FlxG.onMobile;
		// #if debug FlxG.debugger.drawDebug = true; #end
		
		loadLevel();
		initEntities();
		initCamera();
		
		add(instrument = new FlxButton(FlxG.width, 0, onInstrumentClick));
		instrument.scrollFactor.set();
		Instrument.onTypeChange.add(updateInstrument);
		updateInstrument(Instrument.type);
		initDrumKit();
		
		add(medalAnim = MedalPopup.getInstance());
	}
	
	function loadLevel() { }
	
	function getLatestLevel(prefix:String):String
	{
		var day = Calendar.day + 1;
		var exists:Bool = false;
		while (day > 0 && !exists)
		{
			exists = openfl.Assets.exists('assets/data/levels/$prefix$day.json');
			day--;
		}
		day++;
		
		trace('$prefix day $day'); 
		return 'assets/data/levels/$prefix$day.json';
	}
	
	function initEntities()
	{
		props = getByName("Props");
		foreground = getByName("Foreground");
		background = getByName("Background");
		
		geom = getByName("Geom");
		colliders.add(geom);
		
		player = cast props.getByName("Player");
		for (child in props.members)
		{
			var sorting = Sorting.Y;
			if (Std.is(child, ISortable))
				sorting = (cast child:ISortable).sorting;
			
			switch(sorting)
			{
				case Sorting.Top, Sorting.None:
				case Sorting.Y: foreground.add(cast props.remove(child));
				case Sorting.Bottom: background.add(cast props.remove(child));
			}
		}
		
		player.updateSprite(Calendar.day);
		characters.add(player);
		if (player.knife != null)
			add(player.knife);
		
		add(playerHitbox = new FlxObject(0, 0, player.width + 6, player.height + 6));
	}
	
	function addHoverText(target:String, ?text:String, ?callback:Void->Void, hoverDis = 20)
	{
		var decal:FlxObject = foreground.getByName(target);
		if (decal == null)
			decal = cast props.getByName(target);
		if (decal == null)
			throw 'can\'t find $target in foreground or props';
		
		addHoverTextTo(decal, text, callback, hoverDis);
	}
	
	function safeAddHoverText(target:String, ?text:String, ?callback:Void->Void, hoverDis = 20)
	{
		var decal:FlxObject = foreground.getByName(target);
		if (decal == null)
			decal = cast props.getByName(target);
		if (decal != null)
			addHoverTextTo(decal, text, callback, hoverDis);
	}
	
	function addHoverTextTo(target:FlxObject, ?text:String, ?callback:Void->Void, hoverDis = 20)
	{
		addHoverTo(target, cast new InfoTextBox(text, callback), hoverDis);
	}
	
	inline function addThumbnailTo(target:FlxObject, ?asset, ?callback:Void->Void)
	{
		var thumbnail:FlxSprite = null;
		if (asset != null)
		{
			thumbnail = new FlxSprite(0, 0, asset);
			thumbnail.x = -thumbnail.width / 2;
			thumbnail.y = -thumbnail.height - 8;
			//hoverDis += Std.int(thumbnail.height);
		}
		
		return addHoverTo
			( target
			, new InfoBox(thumbnail, callback)
			, 0
			);
	}
	
	inline function initArtPresent(present:Present, data:ArtData, ?callback:()->Void)
	{
		var box = addThumbnailTo(present, data.getThumbPath(), openArtPresent.bind(present, data, callback));
		box.sprite.visible = present.opened;
	}
	
	inline function createArtPresent(x, y, ?suffix:String, ?day:Int, data:ArtData, opened = false, ?callback:()->Void)
	{
		var present = new Present(x, y, suffix, day, opened);
		initArtPresent(present, data, callback);
		return present;
	}
	
	function openArtPresent(present:Present, data:ArtData, ?callback:()->Void):Void
	{
		present.open();
		FlxG.sound.play("assets/sounds/presentOpen.mp3", 1);
		openSubState(new GallerySubstate(data, callback));
		infoBoxes[present].sprite.visible = true;
	}
	
	inline function addHoverTo(target:FlxObject, box:InfoBox, hoverDis = 20)
	{
		touchable.add(target);
		box.updateFollow(target);
		box.hoverDis = hoverDis;
		add(infoBoxes[target] = cast box);
		return box;
	}
	
	function initCamera()
	{
		if (FlxG.onMobile)
		{
			var button = new FullscreenButton(10, 10);
			button.scrollFactor.set();
			add(button);
		}
		
		camFollow.setPosition(player.x, player.y - camOffset);
		FlxG.camera.follow(camFollow, FlxCameraFollowStyle.LOCKON, 0.03);
		FlxG.camera.focusOn(camFollow.getPosition());
		FlxG.camera.fade(FlxG.stage.color, 2.5, true);
	}
	
	override public function update(elapsed:Float):Void 
	{
		FlxG.watch.addMouse();
		
		if (!cutsceneActive)
			camFollow.setPosition(player.x, player.y - camOffset);
		
		FlxG.collide(characters, colliders);
		playerHitbox.setPosition(player.x - 3, player.y - 3);
		
		for (child in touchable.members)
		{
			if (infoBoxes.exists(child))
			{
				infoBoxes[child].updateFollow(child);
				infoBoxes[child].alive = false;
			}
		}
		
		FlxG.overlap(playerHitbox, touchable,
			(_, touched)->
			{
				if (infoBoxes.exists(touched))
				{
					infoBoxes[touched].alive = true;
					if (player.interacting)
						infoBoxes[touched].interact();
				}
			}
		);
		
		foreground.sort(FlxSort.byY);
		
		super.update(elapsed);
		
		#if debug
		if (FlxG.keys.justPressed.B)
			FlxG.debugger.drawDebug = !FlxG.debugger.drawDebug;
		#end
	}
	
	function updateInstrument(type:InstrumentType):Void
	{
		instrument.visible = true;
		switch(type)
		{
			case null:
				instrument.visible = false;
			case Glockenspiel:
				instrument.loadGraphic("assets/images/props/instruments/glockenspiel.png");
			case Flute:
				instrument.loadGraphic("assets/images/props/instruments/flute.png");
			case Drums:
				instrument.loadGraphic("assets/images/props/instruments/drums.png");
			case Piano:
				instrument.loadGraphic("assets/images/props/instruments/piano.png");
		}
		
		if (instrument.visible)
		{
			instrument.x = FlxG.width - instrument.width - 2;
			instrument.y = 2;
		}
	}
	
	function onInstrumentClick():Void
	{
		openSubState(new PianoSubstate());
	}
	
	function openUrl(url:String):Void
	{
		var prompt = new Prompt();
		add(prompt);
		var prettyUrl = url;
		if (prettyUrl.indexOf("://") != -1)
			prettyUrl = url.split("://").pop();
		prompt.setup
			( 'Open external page?\n$prettyUrl'
			, FlxG.openURL.bind(url)
			, null
			, remove.bind(prompt)
			);
	}
	
	function initDrumKit()
	{
		if (Instrument.owns(Drums))
		{
			for (name=>piece in foreground.getAllWithPrefix("instruments/"))//FG
				initDrumPiece(name, piece);
			for (name=>piece in background.getAllWithPrefix("instruments/"))//BG
				initDrumPiece(name, piece);
		}
	}
	
	function initDrumPiece(name:String, piece:OgmoDecal)
	{
		if (name == "flute" || name == "drums" || name == "glockenspiel" || name == "piano")
			return;// not a drum piece
		
		if (DrumKit.isPieceFound(cast name))
			piece.kill();
		else
			addHoverTextTo(piece, toTitleCase(name), pickUpPiece.bind(piece, name));
	}
	
	@:pure
	inline function toTitleCase(str:String):String
	{
		return str.charAt(0).toUpperCase() + str.substr(1);
	}
	
	function pickUpPiece(piece:OgmoDecal, name:String):Void
	{
		DrumKit.pickUpPiece(cast name);
		piece.kill();
		infoBoxes[piece].kill();
		infoBoxes.remove(piece);
		var pronoun = switch (cast name:DrumPiece)
		{
			case DrumPiece.bells | DrumPiece.bongo: "them";
			default: "it";
		}
		openSubState(new DialogSubstate
			( toTitleCase(name)
			, 'You can play $pronoun with\nthe drumsticks'
			, DrumKit.isAnyPieceFound()
			)
		);
	}
	
	override function destroy()
	{
		super.destroy();
		
		Instrument.onTypeChange.remove(updateInstrument);
		infoBoxes.clear();
	}
}