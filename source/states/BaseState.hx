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
import states.OgmoState;
import sprites.InfoBox;
import sprites.Player;
import sprites.Sprite;

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
	var uiCamera:FlxCamera;
	
	var colliders = new FlxGroup();
	var characters = new FlxGroup();
	var touchable = new FlxTypedGroup<FlxObject>();
	var infoBoxes = new Map<FlxObject, InfoBox>();
	
	var geom:FlxTilemap;
	var props:OgmoEntityLayer;
	var foreground:OgmoDecalLayer;
	var background:OgmoDecalLayer;
	
	override public function create():Void 
	{
		super.create();
		
		FlxG.mouse.visible = !FlxG.onMobile;
		
		loadLevel();
		initEntities();
		initCamera();
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
			foreground.add(cast props.remove(child));
		
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
			uiCamera = new FlxCamera(0, 0, FlxG.width, FlxG.height);
			uiCamera.bgColor = FlxColor.TRANSPARENT;
			FlxG.cameras.add(uiCamera);
			FlxCamera.defaultCameras = [FlxG.camera];
			
			var button = new FlxButton(10, 10, "Fullscreen", function() FlxG.fullscreen = !FlxG.fullscreen);
			button.cameras = [uiCamera];
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
		
		FlxG.overlap(player, touchable,
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
}