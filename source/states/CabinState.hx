package states;

import data.NGio;
import data.Calendar;
import data.BitArray;
import sprites.*;

import io.newgrounds.NG;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

/**
 * ...
 * @author 
 */
class CabinState extends BaseState 
{
	inline static var WALL_Y = 78;
	inline static var MEDAL_0 = 58519;
	
	var camFollow:FlxObject;
	var camOffset:Float = 70;
	
	var tree:Tree;
	var tvTouch:FlxObject;
	var tvBubble:TvBubble;
	var fromOutside = false;
	
	override public function new (fromOutside = false)
	{
		this.fromOutside = fromOutside;
		super();
	}
	
	override public function create():Void 
	{
		// shitty game first time run init basically
		if (FlxG.sound.music == null)
		{
			//if its the 25 days leading up to christmas, play the christmas music
			//else play ambient wind and shit
			if (Calendar.isAdvent)
			{
				FlxG.sound.playMusic("assets/music/czyszy.mp3", 0);
				FlxG.sound.music.fadeIn(5, 0, 0.3);
			}
			FlxG.save.bind("advent2019", "GeoKureli");
		}
		
		#if !mobile
			FlxG.mouse.visible = true;
		#end
		
		trace("pres: " + openedPres, FlxG.save.data.openedPres);
		if (FlxG.save.data.openedPres != null && Std.is(FlxG.save.data.openedPres, Int))
		{
			openedPres = FlxG.save.data.openedPres;
			trace("loaded savefile: " + openedPres);
		}
		
		initCameras();
		trace("cameras intted");
		
		var floor = new FlxSprite("assets/images/props/cabin/floor.png");
		floor.updateHitbox();
		add(floor);
		
		add(new Sprite(17, 98, "assets/images/props/cabin/rug.png"));
		
		initCollision();
		// FlxG.debugger.drawDebug = true;
		var rightThird = (floor.height - WALL_Y) / 3;
		_grpCollision.add(new Wall(0              , 0                      , floor.width, WALL_Y      ));
		_grpCollision.add(new Wall(0              , 0                      , 3          , floor.height));
		_grpCollision.add(new Wall(floor.width - 3, WALL_Y                 , 3          , rightThird  ));
		_grpCollision.add(new Wall(floor.width - 3, WALL_Y + rightThird * 2, 3          , rightThird  ));
		_grpCollision.add(new Wall(0              , floor.height           , floor.width, 3           ));
		
		var snow = new Sprite(floor.width, 78 + (floor.height - 78) / 2, "assets/images/props/cabin/doorSnow.png");
		snow.x -= snow.width;
		add(snow);
		
		var wind = new FlxSprite(floor.width, 78 + (floor.height - 78) / 2);
		wind.loadGraphic("assets/images/props/cabin/snowWind.png", true, 100, 60);
		wind.animation.add("anim", [for (i in 0...24) i]);
		wind.animation.play("anim");
		wind.x -= wind.width;
		wind.y -= wind.height / 2;
		add(wind);
		
		initCharacters();
		initPresents();
		
		if (fromOutside)
		{
			player.x = floor.width - player.width;
			player.y = 78 + (floor.height - 78) / 2;
		}
		
		tree = new Tree(floor.width / 2, floor.height / 2 - 18);
		tree.x -= tree.width / 2;
		_grpCharacters.add(tree);
		
		tvBubble = new TvBubble();
		add(tvBubble);
		
		var tv = new FlxSprite(50, 46);
		tv.loadGraphic("assets/images/props/cabin/tv.png", true, 26, 38);
		tv.animation.add("anim", [0,1], 16);
		tv.animation.play("anim");
		tv.immovable = true;
		_grpCollision.add(tv);
		
		tvTouch = new FlxObject(tv.x - 3, tv.y, tv.width + 3, tv.height + 3);
		
		var couch = new Sprite(28, 144, "assets/images/props/cabin/couch.png");
		couch.immovable = true;
		_grpCollision.add(couch);
		
		var punchBowl = new Sprite(328, 66, "assets/images/props/cabin/punchBowl.png");
		punchBowl.immovable = true;
		_grpCollision.add(punchBowl);
		
		FlxG.camera.follow(camFollow, FlxCameraFollowStyle.LOCKON, 0.03);
		FlxG.camera.setScrollBounds(floor.x, floor.width, floor.y, floor.height);
		FlxG.camera.focusOn(player.getPosition());
		FlxG.camera.fade(FlxG.stage.color, 2.5, true);
		
		super.create();
	}
	
	private function initCharacters():Void
	{
		initCharacterBases();
		
		player = new Player(100, 100, Calendar.day);
		_grpCharacters.add(player);
		
		playerHitbox = new FlxObject(0, 0, player.width + 6, player.height + 6);
		add(playerHitbox);
		
		thumbnail = new Thumbnail(0, 0, 0);
		add(thumbnail);
		FlxTween.tween(thumbnail.offset, {y: 5}, 1.2, {ease:FlxEase.quadInOut, type:FlxTweenType.PINGPONG});
		
		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		
		// initNPC();
	}
	
