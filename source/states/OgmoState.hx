package states;

import haxe.Json;

import sprites.TvBubble;
import sprites.Player;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.tile.FlxTilemap;
import flixel.group.FlxGroup;

class OgmoState extends FlxState
{
	var byName:Map<String, FlxBasic> = new Map();

	function parseLevel(levelPath:String)
	{
		var levelString = openfl.Assets.getText(levelPath)
			.split("\\\\").join("/");
		var data:OgmoLevelData = Json.parse(levelString);
		
		var bounds = FlxG.worldBounds.set(data.offsetX, data.offsetY, data.width, data.height);
		FlxG.camera.setScrollBounds(bounds.left, bounds.right, bounds.top, bounds.bottom);
		
		data.layers.reverse();
		for (layerData in data.layers)
		{
			trace('layer: ${layerData.name}');
			var layer = createLayer(layerData);
			add(layer);
			byName[layerData.name] = layer;
		}
	}

	function createLayer(data:OgmoLayerData):FlxBasic
	{
		if (Reflect.hasField(data, "tileset"))
			return new OgmoTilemap(cast data);
		
		if (Reflect.hasField(data, "entities"))
			return new OgmoEntityLayer(cast data);
		
		if (Reflect.hasField(data, "decals"))
			return new OgmoDecalLayer(cast data);
		
		throw 'unhandled layer: ${data.name}';
	}

	public function getByName<T:FlxBasic>(name:String):Null<T>
	{
		return cast byName[name];
	}
}

class OgmoTilemap extends FlxTilemap
{
	public var name:String;
	public function new (data:OgmoTileLayerData)
	{
		super();
		
		name = data.name;
		x = data.offsetX;
		y = data.offsetY;
		final map = data.data.map(i->i == -1 ? 0 : i);
		loadMapFromArray
			( map
			, data.gridCellsX
			, data.gridCellsY
			, new openfl.display.BitmapData(data.gridCellWidth * 2, data.gridCellHeight)
			, data.gridCellWidth
			, data.gridCellHeight
			, 0
			, 2
			, 1
			);
	}
}

class OgmoObjectLayer<T:FlxBasic> extends FlxTypedGroup<T>
{
	public var name:String;

	var byName:Map<String, T> = new Map();

	public function getByName(name:String):Null<T>
	{
		return cast byName[name];
	}
	
	public function getObjectNameIndex(suffix:String, maxValue:Int):Null<Int>
	{
		var value = maxValue;
		while(value >= 0)
		{
			if (byName.exists(suffix + value))
				return value;
			
			value--;
		}
		return null;
	}
	
	public function getIndexNamedObject(suffix:String, maxValue:Int):Null<T>
	{
		return getByName(suffix + getObjectNameIndex(suffix, maxValue));
	}
}

typedef IOgmoDecal = IOgmoObject<OgmoDecalData, OgmoDecalLayer>;
class OgmoDecalLayer extends OgmoObjectLayer<OgmoDecal>
{
	public function new (data:OgmoDecalLayerData, path:String = "")
	{
		super();
		
		for (decalData in data.decals)
		{
			final name = getName(decalData.texture);
			final decal = new OgmoDecal(decalData);
			add(decal);
			if (!byName.exists(name))
				byName[name] = decal;
			trace('decal: $name x:${decal.x} y:${decal.y}');
		}
		
		for (i in 0...data.decals.length)
		{
			if (Std.is(members[i], IOgmoDecal))
				(cast members[i]:IOgmoDecal).ogmoInit(data.decals[i], this);
		}
	}

	inline static function getName(texture:String):String
	{
		return texture.substring(texture.lastIndexOf("/") + 1, texture.lastIndexOf("."))
			.split("_ogmo").join("");
	}
	
	public function getAllWithPrefix(prefix:String):Map<String, OgmoDecal>
	{
		var all:Map<String, OgmoDecal> = [];
		for (child in members)
		{
			if (child.graphic != null && child.graphic.assetsKey.indexOf(prefix) != -1)
			{
				var name = child.graphic.assetsKey.split(prefix).pop();
				name = name.substr(0, name.length - 4);//remove .png
				all[name] = child;
			}
		}
		return all;
	}
}

typedef IOgmoEntity<T> = IOgmoObject<OgmoEntityData<T>, OgmoEntityLayer>;
class OgmoEntityLayer extends OgmoObjectLayer<FlxObject>
{
	public function new (data:OgmoEntityLayerData)
	{
		super();
		
		for (entityData in data.entities)
		{
			var entity = add(create(entityData));
			if (entityData.values != null && entityData.values.id != "" && entityData.values.id != null)
			{
				trace("entity:" + entityData.values.id);
				byName[entityData.values.id] = entity;
			}
			else if (!byName.exists(name))
			{
				trace("entity:" + entityData.name);
				byName[entityData.name] = entity;
			}
		}
		
		for (i in 0...data.entities.length)
		{
			if (Std.is(members[i], IOgmoEntity))
				(cast members[i]:IOgmoEntity<Dynamic>).ogmoInit(data.entities[i], this);
			else
			{
				final entity:FlxObject = cast members[i];
				final entityData = data.entities[i];
				entity.x = entityData.x;
				entity.y = entityData.y;
				
				if (entityData.rotation != null)
					entity.angle = entityData.rotation;
				
				if (entityData.width != null)
					entity.width = entityData.width;
				
				if (entityData.height != null)
					entity.height = entityData.height;
				
				if (Std.is(entity, FlxSprite))
				{
					final entity:FlxSprite = cast entity;
					if (entityData.originX != 0)
						entity.offset.x = entityData.originX;
					if (entityData.originY != 0)
						entity.offset.y = entityData.originY;
					if (entityData.flippedX == true)
						entity.facing = (entity.facing == FlxObject.LEFT) ? FlxObject.RIGHT : FlxObject.LEFT;
				}
			}
		}
	}

