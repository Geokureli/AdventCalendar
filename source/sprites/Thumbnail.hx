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
	
	public var overlappin:Bool = false;
	private var curThumb:Int = -1;

	public function new(?X:Float=0, ?Y:Float=0, theDay:Int) 
	{
		super(X, Y);
		antialiasing = true;
	}
	
	public function newThumb(newDay:Int):Void
	{
		// igloo shit
		if (newDay == -1)
		{
			loadGraphic(AssetPaths.thumb_tom__png);
			curThumb = -1;
		}
		
		if (curThumb != newDay)
		{
			if (newDay > Calendar.data.length - 1)
			{
				loadGraphic(AssetPaths.thumbDefault__png);
			}
			else
			{
				loadGraphic(Calendar.data[newDay].getThumbPath());
			}
			
			curThumb = newDay;
		}
	}
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
		FlxG.watch.addQuick("Overlappin", overlappin);
		FlxG.watch.addQuick("da alpha", alpha);
		
		if (overlappin)
		{
			if (alpha < 1)
			{
				alpha += 0.025;
			}
		}
		else
		{
			
			if (alpha > 0)
			{
				alpha -= 0.5 * FlxG.elapsed;
			}
			else
			{
				alpha = 0;
			}
		}
		
		overlappin = false;
		
		
		
	}
	
}