package sprites;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;

class Fire extends FlxTypedGroup<FlxSprite>
{
	static final graphics = 
		[ new openfl.display.BitmapData(2, 2, false, 0xFFff0000)
		, new openfl.display.BitmapData(2, 2, false, 0xFFff8000)
		, new openfl.display.BitmapData(2, 2, false, 0xFFffff00)
		, new openfl.display.BitmapData(1, 1, false, 0xFFff0000)
		, new openfl.display.BitmapData(1, 1, false, 0xFFff8000)
		, new openfl.display.BitmapData(1, 1, false, 0xFFffff00)
		];
	
	public function new(avgSpacing = 25)
	{
		final density = 1 / avgSpacing / avgSpacing;
		final camera = FlxG.camera;
		
		super(Math.floor(camera.width * camera.height * density));
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		final camera = FlxG.camera;
		for (i in 0...1)
		{
			var flame = new FlxSprite
				( camera.scroll.x + FlxG.random.float(0, camera.width)
				, camera.scroll.y + FlxG.random.float(0, camera.height)
				, graphics[FlxG.random.int(0, graphics.length - 1)]
				);
			add(flame);
			flame.velocity.y = getRandomSpeed();
			flame.velocity.x = FlxG.random.float(-30, 30);
		}
		
		for (flake in members)
		{
			while (flake.y < camera.scroll.y)
				flake.y += camera.height;
			
			if (flake.y > camera.scroll.y + camera.height)
			{
				flake.y -= camera.height;
				flake.x = camera.scroll.x + FlxG.random.float(0, camera.width);
				flake.velocity.y = getRandomSpeed();
			}
			
			if (flake.x > camera.scroll.x + camera.width)
				flake.x -= camera.width;
			
			if (flake.x < camera.scroll.x)
				flake.x += camera.width;
		}
		
	}
	
	inline function getRandomSpeed():Float
		return -FlxG.random.float(20, 50);
}