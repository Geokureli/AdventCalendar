package states;

class HeavenState extends BaseState
{
    
    
    override function loadLevel():Void
    {
        parseLevel('assets/data/levels/heaven.json');
        
        // #if debug FlxG.debugger.drawDebug = true; #end
    }
}