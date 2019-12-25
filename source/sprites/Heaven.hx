package sprites;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

@:forward
abstract Heaven(FlxSpriteGroup) to FlxSpriteGroup
{
    inline public function new ()
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
    
    public function spawnNpcs()
    {
        var cam = FlxG.camera;
        for (c in 0...24)
        {
            var npc:NPC = new NPC
                ( FlxG.random.float(20, FlxG.width - 40)
                , FlxG.random.float(20, FlxG.height - 40)
                );
            npc.updateSprite(c);
            npc.active = false;
            this.add(npc);
            this.add(npc.setEmotion(Dead, true));
        }
    }
}