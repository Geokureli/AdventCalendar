package states;

import data.NGio;
import data.BitArray;
import data.Calendar;
import flixel.ui.FlxButton;
import flixel.group.FlxGroup;
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

typedef MonthData = 
{
    start:Int,
    days:Int,
    name:String,
    pic:String,
    ?message:String
};

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
        active = false;
        FlxG.fixedTimestep = false;
        calendar.startIntro(
            function ()
            {
                active = true;
                var back = new BackButton(FlxG.width - 2, 2, calendar.startOutro.bind(close));
                back.x -= back.width;
                add(back);
                
                var up = new PanButton(CalendarSprite.DATES_X + CalendarSprite.WEEK_WIDTH - 2, 5, onPanClick);
                up.x -= up.width;
                add(up);
            }
        );
    }
    
    function closeAndCallback(date:Int):Void
    {
        calendar.startOutro(
            function()
            {
                FlxG.fixedTimestep = true;
                close();
                callback(date);
            }
        );
    }
    
    function onPanClick():Void
    {
        active = false;
        function onPanDone()
            active = true;
        
        if (calendar.y == 0)
            calendar.panUp(onPanDone);
        else
            calendar.panDown(onPanDone);
    }
}

@:forward
class CalendarSprite extends FlxSpriteGroup
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
    inline static var PIC_WIDTH = WEEK_WIDTH;
    inline static var BG_HEIGHT = 360 - DATES_Y;
    
    static var looked = new BitArray();
    
    var header:FlxBitmapText;
    var picBg:FlxSprite;
    var pic:FlxSprite;
    var leftButton:Button;
    var rightButton:Button;
    var curMonth:Int;
    var dates = new FlxTypedGroup<FlxSprite>();
    var onDateChoose:(Int)->Void;
    
    public function new (onDateChoose:(Int)->Void)
    {
        super();
        this.onDateChoose = onDateChoose;
        
        var bg = new FlxSprite("assets/images/ui/calendar/back.png");
        this.add(bg);
        bg.x = DATES_X - BUFFER;
        bg.y = 180 - BG_HEIGHT;
        
        picBg = new FlxSprite("assets/images/ui/calendar/pickBack.png");
        this.add(picBg);
        picBg.x = DATES_X;
        picBg.y = bg.y + BUFFER;
        
        header = new FlxBitmapText(new XmasFont());
        this.add(header);
        header.color = 0xFF222034;
        header.useTextColor = false;
        header.y = DATES_Y - header.height;
        
        add(pic = new FlxSprite());
        pic.antialiasing = false;
        
        add(leftButton = new LeftButton(DATES_X, header.y + 2, ()->loadMonth(curMonth - 1)));
        add(rightButton = new RightButton(DATES_X + PIC_WIDTH, header.y + 2, ()->loadMonth(curMonth + 1)));
        rightButton.x -= rightButton.width;
        loadMonth(monthData.length - 1);
    }
    
    function loadMonth(index:Int)
    {
        curMonth = index;
        var data = monthData[index];
        
        for (i in 0...dates.members.length)
        {
            this.remove(dates.members.shift());
        }
        
        final start = data.start;
        final days = data.days;
        for (i in 0...WEEK * 5)
        {
            final x = DATES_X + (i % WEEK) * DATE_WIDTH;
            final y = DATES_Y + Std.int(i / WEEK) * DATE_HEIGHT;
            
            final date = i < start || i - start >= days ? 0 : ((i - start) % days) + 1;
            var dateSprite:FlxSprite;
            if (index == 12 && date <= 25 && date > 0)
                dateSprite = new DateButton(x, y, date, onDateChoose.bind(i));
            else
                dateSprite = new DisabledDate(x, y, date);
            
            dates.add(this.add(dateSprite));
            
            inline function addTag(tag:Tag)
                dates.add(this.add(new TagSprite(dateSprite.x, dateSprite.y, tag)));
            
            if (index == 12)
            {
                if (date == Calendar.day + 1)
                    addTag(Today);
                    
                if (Calendar.seenDays[date-1])
                    addTag(Seen);
                
                if (date == 9)
                    addTag(NickBday);
                
                if (date == 13)
                    addTag(Murder);
            }
        }
        
        header.text = data.name;
        header.screenCenter(X);
        
        pic.loadGraphic(data.pic);
        
        if (pic.width / PIC_WIDTH > pic.height / PIC_HEIGHT)
            pic.setGraphicSize(PIC_WIDTH, 0);
        else
            pic.setGraphicSize(0, PIC_HEIGHT);
        
        pic.updateHitbox();
        pic.x = picBg.x + (picBg.width  - pic.width ) / 2;
        pic.y = picBg.y + (picBg.height - pic.height) / 2;
        
        leftButton.visible = index > 0;
        rightButton.visible = index < monthData.length - 1;
        
        if (y != 0)
            setPageLooked();
    }
    
    function setPageLooked():Void
    {
        trace(y, looked);
        if (!looked[curMonth])
        {
            looked[curMonth] = true;
            var count = 0;
            for (i in 0...looked.getLength())
            {
                if (looked[i])
                    count++;
            }
            
            if (count == 13)
                NGio.unlockMedal(58548);
        }
    }
    
    inline public function startIntro(onComplete:()->Void):Void
    {
        this.y = -320;
        FlxTween.tween(this, { y:0 }, DURATION,
            { onComplete:(_)->onComplete(), ease: FlxEase.backOut }
        );
    }
    
    inline public function startOutro(onComplete:()->Void):Void
    {
        FlxTween.tween
            ( this
            , { y:-320 }
            , DURATION
            , { onComplete:(_)->onComplete(), ease: FlxEase.backIn }
            );
    }
    
    inline public function panUp(onComplete:()->Void):Void
    {
        setPageLooked();
        FlxTween.tween
            ( this
            , { y:BG_HEIGHT - 180 }
            , DURATION
            , { onComplete:(_)->onComplete(), ease:FlxEase.backInOut }
            );
    }
    
    inline public function panDown(onComplete:()->Void):Void
    {
        FlxTween.tween
            ( this
            , { y:0 }
            , DURATION
            , { onComplete:(_)->onComplete(), ease:FlxEase.backInOut }
            );
    }
    
    static public final monthData:Array<MonthData> =
        [ { start:2, days:31, name:"December 2018" , pic:"assets/images/fulp/turtletom.jpg"        }
        , { start:0, days:31, name:"January 2019"  , pic:"assets/images/fulp/fulpAndWife.jpg"      }
        , { start:5, days:28, name:"Febuary 2019"  , pic:"assets/images/fulp/fulpAngry.jpg"        }
        , { start:5, days:31, name:"March 2019"    , pic:"assets/images/fulp/fulpbowl.jpg"         }
        , { start:1, days:30, name:"April 2019"    , pic:"assets/images/fulp/fulpCheers.jpg"       }
        , { start:3, days:31, name:"May 2019"      , pic:"assets/images/fulp/fulpFood.jpg"         }
        , { start:6, days:30, name:"June 2019"     , pic:"assets/images/fulp/fulpMinecraft.png"    }
        , { start:1, days:31, name:"July 2019"     , pic:"assets/images/fulp/fulpStrength.jpg"     }
        , { start:4, days:31, name:"August 2019"   , pic:"assets/images/fulp/fulpSurprised.jpg"    }
        , { start:0, days:30, name:"September 2019", pic:"assets/images/fulp/fulpTwizzler.jpg"     }
        , { start:2, days:31, name:"October 2019"  , pic:"assets/images/fulp/krinkleFulp.jpg"      }
        , { start:5, days:30, name:"November 2019" , pic:"assets/images/fulp/tomMiddleFInger2.jpg" }
        , { start:0, days:31, name:"December 2019" , pic:"assets/images/fulp/fulpDad.jpg"          }
        ];
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
        this.width --;
        this.height--;
        
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
        if (date != 0)
        {
            var text = new FlxBitmapText(new GravFont());
            text.text = Std.string(date);
            text.color = 0xFF222034;
            text.useTextColor = false;
            text.x = 31 - text.width;
            text.y = 2;
            this.add(text);
        }
        this.x = x;
        this.y = y;
    }
}

