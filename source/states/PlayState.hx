package states;

import data.NGio;
import data.Calendar;
import data.BitArray;
import sprites.*;
import states.IglooSubstate;
import states.GallerySubstate;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.group.FlxGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxVector;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.ui.FlxSpriteButton;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;
import flixel.util.helpers.FlxPointRangeBounds;
import io.newgrounds.NG;
import io.newgrounds.objects.events.Response;
import io.newgrounds.objects.events.Result.GetDateTimeResult;
import openfl.geom.ColorTransform;

/**
 * ...
 * @author 
 */
class PlayState extends BaseState 
{
	private var camFollow:FlxObject;
	private var camOffset:Float = 70;

	private var snowStamp:FlxSprite;
	
	private var sprSnow:FlxSprite;
	private var snowStamps:FlxSprite;
	
	private var tree:Tree;
	private var treeLights:FlxSprite;
	private var gyrados:FlxSprite;
	
	private var collisionBounds:FlxObject;
	private var treeOGhitbox:FlxObject;
	private var iglooEnter:FlxObject;
	
	private var camZoomPos:FlxPoint = new FlxPoint(288 - 36, 162 - 11);
	
	inline public static var soundEXT:String = ".mp3";
	
	private var enteringIgloo:Bool = false;
	private var playingCutscene:Bool = false;
	
	private var sprSnow2:FlxSprite;
	
