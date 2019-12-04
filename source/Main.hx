package;

import flixel.FlxGame;
import openfl.Assets;
import openfl.display.Sprite;
import openfl.events.MouseEvent;

import states.*;

class Main extends Sprite
{
	public function new()
	{
		super();
		addChild(new FlxGame(320, 180, IntroState, 1, 60, 60, true));
		
		//stage.showDefaultContextMenu = false;
		stage.addEventListener(MouseEvent.MOUSE_WHEEL, (e)->e.preventDefault());
	}
}