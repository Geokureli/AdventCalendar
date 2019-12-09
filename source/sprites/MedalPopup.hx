package sprites;

import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.display.BitmapData;
import openfl.utils.Assets;

import io.newgrounds.NG;
import io.newgrounds.objects.Medal;

import data.NGio;
import states.OutsideState;

import flixel.FlxG;
import flixel.FlxSprite;

class MedalPopup extends flixel.group.FlxSpriteGroup
{
    inline static var TEST_MEDAL = OutsideState.GLOCK_MEDAL;
    inline static var BOX_PATH = "assets/images/ui/medalAnim.png";
    inline static var MEDAL_PATH = "assets/images/ui/medalSlide.png";
    
    static var instance(default, null):MedalPopup;
    
    var animQueue = new Array<Medal>();
    var medalsRects = new Array<Rectangle>();
    var box:FlxSprite;
    var medal:FlxSprite;
    
    function new()
    {
        super();
        
        x = FlxG.width - 65;
        y = FlxG.height - 79;
        visible = false;
        
        add(medal = new FlxSprite(0, 0).loadGraphic(MEDAL_PATH, true, 97, 79));
        medal.animation.add("anim", [0,0,0,0,0,0,0,0,0,0,0,1,1,1,2,3,4,5,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,7,8,9], 10);
        var medalBmd = medal.graphic.bitmap;
        var frameBmd = new BitmapData(97, 79);
        final numFrames = Std.int(medalBmd.width/frameBmd.width);
        var sourceRect = new Rectangle(0, 0, frameBmd.width, frameBmd.height);
        var point = new Point();
        for (i in 0...numFrames)
        {
            frameBmd.fillRect(frameBmd.rect, 0);
            frameBmd.copyPixels(medalBmd, sourceRect, point);
            final rect = frameBmd.getColorBoundsRect(0xFF000000, 0x0, false);
            medalsRects.push(rect);
            trace(rect);
            sourceRect.x += sourceRect.width;
        }
        
        add(box = new FlxSprite(0, 0).loadGraphic(BOX_PATH, true, 65, 79));
        box.animation.add("anim", [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,16,16,17,18,19,20,21,22,23,24], 10, false);

        
        scrollFactor.set(); 
        if (NGio.isLoggedIn)
        {
            if (NG.core.medals != null)
                medalsLoaded();
            else
                NG.core.onMedalsLoaded.add(medalsLoaded);
        }
    }
    
    function medalsLoaded():Void
    {
        var numMedals = 0;
        var numMedalsLocked = 0;
        for (medal in NG.core.medals) {
            
            if (!medal.unlocked) {
                
                numMedalsLocked++;
                medal.onUnlock.add(onMedalUnlock.bind(medal));
                trace('${medal.unlocked ? "unlocked" : "locked  "} - ${medal.name}');
            }
            numMedals++;
        }
        trace('loaded $numMedals medals, $numMedalsLocked locked ');
    }
    
    function onMedalUnlock(medal:Medal):Void
    {
        // if (!enabled)
        //     return;
        
        animQueue.push(medal);
        
        if (!visible)
            playNextAnim();
    }
    
    function playDebugAnim():Void
    {
        onMedalUnlock(NG.core.medals.get(TEST_MEDAL));
    }
    
    function playNextAnim():Void {
        
        if (animQueue.length == 0)
            return;
        
        var medal = animQueue.shift();
        
        visible = true;
        box.visible = true;
        box.animation.play("anim", true);
        box.animation.finishCallback = (_)->box.visible = false;
        
        // _iconFrame.loadGraphic(Prize.getIconPath(medal.id));
        // var right = _points.x + _points.width;
        // _points.text = Std.string(medal.value);
        // _points.x = right - _points.width;// because alignment.right doesn't work
        // _name.text = medal.name.toUpperCase();
        // _name.x = _nameX + _nameRect.width;
        // _nameRect.x = -_nameRect.width;
        // _name.clipRect = new FlxRect();
        // _name.clipRect.copyFrom(_nameRect);
        // _name.visible = false;
        
        // FlxTween.tween(this, { y:0 }, 0.5, { ease:FlxEase.backOut, onComplete:onInComplete } );
    }
    
    function onAnimComplete():Void {
        
        visible = false;
        playNextAnim();
    }
    
    #if debug
    override function update(elapsed:Float)
    {
        super.update(elapsed);
        
        if (FlxG.keys.justPressed.ENTER)
            playDebugAnim();
    }
    #end
    
    function resetForNewState():Void
    {
        var finished = box.animation.finished;
        var frame = box.animation.curAnim.curFrame;
        box.loadGraphic(BOX_PATH, true, 65, 79);
        box.animation.add("anim", [for (i in 0...animation.frames) i], 10, false);
        if (!finished)
            box.animation.play("anim", true, false, frame);
        
        finished = medal.animation.finished;
        frame = medal.animation.curAnim.curFrame;
        medal.loadGraphic(MEDAL_PATH, true, 97, 79);
        medal.animation.add("anim", [0,1,1,1,2,3,4,5,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,7,8,9], 10);
        if (!finished)
            medal.animation.play("anim", true, false, frame);
    }
    
    static public function getInstance()
    {
        if (instance == null)
            instance = new MedalPopup();
        else
            instance.resetForNewState();
        return instance;
    }
}