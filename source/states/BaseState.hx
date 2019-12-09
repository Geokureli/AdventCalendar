package states;

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
import data.Instrument;
import states.OgmoState;
import sprites.Button;
import sprites.InfoBox;
import sprites.MedalPopup;
import sprites.Player;
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
	var touchable = new FlxTypedGroup<FlxObject>();
	var infoBoxes = new Map<FlxObject, InfoBox>();
	
	var geom:FlxTilemap;
	var props:OgmoEntityLayer;
	var foreground:OgmoDecalLayer;
	var background:OgmoDecalLayer;
	var medalAnim:MedalPopup;
	var instrument:FlxButton;
	
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
		
		add(playerHitbox = new FlxObject(0, 0, player.width + 6, player.height + 6));
	}
	
	function addInfoBox(target:String, ?text:String, ?callback:Void->Void, hoverDis = 20)
	{
		var decal:FlxObject = foreground.getByName(target);
		if (decal == null)
			decal = cast props.getByName(target);
		if (decal == null)
			throw 'can\'t find $target in foreground or props';
		
		addInfoBoxTo(decal, text, callback, hoverDis);
	}
	
	function safeAddInfoBox(target:String, ?text:String, ?callback:Void->Void, hoverDis = 20)
	{
		var decal:FlxObject = foreground.getByName(target);
		if (decal == null)
			decal = cast props.getByName(target);
		if (decal != null)
			addInfoBoxTo(decal, text, callback, hoverDis);
	}
	
	function addInfoBoxTo(target:FlxObject, ?text:String, ?callback:Void->Void, hoverDis = 20)
	{
		touchable.add(target);
		add(infoBoxes[target] = new InfoBox(text, callback, target.x + target.width / 2, target.y - hoverDis));
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
		camFollow.setPosition(player.x, player.y - camOffset);
		FlxG.watch.addMouse();
		
		FlxG.collide(characters, colliders);
		playerHitbox.setPosition(player.x - 3, player.y - 3);
		
		for (child in touchable.members)
		{
			if (infoBoxes.exists(child))
				infoBoxes[child].alive = false;
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
	}
	
	function updateInstrument(type:InstrumentType):Void
	{
		instrument.visible = true;
		switch(type)
		{
			case null: instrument.visible = false;
			case Glockenspiel: instrument.loadGraphic("assets/images/props/outside/glockenspiel.png");
		}
		
		if (instrument.visible)
		{
			instrument.x = FlxG.width - instrument.width - 2;
			instrument.y = instrument.height + 2;
		}
	}
	
	function onInstrumentClick():Void
	{
		openSubState(new PianoSubstate());
	}
	
	override function destroy()
	{
		super.destroy();
		
		Instrument.onTypeChange.remove(updateInstrument);
	}
}