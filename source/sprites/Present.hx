package sprites;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;

import data.Calendar;
import states.OgmoState;

/**
 * ...
 * @author NInjaMuffin99
 */
@:forward
abstract Present(FlxSprite) to FlxSprite to OgmoDecal
{
	public var decal(get, never):OgmoDecal;
	inline function get_decal() return this;
	
	public var day(get, never):Null<Int>;
	inline function get_day() return isDaily ? this.ID : null;
	
	public var saveIndex(get, never):Null<Int>;
	inline function get_saveIndex() return this.ID != -1 ? this.ID : null;
	
	public var isDaily(get, never):Bool;
	inline function get_isDaily() return this.ID != -1 && this.ID < 25;
	
	public var opened(get, never):Bool;
	inline function get_opened()
		return this.animation.curAnim != null && this.animation.curAnim.name == "opened";
	
	public function new(?x:Float=0, ?y:Float=0, ?suffix:String, ?saveIndex:Int, opened = false)
	{
		this = new FlxSprite(x, y);
		
		if (saveIndex != null)
		{
			this.ID = saveIndex;
			if (suffix == null)
				suffix = Std.string(saveIndex + 1);
		}
		
		this.loadGraphic('assets/images/presents/present_$suffix.png', true, 16, 17);
		
		setup(opened);
	}
	
	inline public function setup(opened = false):Present
	{
		this.animation.add("closed", [0]);
		this.animation.add("opened", [1]);
		this.animation.play("closed");
		if (opened)
			this.animation.play("opened");
		
		this.drag.x = this.drag.y = 5000;
		
		decal.setBottomHeight(8);
		// this.offset.y = this.height - 8;
		// this.height -= this.offset.y;
		return cast this;
	}
	
	inline public function open():Void
	{
		this.animation.play("opened");
	}
	
	inline static public function fromDecal(decal:OgmoDecal, opened = false):Present
	{
		return (cast decal:Present).setup(opened);
	}
}