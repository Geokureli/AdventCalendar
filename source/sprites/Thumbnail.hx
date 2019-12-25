package sprites;

import data.Calendar;
import flixel.FlxG;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

/**
 * ...
 * @author NInjaMuffin99
 */
class Thumbnail extends Sprite
{
	inline static var INTRO_TIME = 0.25;
	public var overlappin:Bool = false;
	public var time = 0.0;
	
	var curThumb:String = null;

	public function new(?X:Float=0, ?Y:Float=0) 
	{
		super(X, Y);
		visible = false;
	}
	
	public function newThumb(data:ArtData):Void
	{
		if (curThumb != data.getThumbPath())
		{
			curThumb = data.getThumbPath();
			loadGraphic(curThumb);
		}
	}
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
		FlxG.watch.addQuick("Overlappin", overlappin);
		FlxG.watch.addQuick("da alpha", alpha);
		
		if (overlappin)
		{
			if (time < 1)
			{
				time += elapsed / INTRO_TIME;
				if (time > 1)
					time = 1;
			}
		}
		else
		{
			if (time > 0)
			{
				time -= elapsed / INTRO_TIME;
				if (time < 0)
					time = 0;
			}
		}
		
		scale.y = FlxEase.backOut(time);
		visible = time > 0;
		
		overlappin = false;
	}
	
}