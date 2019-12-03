package states;

import flixel.FlxG;
import flixel.FlxSprite;
import states.OgmoState;

class OutsideState extends BaseState
{
	inline static var TREE_FADE_TIME = 5.0;
	inline static var MAX_OFFSET = 50;
	inline static var MIN_OFFSET = 0;
	
	var gyradosTmr:Float = 0;
	
	override function loadLevel():Void
	{
		parseLevel("assets/data/levels/outside0.json");
		
		FlxG.debugger.drawDebug = true;
	}
	
	override function initEntities()
	{
		super.initEntities();
		
		var sky:FlxSprite = background.getByName("sky");
		sky.scrollFactor.set(0.05, 0.05);
		
		var clouds2:FlxSprite = background.getByName("clouds2");
		clouds2.scrollFactor.set(0.1, 0);
		clouds2.alpha = 0.5;
		
		var clouds1:FlxSprite = background.getByName("clouds1");
		clouds1.scrollFactor.set(0.2, 0);
		clouds1.alpha = 0.5;
		
		var mountains:FlxSprite = background.getByName("mountains");
		mountains.scrollFactor.set(0.3, 0.3);
		
		var snow1:FlxSprite = background.getByName("snow1");
		snow1.scrollFactor.set(0.4, 0.4);
		
		var ground:FlxSprite = background.getByName("ground");
		var shine:FlxSprite = background.getByName("shine");
		ground.scrollFactor.set(0.6, 0.6);
		shine.scrollFactor.x = ground.scrollFactor.x * 0.85;
		shine.scrollFactor.y = ground.scrollFactor.y;
		
		var gyrados:FlxSprite = background.getByName("gyrados");
		gyrados.scrollFactor.set(0.6, 0.6);
		gyrados.alpha = 0;
		
		var fire:FlxSprite = background.getByName("fire");
		fire.alpha = 1.0;
		fire.scrollFactor.set(0.6, 0.6);
		
		// reshape tree
		var tree:FlxSprite = foreground.getByName("tree");
		tree.height = 20;
		tree.y += tree.frameHeight - tree.height;
		tree.offset.y += tree.frameHeight - tree.height;
	}
	
	override function initCamera()
	{
		super.initCamera();
		
		camera.focusOn(player.getPosition());
	}
	
	override public function update(elapsed:Float):Void 
	{
		var gyrados:FlxSprite = (getByName("Background"):OgmoDecalLayer).getByName("gyrados");
		var tree:FlxSprite = foreground.getByName("tree");
		
		final top = tree.y - 20;
		final height = FlxG.camera.maxScrollY - top;
		camOffset = MIN_OFFSET + (height - (player.y - top)) / height * (MAX_OFFSET - MIN_OFFSET);
		
		super.update(elapsed);
		
		if (player.x < FlxG.camera.minScrollX - 15 #if debug || FlxG.keys.justPressed.O #end)
			FlxG.switchState(new CabinState(true));
		
		if (player.y < tree.y)
			tree.alpha -= elapsed / TREE_FADE_TIME;
		else
			tree.alpha += elapsed / TREE_FADE_TIME;
		
		//TODO: Gyrados
		// if (player.y < tree.y - 20)
		// {
		// 	gyradosTmr += FlxG.elapsed;
		// 	if (gyradosTmr >= 170)
		// 	{
		// 		gyrados.velocity.x = 2;
				
		// 		if (gyrados.x >= 280)
		// 		{
		// 			if (gyrados.alpha > 0)
		// 			{
		// 				gyrados.alpha -= 0.4 * FlxG.elapsed;
		// 			}
		// 			else
		// 			{
		// 				gyrados.kill();
		// 			}
		// 		}
		// 		else if (gyrados.alpha < 1)
		// 		{
		// 			gyrados.alpha += 0.4 * FlxG.elapsed;
		// 		}
		// 	}
		// }
	}
}