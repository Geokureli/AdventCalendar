package states;

import data.NGio;
import data.Calendar;
import data.BitArray;
import sprites.*;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.ui.FlxButton;

/**
 * recreates the 2018 advent
 * @author George
 */
class OutsideState extends BaseState 
{
	inline public static var soundEXT:String = ".mp3";
	
	private var camFollow:FlxObject;
	private var camOffset:Float = 70;

	private var snowStamp:FlxSprite;
	
	private var sprSnow:FlxSprite;
	private var snowStamps:FlxSprite;
	
	private var tree:OutsideTree;
	private var gyrados:FlxSprite;
	
	private var collisionBounds:FlxObject;
	private var treeOGhitbox:FlxObject;
	
	override public function create():Void 
	{
		/*
		// shitty game first time run init basically
		if (FlxG.sound.music == null)
		{
			//if its the 25 days leading up to christmas, play the christmas music
			//else play ambient wind and shit
			if (Calendar.isAdvent)
			{
				FlxG.sound.playMusic("assets/music/advent001-30sec" + soundEXT, 0);
				FlxG.sound.music.fadeIn(5, 0, 0.3);
			}
			
			FlxG.save.bind("advent2019", "GeoKureli");
		}*/
		
		#if !mobile
			FlxG.mouse.visible = true;
		#end
		
		initCameras();
		trace("cameras intted");
		
		var sprSky:FlxSprite = new FlxSprite(288 - 36, 162 - 11).loadGraphic(AssetPaths.sky__png);
		sprSky.scrollFactor.set(0.05, 0.05);
		add(sprSky);
		
		var sprClouds2:FlxSprite = new FlxSprite(sprSky.x, sprSky.y).loadGraphic(AssetPaths.clouds2__png);
		sprClouds2.scrollFactor.set(0.1, 0);
		sprClouds2.alpha = 0.5;
		add(sprClouds2);
		
		var sprClouds1:FlxSprite = new FlxSprite(sprSky.x, sprSky.y).loadGraphic(AssetPaths.clouds1__png);
		sprClouds1.scrollFactor.set(0.2, 0);
		sprClouds1.alpha = 0.5;
		add(sprClouds1);
		
		var sprMountains:FlxSprite = new FlxSprite(sprSky.x, sprSky.y).loadGraphic(AssetPaths.mountains__png);
		sprMountains.scrollFactor.set(0.3, 0.3);
		add(sprMountains);
		
		var sprSnow1:FlxSprite = new FlxSprite(sprSky.x, sprSky.y - 65).loadGraphic(AssetPaths.snow1__png);
		add(sprSnow1);
		sprSnow1.scrollFactor.set(0.4, 0.4);
		
		// initSnow();
		
		var sprGround:FlxSprite = new FlxSprite(sprSky.x, sprSky.y - 35).loadGraphic(AssetPaths.ground__png);
		sprGround.scrollFactor.set(0.6, 0.6);
		add(sprGround);
		
		gyrados = new FlxSprite(260, sprGround.y + 162);
		gyrados.loadGraphic(AssetPaths.gyradosSheet__png, true, Std.int(74 / 3));
		gyrados.animation.add("play", [0, 1, 2], 2);
		gyrados.animation.play("play");
		gyrados.scrollFactor.set(0.6, 0.6);
		gyrados.alpha = 0;
		add(gyrados);
		
		var sprFire:FlxSprite = new FlxSprite(sprGround.x + 270, sprGround.y + 164).loadGraphic(AssetPaths.fireSheet__png, true, Std.int(63 / 3), 24);
		sprFire.animation.add("fire", [0, 1, 2], 2);
		sprFire.animation.play("fire");
		sprFire.alpha = 1.0;
		sprFire.scrollFactor.set(0.6, 0.6);
		add(sprFire);
		
		var sprShine:FlxSprite = new FlxSprite(sprGround.x + 90, sprGround.y + 176).loadGraphic(AssetPaths.moonSheet__png, true, Std.int(150 / 3), 22);
		sprShine.animation.add("shine", [0, 1, 2], 1);
		sprShine.animation.play("shine");
		sprShine.scrollFactor.x = sprGround.scrollFactor.x * 0.85;
		sprShine.scrollFactor.y = 0.6;
		sprShine.alpha = 0.8;
		//add(sprShine);
		
		var sprSnow2 = new FlxSprite(sprSky.x, sprSky.y - 96).loadGraphic(AssetPaths.snow2__png);
		sprSnow2.scrollFactor.set(0.75, 0.75);
		add(sprSnow2);
		
		sprSnow = new FlxSprite(288 - 36, 162 - 11).loadGraphic(AssetPaths.snow__png);
		add(sprSnow);
		
		// initSnow();
		initCollision();
		
		collisionBounds = new FlxObject(sprSnow.x, 306, sprSnow.width, 3);
		collisionBounds.immovable = true;
		add(collisionBounds);
		
		var collisionBottom:FlxObject = new FlxObject(sprSnow.x, 500, sprSnow.width, 3);
		collisionBottom.immovable = true;
		_grpCollision.add(collisionBottom);
		
		//var collLeft:FlxObject = new FlxObject(sprSnow.x, sprSnow.y, 3, sprSnow.height * 1);
		var collLeft:FlxObject = new FlxObject(sprSnow.x, sprSnow.y, 3, sprSnow.height * 0.76);
		collLeft.immovable = true;
		_grpCollision.add(collLeft);
		
		var collLeft2:FlxObject = new FlxObject(sprSnow.x, 437, 3, 300);
		collLeft2.immovable = true;
		_grpCollision.add(collLeft2);
		
		var collRight:FlxObject = new FlxObject(sprSnow.x + sprSnow.width - 1, sprSnow.y, 3, sprSnow.height);
		collRight.immovable = true;
		_grpCollision.add(collRight);
		
		initSnow();
		initCharacters();
		
		var tank:Prop = new Prop(590, 420, AssetPaths.snowTank__png);
		tank.width -= 25;
		tank.immovable = true;
		_grpCharacters.add(tank);
		
		var fort:Prop = new Prop(640, 340, AssetPaths.snowFort__png);
		_grpCharacters.add(fort);
		fort.offset.x += fort.width;
		fort.width = 30;
		fort.offset.x -= fort.width + 8;
		fort.immovable = true;
		
		var sign:Sprite = new Sprite(266, 318, AssetPaths.sign__png);
		sign.offset.y = sign.height - 4;
		sign.height = 2;
		sign.offset.x = 4;
		sign.width -= 5;
		sign.immovable = true;
		_grpCharacters.add(sign);
		
		tree = new OutsideTree();
		_grpCharacters.add(tree);
		tree.setPosition(collisionBounds.x + 230, collisionBounds.y + 42);
		
		var igloo = new Sprite(410, 410);
		igloo.loadGraphic("assets/images/props/outside/igloo.png");
		igloo.offset.y = igloo.height * 0.7;
		igloo.height *= 0.28;
		igloo.immovable = true;
		_grpCharacters.add(igloo);
		
		var iggCollide:FlxObject = new FlxObject(igloo.x, 410, Std.int(igloo.width), 1);
		iggCollide.immovable = true;
		iggCollide.y -= iggCollide.height + player.height + 3;
		_grpCollision.add(iggCollide);
		
		var iggSideWall:FlxObject = new FlxObject(iggCollide.x + iggCollide.width - 9, iggCollide.y, 9, 10);
		iggSideWall.immovable = true;
		_grpCollision.add(iggSideWall);
		
		treeOGhitbox = new FlxObject(tree.x, tree.y - tree.height, tree.width, tree.height);
		add(treeOGhitbox);
		
		FlxG.camera.follow(camFollow, FlxCameraFollowStyle.LOCKON, 0.03);
		
		var zoomOffset:Float = 250;
		FlxG.camera.setScrollBounds(sprSnow.x, sprSnow.width + zoomOffset, sprSnow.y - 200, sprSnow.y + sprSnow.height);
		FlxG.camera.focusOn(player.getPosition());
		FlxG.camera.fade(FlxG.stage.color, 2.5, true);
		
		super.create();
	}
	
