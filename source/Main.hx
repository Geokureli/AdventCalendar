package;

import flixel.FlxGame;
import openfl.Assets;
import openfl.display.Sprite;

import states.*;

class Main extends Sprite
{
	public function new()
	{
		super();
		addChild(new FlxGame(0, 0, IntroState, 1, 60, 60, true));
		
		//stage.showDefaultContextMenu = false;
	}
}