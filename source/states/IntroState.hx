package states;

import flixel.FlxG;
import flixel.ui.FlxButton;
import flixel.util.FlxTimer;
import flixel.text.FlxBitmapText;

import data.Calendar;
import data.NGio;
import sprites.Button;
import sprites.Font;

class IntroState extends flixel.FlxState
{
    inline static var MSG_TIME = 1.5;
    var msg:FlxBitmapText;
    var timeout:FlxTimer;
    
    override public function create():Void
    {
        super.create();
        FlxG.camera.bgColor = FlxG.stage.color;
        
        add(msg = new FlxBitmapText(new XmasFont()));
        msg.text = "Checking naughty list...";
        msg.alignment = CENTER;
        msg.screenCenter(XY);
        
        new FlxTimer().start(MSG_TIME,
            function(_)
            {
                timeout = new FlxTimer().start(20, showErrorAndBegin);
                
                NGio.attemptAutoLogin(onAutoConnectResult);
            }
        );
    }
    
    function onAutoConnectResult():Void
    {
        timeout.cancel();
        if (NGio.isLoggedIn)
            onLogin();
        else
            NGio.startManualSession(onManualConnectResult, onManualConnectPending);
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
        
        add(yes = new Button( 100, msg.y + msg.height + 5, onDecide.bind(true ), "assets/images/ui/button_yes.png"));
        add(no  = new Button(190, msg.y + msg.height + 5, onDecide.bind(false), "assets/images/ui/button_no.png" ));
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
        Calendar.init(FlxG.switchState.bind(new CabinState()));
    }
    
    inline function showErrorAndBegin(_ = null)
    {
        showMsgAndBegin("Could not connect to Newgrounds\nNot eligible for medals");
    }
    
    function showMsgAndBegin(message:String)
    {
        msg.text = message;
        msg.screenCenter(XY);
        new FlxTimer().start(MSG_TIME, (_)->beginGame());
    }
}