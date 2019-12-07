//SHOUTOUTS TO GAMEPOPPER FOR THE BALLIN TUTORIAL
//https://gamepopper.co.uk/2014/08/26/haxeflixel-making-a-custom-preloader/
package;

import flash.Lib;
import flash.events.Event;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Shape;
import openfl.display.Sprite;
import openfl.geom.Rectangle;

@:bitmap("assets/images/preloader/cane.png"    ) class Cane     extends BitmapData { }
@:bitmap("assets/images/preloader/caneMask.png") class CaneMask extends BitmapData { }
@:bitmap("assets/images/preloader/stripes.png" ) class Stripes  extends BitmapData { }
@:bitmap("assets/images/preloader/loading.png" ) class Loading  extends BitmapData { }
@:bitmap("assets/images/preloader/start.png"   ) class Start    extends BitmapData { }
@:bitmap("assets/images/preloader/caneAnim.png") class CaneAnim extends BitmapData { }
@:bitmap("assets/images/preloader/xmasTank.png") class XmasTank extends BitmapData { }

class Preloader extends flixel.system.FlxBasePreloader
{
	inline static var STRIPE_LOOP = 149;
	inline static var CANE_THICKNESS = 60;
	inline static var STRIPE_MAX = 326;
	inline static var LOOP_TIME = 1.0;
	
	override public function new(MinDisplayTime:Float = 1, ?AllowedURLs:Array<String>) 
	{
		super(MinDisplayTime, AllowedURLs);
	}
	
	var cane:Bitmap;
	var caneAnim:SpriteSheet;
	var stripes:Bitmap;
	var maskShape:Shape;
	var outroStarted:Bool = false;
	var loadingText:Loading;
	var startText:Start;
	
	override private function create():Void 
	{
		this._width = Lib.current.stage.stageWidth;
		this._height = Lib.current.stage.stageHeight;
		
		var tank = new Bitmap(new XmasTank(106, 106));
		tank.scaleX *= 3;
		tank.scaleY *= 3;
		tank.x = (this._width - 106 * tank.scaleX) / 2;
		tank.y = 25;
		addChild(tank);
		
		cane = new Bitmap(new Cane(400, 150));
		var caneMask = new Bitmap(new CaneMask(0, 0));
		addChild(cane);
		addChild(stripes = new Bitmap(new Stripes(0, 0)));
		addChild(caneMask);
		cane.smoothing = false;
		cane.x = (this._width  - 400) / 2;
		cane.y = (this._height - 150) / 2 + 175;
		caneMask.smoothing = false;
		caneMask.transform.colorTransform.color = Lib.current.stage.color;
		caneMask.x = cane.x;
		caneMask.y = cane.y + 150 - CANE_THICKNESS + 2;
		stripes.smoothing = false;
		stripes.x = caneMask.x;
		stripes.y = caneMask.y;
		
		maskShape = new Shape();
		maskShape.graphics.beginFill(0xFFFFFF);
		maskShape.graphics.drawRect(0, 0, STRIPE_MAX, CANE_THICKNESS);
		maskShape.graphics.endFill();
		maskShape.x = caneMask.x;
		maskShape.y = caneMask.y;
		stripes.mask = maskShape;
		
		var loadingText = new Bitmap(new Loading(0, 0));
		loadingText.smoothing = false;
		loadingText.x = cane.x + 30;
		loadingText.y = cane.y + 30;
		addChild(loadingText);
		
		var startText = new Bitmap(new Loading(0, 0));
		startText.smoothing = false;
		startText.x = loadingText.x + 30;
		startText.y = loadingText.y + 30;
		
		super.create();
	}
	
	override private function destroy():Void 
	{
		stripes = null;
		mask = null;
		
		super.destroy();
	}
	
	override function onEnterFrame(e:Event)
	{
		var time = Date.now().getTime() - _startTime;
		var min = minDisplayTime * 1000;
		
		var readyToDestroy = false;
		if (caneAnim != null)
		{
			readyToDestroy = caneAnim.finished;
			caneAnim.update();
		}
		
		if (_loaded && (min <= 0 || time / min >= 1) && !readyToDestroy)
		{
			_loaded = false;
			outroStarted = true;
		}
		else if (readyToDestroy)
			_loaded = true;
		
		super.onEnterFrame(e);
		
		if (stripes != null)
		{
			var oldX = stripes.x;
			stripes.x = cane.x
				+ Math.round(-STRIPE_LOOP * (time / 1000.0 / LOOP_TIME)) % STRIPE_LOOP;
			stripes.x = Math.floor(stripes.x / 4) * 4;
			
			if (oldX < stripes.x && outroStarted)
			{
				stripes.x = cane.x;// - STRIPE_LOOP;
				addChild(caneAnim = new SpriteSheet(new CaneAnim(0, 0), 168, 150, [0,0,0,0,1,2,3,4,5,6,7,7,7,7,7,7]));
				caneAnim.x = cane.x + cane.width - caneAnim.width;
				caneAnim.y = cane.y;
				stripes = null;
			}
		}
	}
	
	override public function update(percent:Float):Void 
	{
		super.update(percent);
		
		maskShape.width = STRIPE_MAX * percent;
		if (caneAnim != null)
			caneAnim.update();
	}
}

class SpriteSheet extends Sprite
{
	public var finished(get, never):Bool;
	inline function get_finished() return time > frames.length * frameTime;
	
	var frames:Array<Int>;
	var frameTime = 0.0;
	var time = 0.0;
	
	override function get_width():Float return scrollRect.width;
	override function get_height():Float return scrollRect.height;
	
	public function new(bitmapData:BitmapData, width:Int, height:Int, frames:Array<Int>, frameRate = 15)
	{
		this.frameTime = 1 / frameRate;
		this.frames = frames;
		super();
		addChild(new Bitmap(bitmapData));
		scrollRect = new Rectangle(0, 0, width, height);
	}
	
	inline public function update():Void
	{
		time += 1 / Lib.current.stage.frameRate;
		var frame = Math.floor(time / frameTime);
		if (frame >= frames.length)
			frame = frames.length -1;
		var rect = scrollRect;
		rect.x = rect.width * frames[frame];
		scrollRect = rect;
	}
}