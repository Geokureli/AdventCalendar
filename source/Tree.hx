package;

import flixel.FlxSprite;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxGraphicAsset;

/**
 * ...
 * @author NInjaMuffin99
 */
class Tree extends FlxSprite 
{
	public var treeSize:FlxRect;

	public function new(?X:Float=0, ?Y:Float=0, ?SimpleGraphic:FlxGraphicAsset) 
	{
		super(X, Y);
		
		loadGraphic(AssetPaths.christmasTree__png);
		
		treeSize = new FlxRect(0, 0, width, height);
		
		offset.y = height - 16;
		height = 16;
		
		offset.x = 20;
		
		width -= offset.x * 2;
		
		treeSize.width = width;
		
		
		immovable = true;
		
		
	}
	
}