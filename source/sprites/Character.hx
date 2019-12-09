package sprites;

import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;

/**
 * ...
 * @author NInjaMuffin99
 */
class Character extends Sprite 
{
	private var speed:Float = 95;
	private var actualOffsetLOL:Float = 12;
	
	override function set_facing(direction:Int):Int
	{
		if (facing != direction)
			offset.x = direction == FlxObject.RIGHT ? 4 : 8;
		
		return super.set_facing(direction);
	}
	
	public function new(?X:Float=0, ?Y:Float=0, ?SimpleGraphic:FlxGraphicAsset) 
	{
		super(X, Y, SimpleGraphic);
		
		
		loadGraphic(AssetPaths.tankMan__png, true, 16, 16);
		animation.frameIndex = 0;
		
		setFacingFlip(FlxObject.LEFT, false, false);
		setFacingFlip(FlxObject.RIGHT, true, false);
		
		drag.x = drag.y = 2500;
		// offsets to the bottom, then shrinks the sprite
		offset.y = height - 4;
		width = 4;
		height = 4;
		offset.x = 4;
		facing = FlxObject.RIGHT;
	}
	
	
	public function updateSprite(day:Int):Void
	{
		if (day == 8)
		{
			loadGraphic(AssetPaths.Daddy__png, false, 24, 24);
			actualOffsetLOL = 20;
			width = 8;
			height = 8;
			offset.y += 9;
		}
		else
		{
			// already should have loaded the sprite data i think
			animation.frameIndex = day;
		}
	}
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
		if (velocity.x > 0)
			facing = FlxObject.RIGHT;
		else if (velocity.x < 0)
			facing = FlxObject.LEFT;
	}
}