class PanButton extends Button
{
    inline static var UP = "assets/images/ui/upIcon.png";
    inline static var DOWN = "assets/images/ui/downIcon.png";
    
    public var isUp(get, never):Bool;
    inline function get_isUp():Bool
        return this.label.graphic.key == UP;
    
    public function new(x, y, onClick)
    {
        super(x, y, toggleAndCall.bind(onClick), IconButton.GRAPHIC, UP);
    }
    
    function toggleAndCall(callback:()->Void):Void
    {
        this.setLabelGraphic(isUp ? DOWN : UP);
        if (callback != null)
            callback();
    }
}

abstract RightButton(Button) to Button
{
    inline static var GRAPHIC = "assets/images/ui/rightIcon.png";
    
    inline public function new(x, y, onClick)
    {
        this = new Button(x, y, onClick, IconButton.GRAPHIC, GRAPHIC);
    }
}

abstract LeftButton(Button) to Button
{
    inline static var GRAPHIC = "assets/images/ui/leftIcon.png";
    
    inline public function new(x, y, onClick)
    {
        this = new Button(x, y, onClick, IconButton.GRAPHIC, GRAPHIC);
    }
}

abstract TagSprite(FlxSprite) to FlxSprite
{
    inline public function new(x, y, tag:Tag)
    {
        this = new FlxSprite(x, y);
        this.loadGraphic("assets/images/ui/calendar/dateArt.png", true, 32, 24);
        this.animation.add("frame", [tag.getIndex()]);
        this.animation.play("frame");
    }
}

enum Tag
{
    Seen;
    Today;
    NickBday;
    Murder;
}