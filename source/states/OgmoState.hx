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
		var data:OgmoLevelData = Json.parse(openfl.Assets.getText(levelPath));
		
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

	public function getByName<T>(name:String):Null<T>
	{
		return cast byName[name];
	}
}

typedef IOgmoDecal = IOgmoObject<OgmoDecalData, OgmoDecalLayer>;
class OgmoDecalLayer extends OgmoObjectLayer<FlxSprite>
{
	public function new (data:OgmoDecalLayerData, path:String = "")
	{
		super();
		
		for (decalData in data.decals)
		{
			final name = getName(decalData.texture);
			final decal = create(decalData);
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

	function create(data:OgmoDecalData):FlxSprite
	{
		var path = "assets/images/" + data.texture;
		var decal = switch(data.texture)
		{
			// case "props/cabin/tree.png": new Tree();
			case _: new FlxSprite(path);
		}
		
		decal.x = data.x;
		decal.y = data.y;
		if (path.indexOf("_ogmo.") != -1)
		{
			decal.loadGraphic
				( path.split("_ogmo").join("")
				, true
				, decal.frameWidth
				, decal.frameHeight
				);
			decal.animation.add("anim", [for (i in 0...decal.animation.frames) i], 12);
			decal.animation.play("anim");
		}
		
		decal.x -= decal.width / 2;
		decal.y -= decal.height / 2;
		
		return decal;
	}

	inline static function getName(texture:String):String
	{
		return texture.substring(texture.lastIndexOf("/") + 1, texture.lastIndexOf("."))
			.split("_ogmo").join("");
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
				
				if (Std.is(entity, FlxSprite))
				{
					final entity:FlxSprite = cast entity;
					entity.offset.x = entityData.originX;
					entity.offset.x = entityData.originY;
					entity.flipX = entityData.flippedX == true;
					entity.flipY = entityData.flippedY == true;
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
	name    :String,
	id      :Int,
	rotation:Float,
	originX :Int,
	originY :Int,
	?flippedX:Bool,
	?flippedY:Bool,
	values  :T
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

	inline public function getInt  ():Int   return isEmpty ? null : Std.parseInt(this);
	inline public function getFloat():Float return isEmpty ? null : Std.parseFloat(this);
	inline public function getBool ():Bool  return isEmpty ? null : this == "true";
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
