package states;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxSort;

import sprites.Evidence;
import sprites.Player;
import sprites.Sprite;
import sprites.Thumbnail;

/**
 * ...
 * @author NInjaMuffin99
 */
class BaseState extends FlxState 
{
	
	private var player:Player;
	private var playerHitbox:FlxObject;
	private var gameCamera:FlxCamera;
	private var uiCamera:FlxCamera;
	
	
	private var presOverlaps:Int = 0;
	
	private var _grpEntites:FlxTypedGroup<FlxObject>;
	private var _grpCharacters:FlxTypedSpriteGroup<Sprite>;
	private var _grpCollision:FlxGroup;
	
	private var thumbnail:Thumbnail;
	

	override public function create():Void 
	{
		super.create();
	}
	
	private function initCharacterBases():Void
	{
		_grpEntites = new FlxTypedGroup<FlxObject>();
		add(_grpEntites);
		
		_grpCharacters = new FlxTypedSpriteGroup<Sprite>();
		_grpEntites.add(_grpCharacters);
	}
	
	private function initCameras():Void
	{
		FlxG.camera.zoom = 2.5;
		
		if (FlxG.onMobile)
		{
			uiCamera = new FlxCamera(0, 0, FlxG.width, FlxG.height);
			uiCamera.bgColor = FlxColor.TRANSPARENT;
			FlxG.cameras.add(uiCamera);
			
			var button = new FlxButton(10, 10, "Fullscreen", function() FlxG.fullscreen = !FlxG.fullscreen);
			button.cameras = [uiCamera];
			button.scrollFactor.set();
			add(button);
		}
	}
	
	private function initCollision():Void
	{
		_grpCollision = new FlxGroup();
		add(_grpCollision);
	}
	
	override public function update(elapsed:Float):Void 
	{
		FlxG.watch.addMouse();
		
		FlxG.collide(_grpCharacters, _grpEntites);
		FlxG.collide(_grpCharacters, _grpCollision);
		
		_grpCharacters.sort(FlxSort.byY);
		
		super.update(elapsed);
	}
	
}