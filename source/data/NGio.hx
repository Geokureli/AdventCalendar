package data;

import flixel.util.FlxSignal;
import io.newgrounds.NG;
import io.newgrounds.objects.Medal;
import io.newgrounds.objects.Score;
import io.newgrounds.objects.ScoreBoard;
import io.newgrounds.components.ScoreBoardComponent.Period;
import io.newgrounds.objects.events.Response;
import io.newgrounds.objects.events.Result.GetDateTimeResult;
import openfl.display.Stage;

import flixel.FlxG;

/**
 * MADE BY GEOKURELI THE LEGENED GOD HERO MVP
 */
class NGio
{
	
	public static var isLoggedIn:Bool = false;
	public static var scoreboardsLoaded:Bool = false;
	public static var ngDate:Date;
	
	public static var scoreboardArray:Array<Score> = [];
	
	public static var ngDataLoaded(default, null):FlxSignal = new FlxSignal();
	public static var ngScoresLoaded(default, null):FlxSignal = new FlxSignal();
	
	static public function login(callback:Void->Void) {
		
		if (isLoggedIn)
		{
			trace("already logged in");
			return;
		}
		
		ngDataLoaded.addOnce(callback);
		
		trace("connecting to newgrounds");
		NG.createAndCheckSession(APIStuff.APIID, true, #if debug APIStuff.DebugSession, #end
			function(e)
			{
				ngDataLoaded.remove(callback);
				callback();
			}
		);
		
		NG.core.verbose = true;
		// Set the encryption cipher/format to RC4/Base64. AES128 and Hex are not implemented yet
		NG.core.initEncryption(APIStuff.EncKey);// Found in you NG project view
		
		trace(NG.core.attemptingLogin);
		
		if (NG.core.attemptingLogin)
		{
			/* a session_id was found in the loadervars, this means the user is playing on newgrounds.com
			 * and we should login shortly. lets wait for that to happen
			 */
			trace("attempting login");
			NG.core.onLogin.add(onNGLogin);
		}
		else
		{
			/* They are NOT playing on newgrounds.com, no session id was found. We must start one manually, if we want to.
			 * Note: This will cause a new browser window to pop up where they can log in to newgrounds
			 */
			NG.core.requestLogin(onNGLogin);
		}
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