	private var snowLayer:Int = 2;
	
	private function initSnow():Void
	{
		add(new Snow(snowLayer + 1));
		snowLayer -= 1;
	}
	
	private function initCharacters():Void
	{
		initCharacterBases();
		
		player = new Player(265, collisionBounds.y + 125, Calendar.day);
		player.facing = FlxObject.RIGHT;
		_grpCharacters.add(player);
		
		playerHitbox = new FlxObject(0, 0, player.width + 6, player.height + 6);
		add(playerHitbox);
		
		thumbnail = new Thumbnail(0, 0, 0);
		add(thumbnail);
		FlxTween.tween(thumbnail.offset, {y: 5}, 1.2, {ease:FlxEase.quadInOut, type:FlxTweenType.PINGPONG});
		
		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);
	}
	
	private var gyradosTmr:Float = 0;
	
	override public function update(elapsed:Float):Void 
	{
		camFollow.setPosition(player.x, player.y - camOffset);
		
		if (player.x < 250)
		{
			FlxG.switchState(new CabinState(true));
		}
		
		playerHitbox.setPosition(player.x - 3, player.y - 3);
		
		if (player.y < collisionBounds.y + 20)
		{
			if (gyradosTmr >= 170)
			{
				gyrados.velocity.x = 2;
				
				if (gyrados.x >= 280)
				{
					if (gyrados.alpha > 0)
					{
						gyrados.alpha -= 0.4 * FlxG.elapsed;
					}
					else
					{
						gyrados.kill();
					}
				}
				else if (gyrados.alpha < 1)
				{
					gyrados.alpha += 0.4 * FlxG.elapsed;
				}
				
			}
			else
			{
				gyradosTmr += FlxG.elapsed;
			}
			
			if (camOffset < 90)
			{
				camOffset += 10 * FlxG.elapsed;
			}
			else
			{
				tree.alpha -= 0.3 * FlxG.elapsed;
			}
		}
		else
		{
			if (camOffset > 70)
			{
				camOffset -= 10 * FlxG.elapsed;
			}
		}
		
		FlxG.collide(collisionBounds, _grpCharacters);
		
		if (FlxG.overlap(player, treeOGhitbox))
		{
			if (FlxG.keys.justPressed.SPACE)
				FlxG.openURL("https://www.newgrounds.com/portal/view/721061");
			
			if (tree.alpha > 0.55)
			{
				tree.alpha -= 0.025;
			}
		}
		else
		{
			if (tree.alpha < 1 && player.y > collisionBounds.y + 20)
			{
				tree.alpha += 0.025;
			}
		}
		
		super.update(elapsed);
		
	}
}

/**
 * ...
 * @author NInjaMuffin99
 */
 @:forward
abstract OutsideTree(Sprite) to Sprite
{
	inline public function new() 
	{
		this = new Sprite("assets/images/props/outside/tree.png");
		
		this.offset.x = 54;
		this.offset.y = this.height - 20;
		this.width -= this.offset.x * 2;
		this.height = 16;
		
		this.immovable = true;
	}
	
}