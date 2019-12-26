package states;

import openfl.Assets;
import flixel.FlxG;
import flixel.ui.FlxButton;
import flixel.util.FlxTimer;
import flixel.text.FlxBitmapText;

import data.APIStuff;
import data.Calendar;
import data.Instrument;
import data.NGio;
import sprites.Button;
import sprites.Font;

class IntroState extends flixel.FlxState
{
    inline static var MSG_TIME = 1.5;
    var msg:FlxBitmapText;
    var timeout:FlxTimer;
    var complete = false;
    var waitTime = MSG_TIME;
    
    var debugFutureEnabled = false;
    
    override public function create():Void
    {
        super.create();
        FlxG.camera.bgColor = FlxG.stage.color;
        
        add(msg = new FlxBitmapText(new XmasFont()));
        msg.text = "Checking naughty list...";
        if (APIStuff.DebugSession != null)
            msg.text += "\n Debug Session";
        if (Calendar.isDebugDay)
            msg.text += "\n Debug Day";
        
        msg.alignment = CENTER;
        msg.screenCenter(XY);
        
        timeout = new FlxTimer().start(20, showErrorAndBegin);
        NGio.attemptAutoLogin(onAutoConnectResult);
    }
    
    function onAutoConnectResult():Void
    {
        timeout.cancel();
        #if BYPASS_LOGIN
        showMsgAndBegin("Login bypassed\nNot eligible for medals");
        #else
        if (NGio.isLoggedIn)
            onLogin();
        else
            NGio.startManualSession(onManualConnectResult, onManualConnectPending);
        #end
    }
    
    function onManualConnectPending(callback:(Bool)->Void)
    {
        msg.text = "Log in to Newgrounds?";
        msg.screenCenter(XY);
        var yes:Button;
        var no:Button;
        
        function onDecide(isYes:Bool)
        {
            remove(yes);
            remove(no);
            callback(isYes);
        }
        
        add(yes = new YesButton(100, msg.y + msg.height + 5, onDecide.bind(true )));
        add(no  = new NoButton (190, msg.y + msg.height + 5, onDecide.bind(false)));
    }
    
    function onManualConnectResult(result:ConnectResult):Void
    {
        switch(result)
        {
            case Succeeded: onLogin();
            case Failed(_): showErrorAndBegin();
            case Cancelled: showMsgAndBegin("Login cancelled\nNot eligible for medals");
        }
    }
    
    function onLogin()
    {
        if (NGio.isNaughty)
            showMsgAndBegin("You've been naughty!");
        else if (NGio.wouldBeNaughty)
            showMsgAndBegin("You've been naughty!\n You're lucky it's Christmas");
        else
            beginGame();
    }
    
    function beginGame():Void
    {
        Calendar.init
        (
            ()->
            {
                complete = true;
                if (debugFutureEnabled && NGio.isWhitelisted && Calendar.isAdvent && Calendar.day != 24)
                    enableTimeTravel();
            }
        );
    }
    
    function enableTimeTravel():Void
    {
        Calendar.showDebugNextDay();
        msg.text += "\nTime travel activated";
        if (waitTime < 0.5)
            waitTime = 0.5;
    }
    
    inline function showErrorAndBegin(_ = null)
    {
        showMsgAndBegin("Could not connect to Newgrounds\nNot eligible for medals");
    }
    
    function showMsgAndBegin(message:String)
    {
        msg.text = message;
        msg.screenCenter(XY);
        waitTime = MSG_TIME;
        beginGame();
    }
    
    override function update(elapsed:Float):Void
    {
        super.update(elapsed);
        waitTime -= elapsed;
        
        if (FlxG.keys.pressed.SPACE && !debugFutureEnabled)
        {
            debugFutureEnabled = true;
            if (complete)
                enableTimeTravel();
        }
        
        if (waitTime <= 0 && complete)
        {
            var allowPlay = true;
            
            var missing = [];
            // var today = Calendar.today;
            // if (!Assets.exists(today.getArtPath()))             missing.push("art");
            // if (!Assets.exists(today.getThumbPath()))           missing.push("thumb");
            // if (!Assets.exists(today.getSongPath()))            missing.push("song");
            // if (!Assets.exists(today.getArtistSnowmanPath()))   missing.push("artist-snowman");
            // if (!Assets.exists(today.getMusicianSnowmanPath())) missing.push("musician-snowman");
            // if (Calendar.today.tv == null)                      missing.push("tv");
            // if (!Assets.exists(Calendar.getPresentPath()))      missing.push("present");
            // if (!Assets.exists(Calendar.getMedalPath()))        missing.push("medal");
            
            if (Calendar.today.notReady || missing.length > 0)
            {
                allowPlay = false;
                msg.text = "Today's content is almost done,\nplease try again soon.\n Sorry";
                if (Calendar.isDebugDay || NGio.isWhitelisted)
                {
                    allowPlay = waitTime < -1.0;
                    
                    var text = "Debug Missing:\n" + missing.join(", ");
                    if (Calendar.today.notReady)
                        text += "\n remove blocker";
                    msg.text = text;
                }
                msg.screenCenter(XY);
            }
            
            if (allowPlay)
            {
                Instrument.setInitial();
                FlxG.switchState(new CabinState());
            }
        }
    }
}