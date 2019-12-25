package sprites;

import data.Calendar;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;

/**
 * ...
 * @author NInjaMuffin99
 */
class Present extends Sprite
{
	public var data:ArtData;
	public function new(?X:Float=0, ?Y:Float=0, ?suffix:String, ?day:Int, data) 
	{
		super(X, Y);
		
		this.data = data;
		this.curDay = day;
		
		if (day != null)
			suffix = Std.string(day + 1);
		
		loadGraphic('assets/images/presents/present_$suffix.png', true, 16, 17);
		animation.add("closed", [0]);
		animation.add("opened", [1]);
		animation.play("closed");
		drag.x = drag.y = 5000;
		
		offset.y = height - 8;
		height -= offset.y;
		
	}
	
}