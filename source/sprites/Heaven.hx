package sprites;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

abstract Heaven(FlxSpriteGroup) to FlxSpriteGroup
{
    public function new ()
    {
        this = new FlxSpriteGroup();
        
        this.add(new FlxSprite("assets/images/props/heaven/heaven.png"));
        
        var bottom = new FlxSprite("assets/images/props/heaven/heaven_back.png");
        bottom.screenCenter(X);
        bottom.y = FlxG.height - bottom.height / 2;
        this.add(bottom);
        
        var tree = new FlxSprite("assets/images/props/heaven/tree_topper.png");
        tree.screenCenter(XY);
        this.add(tree);
    }
}