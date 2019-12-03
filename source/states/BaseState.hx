package states;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.tile.FlxTilemap;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;

import data.Calendar;
import states.OgmoState;
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
	var geom:FlxTilemap;
	
	var colliders = new FlxGroup();
	var characters = new FlxGroup();
	
	override public function create():Void 
	{
		super.create();
		
		FlxG.mouse.visible = !FlxG.onMobile;
		
		loadLevel();
		initEntities();
		initCamera();
	}
	
	function loadLevel() { }
	
	function initEntities()
	{
		var props:OgmoEntityLayer = getByName("Props");
		// var fg:OgmoDecalLayer = getByName("Foreground");
		// var bg:OgmoDecalLayer = getByName("Background");
		geom = getByName("Geom");
		colliders.add(geom);
		
		player = props.getByName("Player");
		player.updateSprite(Calendar.day);
		characters.add(player);
		
		add(playerHitbox = new FlxObject(0, 0, player.width + 6, player.height + 6));
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
		
		FlxG.camera.follow(camFollow, FlxCameraFollowStyle.LOCKON, 0.03);
		FlxG.camera.fade(FlxG.stage.color, 2.5, true);
	}
	
	override public function update(elapsed:Float):Void 
	{
		camFollow.setPosition(player.x, player.y - camOffset);
		FlxG.watch.addMouse();
		
		FlxG.collide(characters, colliders);
		playerHitbox.setPosition(player.x - 3, player.y - 3);
		
		super.update(elapsed);
	}
}