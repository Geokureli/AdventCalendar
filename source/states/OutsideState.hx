package states;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxMath;

import states.OgmoState;

class OutsideState extends BaseState
{
	inline static var CLOUD_BOB_DIS = 50;
	inline static var CLOUD1_PERIOD = 10.0;
	inline static var CLOUD2_PERIOD = 15.0;
	
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
		sky.scrollFactor.set(0.05, 0.05);
		
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
		
		var ground = background.getByName("ground");
		var shine = background.getByName("shine");
		ground.scrollFactor.set(0.6, 0.6);
		shine.scrollFactor.x = ground.scrollFactor.x * 0.6;
		shine.scrollFactor.y = ground.scrollFactor.y * 0.85;
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
		
		for (child in foreground.members)
		{
			if (child.graphic != null && child.graphic.assetsKey.indexOf("snowSprite/") != -1)
			{
				var name = child.graphic.assetsKey.split("snowSprite/").pop();
				name = name.substr(0, name.length - 4);
				addInfoBoxTo(child, name, FlxG.openURL.bind('https://$name.newgrounds.com'));
			}
		}
	}
	
	override function initCamera()
	{
		super.initCamera();
		
		FlxG.camera.focusOn(player.getPosition());
		FlxG.camera.bgColor = 0xFF15122d;
	}
	
	inline static var TREE_FADE_TIME = 3.0;
	inline static var GYRADOS_TIME = 2 * 60.0;
	inline static var MAX_CAM_OFFSET = 80;
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
		
		if (player.overlaps(toCabin) #if debug || FlxG.keys.justPressed.O #end)
			FlxG.switchState(new CabinState(true));
		
		if (player.y < top)
			tree.alpha -= elapsed / TREE_FADE_TIME;
		else
			tree.alpha += elapsed / TREE_FADE_TIME;
		
		if (tree.alpha < 1)
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
}