package states;

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
	private var bg:FlxSprite;
	
	private var debugSquare:FlxSprite;
	private var debugText:FlxText;
	
	public static var evAmount:Array<Bool> =
	[
		false,
		false,
		false,
		false,
		false,
		false,
		false,
		false,
		false,
		false
	];

	override public function create():Void 
	{
		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.fadeOut(2, FlxG.sound.music.volume / 2);
		}
		
		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		
		FlxG.camera.follow(camFollow, null, 0.02);
		FlxG.camera.zoom = 0.5;
		FlxG.camera.setScrollBounds(bg.x, bg.width, bg.y, bg.height);
		
		debugSquare = new FlxSprite(0, 0);
		debugSquare.alpha = 0.5;
		add(debugSquare);
		
		debugText = new FlxText(-400, -250, 0, "", 36);
		debugText.scrollFactor.set();
		if (!FlxG.onMobile)
			debugText.text = "arrow keys to move between pics\nWASD to move freely\nSpacebar to exit";
		add(debugText);
		
		super.create();
	}
	
	private var mousePosOld:FlxPoint = new FlxPoint();
	private var curEv:Int = 0;
	
	override public function update(elapsed:Float):Void 
	{
		if (FlxG.mouse.justPressed)
		{
			mousePosOld.set(FlxG.mouse.x, FlxG.mouse.y);
		}
		
		if (camFollow.x < 0)
		{
			camFollow.x = 0;
		}
		if (camFollow.x > bg.width)
		{
			camFollow.x = bg.width;
		}
		if (camFollow.y < 0)
		{
			camFollow.y = 0;
		}
		if (camFollow.y > bg.height)
			camFollow.y = bg.height - 10;
		
		
		/*
		debugText.setPosition(FlxG.mouse.x, FlxG.mouse.y - 40);
		debugText.text = Std.int(FlxG.mouse.x) + ", " + Std.int(FlxG.mouse.y);
		*/
		
		if (FlxG.keys.justPressed.LEFT)
		{
			curEv -= 1;
			updateCamPos();
		}
		if (FlxG.keys.justPressed.RIGHT)
		{
			curEv += 1;
			updateCamPos();
		}
		
		if (FlxG.keys.justPressed.SPACE)
			FlxG.switchState(new CabinState());
		
		if (FlxG.onMobile)
		{
			if (FlxG.touches.list[0].justPressed)
			{
				curEv += 1;
				updateCamPos();
			}
		}
		
		camFollow.velocity.set();
		
		var speed:Float = 220;
		
		if (FlxG.keys.pressed.SHIFT)
			speed *= 4;
		
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
	
	private function updateCamPos():Void
	{
		if (curEv < 0)
			curEv = camPosArr.length - 1;
		if (curEv >= camPosArr.length)
		{
			curEv = 0;
			if (FlxG.onMobile)
			{
				FlxG.switchState(new CabinState());
			}
			
		}
		
		camFollow.setPosition(camPosArr[curEv][0], camPosArr[curEv][1]);
	}
	
	private var picPosArray:Array<Dynamic> =
	[
		[140, 290],
		[176, 1596],
		[707, 820],
		[935, 2230],
		[1412, 1358],
		[2430, 800],
		[3318, 1635],
		[2532, 1746],
		[3270, 170],
		[1440, 250]
	];
	
	private var stringPosArr:Array<Dynamic> = 
	[
		[270, 350],
		[760, 830],
		[1180, 835],
		[1310, 280],
		[1460, 260],
		[2366, 804],
		[3237, 183],
		[2363, 1390],
		[2398, 1438],
	];
	private var camPosArr:Array<Dynamic> =
	[
		[500, 600],
		[650, 1880],
		[1110, 1180],
		[1400, 2410],
		[2000, 1810],
		[2975, 1110],
		[3800, 510],
		[3750, 2040],
		[2966, 2230],
		[2017, 900]
	];
}