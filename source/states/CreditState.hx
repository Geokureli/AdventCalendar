package states;

import sprites.Credits;
import flixel.FlxState;

class CreditState extends FlxState
{
    override function create()
    {
        super.create();
        
        var credits = new Credits();
        add(credits);
    }
}