	function create(data:OgmoEntityData<Dynamic>):FlxObject
	{
		var entity:FlxObject = switch(data.name)
		{
			case "TvBubble": new TvBubble();
			case "Player": new Player();
			case "Teleport": new FlxObject();
			case name: throw 'unhandled entity name: $name';
		}
		
		return entity;
	}
}

typedef OgmoLevelData =
{
	width     :Int,
	height    :Int,
	offsetX   :Int,
	offsetY   :Int,
	layers    :Array<OgmoLayerData>,
	exportMode:Int,
	arrayMode :Int
}

typedef OgmoLayerData = 
{
	name          :String,
	offsetX       :Int,
	offsetY       :Int,
	gridCellWidth :Int,
	gridCellHeight:Int,
	gridCellsX    :Int,
	gridCellsY    :Int
}

typedef OgmoTileLayerData
= OgmoLayerData
& {
	tileset:String,
	data   :Array<Int>
}

typedef OgmoDecalLayerData
= OgmoLayerData
& { decals: Array<OgmoDecalData> }

typedef OgmoEntityLayerData
= OgmoLayerData
& { entities:Array<OgmoEntityData<Dynamic>> }

typedef OgmoObjectData = { x:Int, y:Int }

typedef OgmoEntityData<T>
= OgmoObjectData & {
	name     :String,
	id       :Int,
	rotation :Null<Float>,
	originX  :Int,
	originY  :Int,
	?width   :Int,
	?height  :Int,
	?flippedX:Bool,
	?flippedY:Bool,
	values   :T
}

@:forward
abstract OgmoDecal(FlxSprite) to FlxSprite from FlxSprite
{
	inline public function new(data:OgmoDecalData):Void
	{
		var path = "assets/images/" + data.texture;
		this = switch(data.texture)
		{
			// case "props/cabin/tree.png": new Tree();
			case _: new FlxSprite(path);
		}
		
		this.x = data.x;
		this.y = data.y;
		if (path.indexOf("_ogmo.") != -1)
		{
			this.loadGraphic
				( path.split("_ogmo").join("")
				, true
				, this.frameWidth
				, this.frameHeight
				);
			this.animation.add("anim", [for (i in 0...this.animation.frames) i], 12);
			this.animation.play("anim");
		}
		
		// convert from center pos
		this.x -= Math.round(this.width / 2);
		this.y -= Math.round(this.height / 2);
		// allow player to go behind stuff
		setBottomHeight(Math.round(this.height / 3));
	}
	
	public function setBottomHeight(value:Int)
	{
		var oldHeight = this.height;
		this.height = value;
		this.y += oldHeight - value;
		this.offset.y += oldHeight - value;
	}
	
	public function setMiddleWidth(value:Int)
	{
		var oldWidth = this.width;
		this.width = value;
		this.x += (oldWidth - value) / 2;
		this.offset.x += (oldWidth - value) / 2;
	}
}

typedef OgmoDecalData = OgmoObjectData & { texture:String }

interface IOgmoObject<Data:OgmoObjectData, Layer>
{
	function ogmoInit(data:Data, parent:Layer):Void;
}

abstract OgmoValue(String) from String to String
{
	public var isEmpty(get, never):Bool;
	inline function get_isEmpty() return this == "-1";
		
	inline public function getColor():Null<Int>
	{
		return isEmpty ? null : (Std.parseInt("0x" + this.substr(1)) >> 8);
	}

	inline public function getInt  ():Null<Int>   return isEmpty ? null : Std.parseInt(this);
	inline public function getFloat():Null<Float> return isEmpty ? null : Std.parseFloat(this);
	inline public function getBool ():Null<Bool>  return isEmpty ? null : this == "true";
}

@:forward abstract OgmoInt(OgmoValue) from String to String
{
	public var value(get, never):Int; inline function get_value() return this.getInt();
}

@:forward abstract OgmoFloat(OgmoValue) from String to String
{
	public var value(get, never):Float; inline function get_value() return this.getFloat();
}

@:forward abstract OgmoBool(OgmoValue) from String to String
{
	public var value(get, never):Bool; inline function get_value() return this.getBool();
}

@:forward abstract OgmoColor(OgmoValue) from String to String
{
public var value(get, never):Int; inline function get_value() return this.getColor();
}
