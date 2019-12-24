package states;

import flixel.tweens.FlxEase;
import flixel.math.FlxRect;
import sprites.Button;
import sprites.Font;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxBitmapText;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBitmapTextButton;

import flixel.addons.display.FlxSliceSprite;

import openfl.geom.Rectangle;
import openfl.display.BitmapData;

class CalendarSubstate extends flixel.FlxSubState
{
    var callback:(Int)->Void;
    var calendar:CalendarSprite;
    
    public function new(callback):Void
    {
        super();
        this.callback = callback;
    }
    
    override function create()
    {
        super.create();
        
        add(calendar = new CalendarSprite(closeAndCallback));
        calendar.startIntro(
            function ()
            {
                var back = new BackButton(FlxG.width - 2, 2, calendar.startOutro.bind(close));
                back.x -= back.width;
                add(back);
                
                var up = new IconButton
                    ( CalendarSprite.DATES_X + CalendarSprite.WEEK_WIDTH - 25
                    , 2
                    , "assets/images/ui/upIcon.png"
                    , showPicture
                    );
                back.x -= back.width;
                add(back);
            }
        );
    }
    
    function closeAndCallback(date:Int):Void
    {
        calendar.startOutro(
            function()
            {
                close();
                callback(date);
            }
        );
    }
    
    function showPicture():Void
    {
        
    }
}

abstract CalendarSprite(FlxSpriteGroup) to FlxSpriteGroup
{
    inline static var DURATION = 0.5;
    
    inline static public var GUTTER = 1;
    inline static public var WEEK = 7;
    inline static public var DAYS = 31;
    inline static public var DATE_WIDTH = 31;
    inline static public var DATE_HEIGHT = 23;
    inline static public var WEEK_WIDTH = WEEK * DATE_WIDTH + GUTTER;
    inline static public var DATES_X = (320 - (DATE_WIDTH * WEEK + GUTTER)) / 2;
    inline static public var DATES_Y = 180 - BUFFER - DATE_HEIGHT * 5;
    inline static public var BUFFER = 3;
    
    inline static var HEADER_HEIGHT = 24 + GUTTER;
    inline static var PIC_HEIGHT = 180 - (DATES_Y - HEADER_HEIGHT);
    inline static var BG_HEIGHT = 360 - DATES_Y;
    
    inline public function new (onDateChoose:(Int)->Void)
    {
        this = new FlxSpriteGroup();
        
        var bg = new FlxSliceSprite
            ( "assets/images/ui/calendar/nineslice.png"
            , new FlxRect(1,1,1,1)
            , WEEK_WIDTH + BUFFER * 2
            , BG_HEIGHT
            );
        this.add(bg);
        bg.x = DATES_X - BUFFER;
        bg.y = 180 - BG_HEIGHT;
        
        for (i in 0...WEEK * 5)
        {
            final x = DATES_X + (i % WEEK) * DATE_WIDTH;
            final y = DATES_Y + Std.int(i / WEEK) * DATE_HEIGHT;
            if (i + 1 <= 25)
                this.add(new DateButton(x, y, i + 1, onDateChoose.bind(i)));
            else
                this.add(new DisabledDate(x, y, i - 25 + 1));
        }
        
        var header = new FlxBitmapText(new XmasFont());
        this.add(header);
        header.color = 0xFF222034;
        header.useTextColor = false;
        header.text = "December 2019";
        header.screenCenter(X);
        header.y = DATES_Y - header.height;
    }
    
    public function startIntro(onComplete:()->Void):Void
    {
        this.active = false;
        this.y = -320;
        FlxTween.tween(this, { y:0 }, DURATION,
            { onComplete:(_)->
                {
                    this.active = true;
                    onComplete();
                }
            , ease: FlxEase.backOut
            }
        );
    }
    
    public function startOutro(onComplete:()->Void):Void
    {
        FlxTween.tween(this, { y:-320 }, DURATION, { onComplete:(_)->onComplete() });
    }
}

abstract DateButton(FlxBitmapTextButton) to FlxBitmapTextButton
{
    inline static var GRAPHIC = "assets/images/ui/calendar/dateBtn.png";
    
    inline public function new(x, y, date:Int, onClick)
    {
        this = new FlxBitmapTextButton(x, y, Std.string(date), onClick);
        //bg
        this.loadGraphic(GRAPHIC);
        this.loadGraphic(GRAPHIC, true, Std.int(this.width / 2), Std.int(this.height));
        //date
        final label = this.label;
        label.color = 0xFF222034;
        label.useTextColor = false;
        label.font = new GravFont();
        this.labelOffsets[0].x
            = this.labelOffsets[1].x
            = this.labelOffsets[2].x
            = 31 - label.width;
        this.labelOffsets[0].y
            = this.labelOffsets[1].y
            = this.labelOffsets[2].y
            = 2;
    }
}

abstract DisabledDate(FlxSpriteGroup) to FlxSprite
{
    inline static var GRAPHIC = "assets/images/ui/calendar/disabledDate.png";
    
    inline public function new(x, y, date:Int)
    {
        this = new FlxSpriteGroup(0, 0);
        this.add(new FlxSprite(0, 0, GRAPHIC));
        var text = new FlxBitmapText(new GravFont());
        text.text = Std.string(date);
        text.color = 0xFF222034;
        text.useTextColor = false;
        text.x = 31 - text.width;
        text.y = 2;
        this.add(text);
        this.x = x;
        this.y = y;
    }
}
    