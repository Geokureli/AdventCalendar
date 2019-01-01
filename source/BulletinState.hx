package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.math.FlxPoint;
import flixel.text.FlxText;

/**
 * ...
 * @author ...
 */
class BulletinState extends FlxState 
{
	
	private var camFollow:FlxObject;
	
	private var debugSquare:FlxSprite;
	private var debugText:FlxText;

	override public function create():Void 
	{
		var bg:FlxSprite = new FlxSprite().loadGraphic(AssetPaths.board2__png);
		bg.setGraphicSize(Std.int(bg.width * 2));
		bg.updateHitbox();
		add(bg);
		
		for (i in 0...picPosArray.length)
		{
			var ev:FlxSprite = new FlxSprite(picPosArray[i][0], picPosArray[i][1]).loadGraphic("assets/images/loganStuff/E" + (i + 1) +".png");
			add(ev);
		}
		
		
		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		
		FlxG.camera.follow(camFollow, null, 0.1);
		FlxG.camera.zoom = 0.5;
		
		debugSquare = new FlxSprite(0, 0);
		debugSquare.alpha = 0.5;
		add(debugSquare);
		
		debugText = new FlxText(0, 0, 0, "", 32);
		add(debugText);
		
		super.create();
	}
	
	private var mousePosOld:FlxPoint = new FlxPoint();
	
	override public function update(elapsed:Float):Void 
	{
		if (FlxG.mouse.justPressed)
		{
			mousePosOld.set(FlxG.mouse.x, FlxG.mouse.y);
			
		}
		
		if (FlxG.mouse.pressed)
		{
			debugText.setPosition(FlxG.mouse.x, FlxG.mouse.y - 40);
			debugText.text = Std.int(mousePosOld.x - FlxG.mouse.x) + ", " + Std.int(mousePosOld.y - FlxG.mouse.y);
		}
		
		
		camFollow.velocity.set();
		
		var speed:Float = 220;
		
		if (FlxG.keys.pressed.W)
		{
			camFollow.velocity.y = -speed;
		}
		if (FlxG.keys.pressed.S)
		{
			camFollow.velocity.y = speed;
		}
		if (FlxG.keys.pressed.A)
		{
			camFollow.velocity.x = -speed;
		}
		if (FlxG.keys.pressed.D)
		{
			camFollow.velocity.x = speed;
		}
		
		super.update(elapsed);
	}
	
	private var picPosArray:Array<Dynamic> =
	[
		[140, 290],
		[190, 1600],
		[720, 800],
		[950, 2230],
		[1430, 1370],
		[2430, 800],
		[3340, 1640],
		[2556, 1750],
		[3270, 170],
		[1445, 220]
	];
}