package data;

import flixel.util.FlxSignal;
import io.newgrounds.NG;
import io.newgrounds.objects.Medal;
import io.newgrounds.objects.Score;
import io.newgrounds.objects.ScoreBoard;
import io.newgrounds.components.ScoreBoardComponent.Period;
import io.newgrounds.objects.Error;
import io.newgrounds.objects.events.Response;
import io.newgrounds.objects.events.Result.GetDateTimeResult;

import openfl.display.Stage;

import flixel.FlxG;

class NGio
{
	
	public static var isLoggedIn:Bool = false;
	public static var scoreboardsLoaded:Bool = false;
	public static var ngDate:Date;
	
	public static var scoreboardArray:Array<Score> = [];
	
	public static var ngDataLoaded(default, null):FlxSignal = new FlxSignal();
	public static var ngScoresLoaded(default, null):FlxSignal = new FlxSignal();
	
	static public function attemptAutoLogin(callback:Void->Void) {
		
		if (isLoggedIn)
		{
			trace("already logged in");
			return;
		}
		
		ngDataLoaded.addOnce(callback);
		
		function onSessionFail(e)
		{
			ngDataLoaded.remove(callback);
			callback();
		}
		
		trace("connecting to newgrounds");
		NG.createAndCheckSession(APIStuff.APIID, APIStuff.DebugSession, onSessionFail);
		NG.core.initEncryption(APIStuff.EncKey);
		NG.core.onLogin.add(onNGLogin);
		NG.core.verbose = true;
		
		if (!NG.core.attemptingLogin)
			callback();
	}
	
	static public function startManualSession(callback:ConnectResult->Void, onPending:((Bool)->Void)->Void):Void
	{
		if (NG.core == null)
			throw "call NGio.attemptLogin first";
		
		function onClickDecide(connect:Bool):Void
		{
			if (connect)
				NG.core.openPassportUrl();
			else
			{
				NG.core.cancelLoginRequest();
				callback(Cancelled);
			}
		}
		
		NG.core.requestLogin(
			callback.bind(Succeeded),
			onPending.bind(onClickDecide),
			(error)->callback(Failed(error)),
			callback.bind(Cancelled)
		);
	}
	
	static function onNGLogin():Void
	{
		trace ('logged in! user:${NG.core.user.name}');
		isLoggedIn = true;
		// Load medals then call onNGMedalFetch()
		NG.core.requestMedals(onNGMedalFetch);
		
		ngDataLoaded.dispatch();
	}
	
	static public function checkNgDate(onComplete:Void->Void):Void
	{
		NG.core.calls.gateway.getDatetime()
		.addDataHandler(
			function(response)
			{
				if (response.success && response.result.success) 
					ngDate = Date.fromString(response.result.data.dateTime.substring(0, 10));
			}
		).addSuccessHandler(onComplete)
		.addErrorHandler((_)->onComplete())
		.send();
	}
	
	// --- MEDALS
	static function onNGMedalFetch():Void
	{
		
		/*
		// Reading medal info
		for (id in NG.core.medals.keys())
		{
			var medal = NG.core.medals.get(id);
			trace('loaded medal id:$id, name:${medal.name}, description:${medal.description}');
		}
		
		// Unlocking medals
		var unlockingMedal = NG.core.medals.get(54352);// medal ids are listed in your NG project viewer 
		if (!unlockingMedal.unlocked)
			unlockingMedal.sendUnlock();
		*/
	}
}

enum ConnectResult
{
	Succeeded;
	Failed(error:Error);
	Cancelled;
}