	private function initNPC():Void
	{
		FlxG.log.add("NPCS ADDED");
		var chars = Calendar.day;
		// hopefulyl make it so that NPCs wind down as December ends
		if (!Calendar.isAdvent)
		{
			chars = FlxG.random.int(0, 10);
			FlxG.log.add("shrunkDays");
		}
		
		// NPCS only show up if its december
		if (!Calendar.isDecember)
			chars = 0;
		
		// for (c in 0...chars)
		// {
		// 	FlxG.log.add("NPC ADDED" + FlxG.random.int(0, 100));
		// 	var npc:NPC = new NPC(450 + FlxG.random.float( -150, 150), FlxG.random.float(collisionBounds.y + 60, 500));
		// 	npc.updateSprite(c);
		// 	npc.ID = 2;
		// 	_grpCharacters.add(npc);
		// }
	}
	
	private function initPresents():Void
	{
		var presents = Calendar.day + 1;
		trace("num presents: " + presents);
		
		for (p in 0...presents)
		{
			final pos = Calendar.data[p].pos;
			var present:Present = new Present(pos.x / 2 , pos.y / 2, p);
			_grpCharacters.add(present);
			if (openedPres[p])
			{
				present.animation.play("opened");
			}
			present.ID = 1;
		}
	}
	
	private var gyradosTmr:Float = 0;
	
	override public function update(elapsed:Float):Void 
	{
		playerHitbox.setPosition(player.x - 3, player.y - 3);
		presOverlaps = 0;
		camFollow.setPosition(player.x, player.y - camOffset);
		
		_grpCharacters.forEach(function(s:Sprite)
		{
			// Present
			if (s.ID == 1)
			{
				if (presOverlaps < 1)
				{
					if (FlxG.overlap(playerHitbox, s))
					{
						presOverlaps += 1;
						if (openedPres[s.curDay])
						{
							thumbnail.overlappin = true;
							thumbnail.setPosition(s.x - 20, s.y - thumbnail.height - 8);
							thumbnail.newThumb(s.curDay);
						}
						
						if (FlxG.onMobile)
						{
							for (touch in FlxG.touches.list)
							{
								if (touch.justPressed)
								{
									if (touch.overlaps(s) || touch.overlaps(thumbnail))
									{
										interactPres(s);
									}
								}
								
							}
						}
						
						
						if (FlxG.keys.justPressed.SPACE)
						{
							interactPres(s);
						}
					}
				}
				
			}
		});
		
		if (tvTouch.overlaps(playerHitbox) && FlxG.keys.justPressed.SPACE)
		{
			tvBubble.play();
		}
		
		super.update(elapsed);
		
		if (player.x > FlxG.camera.maxScrollX)
		{
			FlxG.switchState(new OutsideState());
		}
	}
	
	private function interactPres(s:Sprite):Void
	{
		FlxG.log.add(s.curDay);
		
		var whitelistUnlock:Bool = false;
		
		for (w in whitelist)
		{
			if (NGio.isLoggedIn)
			{
				if (NG.core.user.name == w)
					whitelistUnlock = true;
			}
		}
		
		if (NGio.isLoggedIn && s.curDay == Calendar.day)
		{
			trace("unlocking " + (MEDAL_0 + Calendar.day));
			var medal = NG.core.medals.get(MEDAL_0 + Calendar.day);
			if (!medal.unlocked)
				medal.sendUnlock();
			else
				trace("already unlocked");
		}
		
		s.animation.play("opened");
		openedPres[s.curDay] = true;
		
		var presCount:Int = 0;
		for (i in 0...openedPres.getLength())
		{
			if (openedPres[i])
			{
				presCount += 1;
			}
		}
		
		// if (presCount == 25)
		// {
		// 	triggerCutscene();
			
		// 	openedPres.reset();
		// }
		
		
		trace("saved: " + openedPres);
		FlxG.save.data.openedPres = (openedPres:Int);
		FlxG.save.flush();
		
		FlxG.sound.play("assets/sounds/presentOpen.mp3", 1);
		openSubState(new GallerySubstate(s.curDay));
	}
	
	
	// whitelist also gets filled with artist info from gridArray or whatever
	private var whitelist:Array<String> =
	[
		"geokureli",
		"brandybuizel",
		"thedyingsun"
	];
	
	private var openedPres:BitArray = new BitArray();
}

@:forward
abstract Tree(Sprite) to Sprite
{
	inline public function new(x = 0.0, y = 0.0) 
	{
		this = new Sprite(x, y, "assets/images/props/cabin/tree_1.png");
		
		this.width = 30;
		this.height = 20;
		this.offset.x = (this.frameWidth - this.width) / 2 ;
		this.offset.y = this.frameHeight - this.height - 20;
		
		this.immovable = true;
	}
}

@:forward
abstract Wall(FlxObject) to FlxObject
{
	inline public function new(x = 0.0, y = 0.0, width = 0.0, height = 0.0)
	{
		this = new FlxObject(x, y, width, height);
		this.immovable = true;
	}
}

