package states;

import flixel.util.FlxTimer;
import states.CabinState;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxSliceSprite;
import flixel.math.FlxRect;
import flixel.text.FlxBitmapText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

import sprites.AppearingText;

class DialogSubstate extends flixel.FlxSubState
{
	inline static var BUFFER = 20;
	
	var canExit = false;
	var onComplete:()->Void = null;
	var msg:Message;
	var bg:FlxSliceSprite;
	
	public function new(msg:Message, ?onComplete:()->Void):Void
	{
		this.msg = msg;
		this.onComplete = onComplete;
		
		super();
	}
	
	override function create()
	{
		super.create();
		
		bg = new FlxSliceSprite
			( "assets/images/ui/box.png"
			, new FlxRect(2,2,1,1)
			, 3
			, 3
			);
		bg.scrollFactor.set();
		bg.screenCenter(XY);
		add(bg);
		
		FlxTween.tween
			( bg
			,   { x:BUFFER
				, y:BUFFER
				, width:FlxG.width - BUFFER * 2
				, height:FlxG.height - BUFFER * 2
				}
			, 0.15
			, { ease:FlxEase.backOut, onComplete: showText }
			);
	}
	
	function showText(tween:FlxTween)
	{
		
		var body:AppearingText = null;
		body = new AppearingText(msg.body);
		body.scrollFactor.set();
		body.scale.set(2,2);
		body.updateHitbox();
		body.screenCenter(XY);
		body.alignment = CENTER;
		body.visible = false;
		add(body);
		
		var footer:AppearingText = null;
		footer = new AppearingText("Press any key to exit", 0, FlxG.height - BUFFER * 2);
		footer.scrollFactor.set();
		footer.screenCenter(X);
		footer.visible = false;
		add(footer);
		function showFooter()
		{
			footer.visible = true;
			canExit = true;
		}
		
		function showBody()
		{
			body.visible = true;
			body.appear(0.75, 0.1, showFooter);
		}
		
		var bodyAppearTime = 0.0;
		
		if (msg.title != null)
		{
			var title:AppearingText = null;
			title = new AppearingText(msg.title, 0, bg.y + BUFFER / 2);
			title.scrollFactor.set();
			title.scale.set(2,2);
			title.updateHitbox();
			title.screenCenter(X);
			title.alignment = CENTER;
			title.width = bg.width;
			title.appear(0.25, 0, showBody);
			add(title);
			bodyAppearTime = 0.25;
		}
	}
	
	override function update(elapsed)
	{
		super.update(elapsed);
		
		if (canExit && FlxG.keys.pressed.ANY)
			close();
	}
	
	override function destroy()
	{
		super.destroy();
		
		msg = null;
		onComplete = null;
		bg = null;
	}
}