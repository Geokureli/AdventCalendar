package sprites;

import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets.FlxGraphicAsset;

/**
 * This is a bullshit class IDK lOLOL
 * @author NInjaMuffin99
 */
class Sprite extends FlxSprite 
{
	public var curDay:Int = 0;
	public var nameShit:String = "";
	
	public function new(?X:Float=0, ?Y:Float=0, ?SimpleGraphic:FlxGraphicAsset) 
	{
		super(X, Y, SimpleGraphic);
	}
}