	override public function create():Void 
	{
		// shitty game first time run init basically
		if (FlxG.sound.music == null)
		{
			//if its the 25 days leading up to christmas, play the christmas music
			//else play ambient wind and shit
			if (Calendar.isAdvent)
				FlxG.sound.playMusic("assets/music/song4" + soundEXT, 0);
			else
				FlxG.sound.playMusic(AssetPaths.ambience__mp3, 0);
			
			FlxG.sound.music.fadeIn(5, 0, 0.3);
			
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
		
		var sprSky:FlxSprite = new FlxSprite(288 - 36, 162 - 11).loadGraphic(AssetPaths.AdventCalendarBG__png);
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
		
		var sprGround:FlxSprite = new FlxSprite(sprSky.x, sprSky.y - 35).loadGraphic("assets/images/ground_6.png");
		sprGround.scrollFactor.set(0.6, 0.6);
		add(sprGround);
		
		gyrados = new FlxSprite(260, sprGround.y + 162);
		gyrados.loadGraphic("assets/images/gyradosSheet.png", true, Std.int(74 / 3));
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
		
		sprSnow2 = new FlxSprite(sprSky.x, sprSky.y - 96).loadGraphic(AssetPaths.snow2__png);
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
		initPresents();
		
		var tank:Prop = new Prop(590, 420, "assets/images/snowTank.png");
		tank.width -= 25;
		tank.immovable = true;
		_grpCharacters.add(tank);
		
		var fort:Prop = new Prop(640, 340, "assets/images/snowFort.png");
		_grpCharacters.add(fort);
		fort.offset.x += fort.width;
		fort.width = 30;
		fort.offset.x -= fort.width + 8;
		fort.immovable = true;
		
		var sign:SpriteShit = new SpriteShit(266, 318);
		sign.loadGraphic(AssetPaths.sign_1__png);
		sign.offset.y = sign.height - 4;
		sign.height = 2;
		sign.offset.x = 4;
		sign.width -= 5;
		sign.immovable = true;
		_grpCharacters.add(sign);
		
		tree = new Tree(0, 0, Calendar.day);
		_grpCharacters.add(tree);
		tree.setPosition(collisionBounds.x + 230, collisionBounds.y + 42);
		
		treeLights = new FlxSprite(tree.x - tree.offset.x, tree.y - tree.offset.y).loadGraphic(AssetPaths.christmasTree_lights__png);
		treeLights.scrollFactor.set(_grpCharacters.scrollFactor.x, _grpCharacters.scrollFactor.y);
		treeLights.cameras = [gameCamera];
		add(treeLights);
		
		
		var igloo:SpriteShit = new SpriteShit(410, 410);
		igloo.loadGraphic("assets/images/igloo.png");
		igloo.offset.y = igloo.height * 0.7;
		igloo.height *= 0.28;
		igloo.immovable = true;
		_grpCharacters.add(igloo);
		
		var iggCollide:SpriteShit = new SpriteShit(igloo.x, 410);
		iggCollide.makeGraphic(Std.int(igloo.width), 1, FlxColor.TRANSPARENT);
		iggCollide.immovable = true;
		
		iggCollide.y -= iggCollide.height + player.height + 3;
		_grpCharacters.add(iggCollide);
		
		var iggSideWall:SpriteShit = new SpriteShit(iggCollide.x + iggCollide.width - 9, iggCollide.y);
		iggSideWall.makeGraphic(9, 10, FlxColor.TRANSPARENT);
		iggSideWall.immovable = true;
		_grpCharacters.add(iggSideWall);
		
		iglooEnter = new FlxObject(425, 403, 2, 6);
		add(iglooEnter);
		
		treeOGhitbox = new FlxObject(tree.x, tree.y - tree.treeSize.height, tree.treeSize.width, tree.treeSize.height);
		add(treeOGhitbox);
		
		FlxG.camera.follow(camFollow, FlxCameraFollowStyle.LOCKON, 0.03);
		
		var zoomOffset:Float = 250;
		FlxG.camera.setScrollBounds(sprSnow.x, sprSnow.width + zoomOffset, sprSnow.y - 200, sprSnow.y + sprSnow.height);
		FlxG.camera.focusOn(player.getPosition());
		FlxG.camera.fade(FlxColor.BLACK, 2.5, true);
		
		if (FlxG.onMobile)
		{
			FlxG.cameras.add(uiCamera);
			
			var button = new FlxButton(10, 10, "Fullscreen", function() FlxG.fullscreen = !FlxG.fullscreen);
			button.cameras = [uiCamera];
			button.scrollFactor.set();
			add(button);
			
		}
		
		super.create();
	}
	
	private var snowLayer:Int = 2;
	
	private function initSnow():Void
	{
		add(new Snow(snowLayer + 1));
		snowLayer -= 1;
	}
	
	override function initEvidence():Void 
	{
		super.initEvidence();
		
		var evidence1:Evidence = new Evidence(620, 410);
		evidence1.ID = 0;
		_grpEvidence.add(evidence1);
		
		var evidence2:Evidence = new Evidence(590 - 15, 400);
		evidence2.ID = 1;
		_grpEvidence.add(evidence2);
		
		var treeEv:Evidence = new Evidence(503, 322);
		treeEv.ID = 7;
		_grpEvidence.add(treeEv);
		
		var fortEv:Evidence = new Evidence(644, 330);
		fortEv.ID = 4;
		_grpEvidence.add(fortEv);
		
		var evCorner:Evidence = new Evidence(256, 490);
		evCorner.ID = 2;
		_grpEvidence.add(evCorner);
		
		var evPhil:Evidence = new Evidence(473, 390);
		evPhil.ID = 5;
		_grpEvidence.add(evPhil);
		
		var evSign:Evidence = new Evidence(264, 311);
		evSign.ID = 8;
		_grpEvidence.add(evSign);
		
		var evTyler:Evidence = new Evidence(443, 478);
		evTyler.ID = 9;
		_grpEvidence.add(evTyler);
		
		checkEv();
	}
	
	
	private function initCharacters():Void
	{
		initCharacterBases();
		
		player = new Player(315, collisionBounds.y + 65, Calendar.day);
		_grpCharacters.add(player);
		
		playerHitbox = new FlxObject(0, 0, player.width + 6, player.height + 6);
		add(playerHitbox);
		
		thumbnail = new Thumbnail(0, 0, 0);
		add(thumbnail);
		FlxTween.tween(thumbnail.offset, {y: 5}, 1.2, {ease:FlxEase.quadInOut, type:FlxTweenType.PINGPONG});
		
		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		
		initNPC();
		
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
		
		for (c in 0...chars)
		{
			FlxG.log.add("NPC ADDED" + FlxG.random.int(0, 100));
			var npc:NPC = new NPC(450 + FlxG.random.float( -150, 150), FlxG.random.float(collisionBounds.y + 60, 500));
			npc.updateSprite(c);
			npc.ID = 2;
			_grpCharacters.add(npc);
		}
	}
	
	private function initPresents():Void
	{
		FlxG.log.add("GETTIN PRESENTS");
		
		var presents = Calendar.day + 1;
		FlxG.log.add("how many presents there should be: " + presents);
		
		for (p in 0...presents)
		{
			final pos = Calendar.data[p].pos;
			var present:Present = new Present(pos.x, pos.y, p);
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
		if (FlxG.keys.justPressed.O)
		{
			FlxG.switchState(new IglooSubstate());
		}
		
		if (FlxG.overlap(playerHitbox, iglooEnter) && !enteringIgloo)
		{
			enteringIgloo = true;
			
			FlxG.camera.fade(FlxColor.BLACK, 1, false, function(){FlxG.switchState(new IglooSubstate()); });
		}
		
		treeLights.alpha = tree.alpha;
		
		
		if (canExitCutscene)
		{
			if (FlxG.onMobile)
			{
				for (touch in FlxG.touches.list)
				{
					if (touch.pressed)
					{
						playingCutscene = false;
						canExitCutscene = false;
						player.setPosition(315, collisionBounds.y + 65);
					}
				}
			}
			else
			{
				if (FlxG.keys.justPressed.SPACE)
				{
					playingCutscene = false;
					canExitCutscene = false;
					player.setPosition(315, collisionBounds.y + 65);
				}
			}
		}
		
		if (!playingCutscene)
		{
			camFollow.setPosition(player.x, player.y - camOffset);
		}
		
		if (player.x < 250)
		{
			FlxG.switchState(new CabinState());
		}
		
		playerHitbox.setPosition(player.x - 3, player.y - 3);
		presOverlaps = 0;
		
		if (FlxG.overlap(player, iglooEnter))
		{
			// blah blah blah enter the igloo here
		}
		
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
			else if (!playingCutscene)
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
		
		
		if (FlxG.overlap(player, treeOGhitbox) && !playingCutscene)
		{
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
		
		_grpCharacters.forEach(function(s:SpriteShit)
		{
			// Present
			if (s.ID == 1)
			{
				if (s.posDiff.x != 0 || s.posDiff.y != 0)
				{
					// sprSnow.stamp(snowStamp, Std.int(s.x), Std.int(s.y));
				}
				
				if (presOverlaps < 1)
				{
					if (FlxG.overlap(playerHitbox, s))
					{
						presOverlaps += 1;
						thumbnail.overlappin = true;
						thumbnail.setPosition(s.x - 20, s.y - thumbnail.height - 8);
						thumbnail.newThumb(s.curDay);
						
						
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
		
		super.update(elapsed);
		
	}
	
	private function interactPres(s:SpriteShit):Void
	{
		FlxG.log.add(s.curDay);
		
		if (s.curDay == 0)
		{
			if (NGio.isLoggedIn) 
			{
				var medal = NG.core.medals.get(Calendar.data[0].medal);
				if (!medal.unlocked)
					medal.sendUnlock();
			}
			
		}
		
		var whitelistUnlock:Bool = false;
		
		for (w in whitelist)
		{
			if (NGio.isLoggedIn)
			{
				if (NG.core.user.name == w)
					whitelistUnlock = true;
			}
		}
		
		if ((NGio.isLoggedIn && s.curDay == Calendar.day) || whitelistUnlock)
		{
			var medal = NG.core.medals.get(Calendar.data[Calendar.day].medal);
			if (!medal.unlocked)
				medal.sendUnlock();
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
		
		if (presCount == 25)
		{
			triggerCutscene();
			
			openedPres.reset();
		}
		
		
		trace("saved: " + openedPres);
		FlxG.save.data.openedPres = (openedPres:Int);
		FlxG.save.flush();
		
		FlxG.sound.play("assets/sounds/presentOpen" + soundEXT, 1);
		openSubState(new GallerySubstate(s.curDay));
	}
	
	private function triggerCutscene():Void
	{
		FlxG.log.add("cutscene triggered");
		if (!playingCutscene)
		{
			playingCutscene = true;
			FlxG.sound.music.fadeOut(4.5, 0, function(t:FlxTween)
			{
				FlxG.sound.playMusic(AssetPaths.ambience__mp3, 0);
				FlxG.sound.music.fadeIn(6, 0, 0.5);
			});
			
			FlxTween.tween(camFollow, {y:sprSnow.y - 100}, 8, {onComplete: function(t:FlxTween)
			{
				FlxG.sound.play(AssetPaths.rise__mp3, 0.7);
				FlxG.camera.fade(FlxColor.WHITE, 5.8, false, function()
				{
					FlxG.camera.fade(FlxColor.WHITE, 0.1, true);
					var star:FlxSprite = new FlxSprite(507, 25).loadGraphic(AssetPaths.christmasTree_star__png);
					add(star);
					
					FlxG.sound.play(AssetPaths.crash__mp3, 0.6, false, null, true, function(){beginCreds(); });
				});
			}});
		}
	}
	
	private function beginCreds():Void
	{
		FlxG.sound.music.fadeOut(1, 0, function(t:FlxTween)
		{
			FlxG.sound.playMusic(AssetPaths.dedicatedEXTENDED__mp3, 0);
			FlxG.sound.music.fadeIn(8, 0, 1);
			new FlxTimer().start(1.6, function(t:FlxTimer)
			{
				FlxG.cameras.add(uiCamera);
				for (i in 0...3)
				{
					var cred:FlxSprite = new FlxSprite(40 + (i * (8 * i)), 100 + (85 * i)).loadGraphic("assets/images/credits" + i + ".png");
					cred.alpha = 0;
					cred.velocity.y = 5;
					add(cred);
					
					if (i == 2)
					{
						cred.y -= 30;
					}
					
					FlxTween.tween(cred, {alpha: 1, y: cred.y + 10}, 0.13, {ease: FlxEase.quartOut, startDelay: 0.12 * i});
					
					cred.cameras = [uiCamera];
					
					new FlxTimer().start(2 + (0.1 * i), function(tt:FlxTimer)
					{
						remove(cred);
						if (i == 2)
						{
							credsPartTwo();
						}
					});
				}
			});
			
		});
	}
	
	private function credsPartTwo():Void
	{
		var credArray:Array<Dynamic> = [];
		credArray.push(["Organizer", "ninjamuffin99"]);
		credArray.push(["Pixel Art", "BrandyBuizel"]);
		
		for (i in 0...Calendar.data.length)
		{
			credArray.push(["Day " + (i + 1), Calendar.data[i].author]);
		}
		
		credArray.push(["Music Days 1-5", "'Snowfall'", "LawnReality"]);
		credArray.push(["Music Days 5-10", "'Yuletide Memories'", "LucidShadowDreamer"]);
		credArray.push(["Music Days 10-20", "'Anastasia and Cinderella'", "Precipitation24"]);
		credArray.push(["Music Days 20-25", "'Christmas Cheer'", "TwelfthChromatic"]);
		credArray.push(["Credits Music", "ninjamuffin99"]);
		credArray.push(["Additional Code", "Geokureli"]);
		credArray.push(["Additional Pixel Art", "NickConter"]);
		credArray.push(["Additional Pixel Art", "TheDyingSun"]);
		credArray.push(["Special Thanks", "Newgrounds", "Tom Fulp", "TurkeyOnAStick"]);
		
		if (NGio.isLoggedIn)
		{
			if (NG.core.user.supporter)
			{
				credArray.push(["Special Thanks", "to YOU!", NG.core.user.name, "For Supporting NG"]);
			}
		}
		
		credArray.push([""]);
		
		if (FlxG.onMobile)
		{
			credArray.push(["Tap anywhere \nat anytime to \nreturn to the game"]);
		}
		else
		{
			credArray.push(["Press Spacebar \nat anytime to \nreturn to the game"]);
		}
		
		
		for (i in 0...credArray.length)
		{
			new FlxTimer().start(2.5 * i, function(t:FlxTimer)
			{
				var credText:FlxText = new FlxText(100, 180, 0, "", 32);
				credText.alignment = FlxTextAlign.CENTER;
				add(credText);
				
				for (c in 0...credArray[i].length)
				{
					credText.text += credArray[i][c] + "\n";
				}
				
				credText.cameras = [uiCamera];
				
				FlxTween.tween(credText, {y:credText.y + 50, alpha: 0}, 2.4, {onComplete: function(maTween:FlxTween){
					remove(credText); 
					if (i == credArray.length - 1)
					{
						canExitCutscene = true;
						if (NGio.isLoggedIn)
						{
							var medal = NG.core.medals.get(56235);
							if (!medal.unlocked)
								medal.sendUnlock();
							// 56235
						}
					}
					
				}});
			});
		}
	}
	
	private var canExitCutscene:Bool = false;
	
	
	// whitelist also gets filled with artist info from gridArray or whatever
	private var whitelist:Array<String> =
	[
		"geokureli"
	];
	
	private var openedPres:BitArray = new BitArray();
}