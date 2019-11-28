package sprites;

import flixel.system.FlxAssets.FlxGraphicAsset;

/**
 * ...
 * @author NInjaMuffin99
 */
class Prop extends Sprite
{
	public function new(?x, ?y, ?graphic) 
	{
		super(x, y, graphic);
		
		drag.x = drag.y = 5000;
		
		offset.y = height - 8;
		height -= offset.y;
	}
}