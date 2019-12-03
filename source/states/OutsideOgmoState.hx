package states;

import flixel.FlxG;
import flixel.FlxSprite;
import states.OgmoState;

class OutsideOgmoState extends BaseState
{
	inline static var MAX_OFFSET = 120;
	inline static var MIN_OFFSET = 0;
	
	var gyradosTmr:Float = 0;
	
	override function loadLevel():Void
	{
		parseLevel("assets/data/levels/outside0.json");
		
		// FlxG.debugger.drawDebug = true;
	}
	
	override function initEntities()
	{
		super.initEntities();
		
		var bg:OgmoDecalLayer = getByName("Background");
		
		var sky:FlxSprite = bg.getByName("sky");
		sky.scrollFactor.set(0.05, 0.05);
		
		var clouds2:FlxSprite = bg.getByName("clouds2");
		clouds2.scrollFactor.set(0.1, 0);
		clouds2.alpha = 0.5;
		
		var clouds1:FlxSprite = bg.getByName("clouds1");
		clouds1.scrollFactor.set(0.2, 0);
		clouds1.alpha = 0.5;
		
		var mountains:FlxSprite = bg.getByName("mountains");
		mountains.scrollFactor.set(0.3, 0.3);
		
		var snow1:FlxSprite = bg.getByName("snow1");
		snow1.scrollFactor.set(0.4, 0.4);
		
		var ground:FlxSprite = bg.getByName("ground");
		var shine:FlxSprite = bg.getByName("shine");
		ground.scrollFactor.set(0.6, 0.6);
		shine.scrollFactor.x = ground.scrollFactor.x * 0.85;
		shine.scrollFactor.y = ground.scrollFactor.y;
		
		var gyrados:FlxSprite = bg.getByName("gyrados");
		gyrados.scrollFactor.set(0.6, 0.6);
		gyrados.alpha = 0;
		
		var fire:FlxSprite = bg.getByName("fire");
		fire.alpha = 1.0;
		fire.scrollFactor.set(0.6, 0.6);
	}
	
	override function initCamera()
	{
		super.initCamera();
		
		camera.focusOn(player.getPosition());
	}
	
	override public function update(elapsed:Float):Void 
	{
		var gyrados:FlxSprite = (getByName("Background"):OgmoDecalLayer).getByName("gyrados");
		var fg:OgmoDecalLayer = getByName("Foreground");
		var tree:FlxSprite = fg.getByName("tree");
		
		final top = tree.y - 20;
		final height = FlxG.camera.maxScrollY - top;
		camOffset = MIN_OFFSET + (height - (player.y - top)) / height * (MAX_OFFSET - MIN_OFFSET);
		
		super.update(elapsed);
		trace(FlxG.camera.scroll.x);
		
		if (player.x < FlxG.camera.minScrollX - 15 #if debug || FlxG.keys.justPressed.O #end)
			FlxG.switchState(new CabinState(true));
		
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
		// 	else
			
		// 	if (camOffset < 90)
		// 	{
		// 		camOffset += 10 * FlxG.elapsed;
		// 	}
		// 	else
		// 	{
		// 		tree.alpha -= 0.3 * FlxG.elapsed;
		// 	}
		// }
		// else
		// {
		// 	if (camOffset > 70)
		// 	{
		// 		camOffset -= 10 * FlxG.elapsed;
		// 	}
		// }
		
		// if (FlxG.overlap(player, treeOGhitbox))
		// {
		// 	if (FlxG.keys.justPressed.SPACE)
		// 		FlxG.openURL("https://www.newgrounds.com/portal/view/721061");
			
		// 	if (tree.alpha > 0.55)
		// 	{
		// 		tree.alpha -= 0.025;
		// 	}
		// }
		// else
		// {
		// 	if (tree.alpha < 1 && player.y > collisionBounds.y + 20)
		// 	{
		// 		tree.alpha += 0.025;
		// 	}
		// }
	}
}