package sprites;

import flixel.group.FlxSpriteGroup;

abstract InfoBox(FlxSpriteGroup) to FlxSpriteGroup
{
    public function new (text, x = 0.0, y = 0.0, border = 1)
    {
        super();
        this.x = x;
        this.y = y;
        var box = new FlxSprite(0, 0);
    }
}