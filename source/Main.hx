package;

import openfl.events.MouseEvent;

import states.*;

class Main extends openfl.display.Sprite
{
	public function new()
	{
		super();
		addChild(new flixel.FlxGame(320, 180, IntroState, 1, 60, 60, true));
		
		//stage.showDefaultContextMenu = false;
		stage.addEventListener(MouseEvent.MOUSE_WHEEL, (e)->e.preventDefault());
		
		flixel.FlxG.sound.muteKeys = [M, ZERO];
	}
}