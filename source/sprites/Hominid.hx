package sprites;

import flixel.FlxSprite;

class Hominid extends FlxSprite
{
    public function new (X:Float, Y:Float)
    {
        super(X, Y);

        loadGraphic("assets/images/minigame/alien.png", true, Std.int(144 / 3), 48);

    }
}