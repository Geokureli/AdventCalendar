package sprites;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.ui.FlxButton;

class Button extends FlxTypedButton<FlxSprite>
{
    public function new(x:Float, y:Float, ?onClick:Void->Void, graphic)
    {
        super(x, y, onClick);
        
        setGraphic(graphic);
    }
    
    inline function setGraphic(graphic):Void
    {
        this.loadGraphic(graphic);
        this.loadGraphic(graphic, true, Std.int(this.width / 2), Std.int(this.height));
    }
}

@:forward
abstract YesButton(Button) to Button
{
    public function new(x, y, ?onClick)
    {
        this = new Button(x, y, onClick, "assets/images/ui/button_yes.png");
    }
}

@:forward
abstract NoButton(Button) to Button
{
    public function new(x, y, ?onClick)
    {
        this = new Button(x, y, onClick, "assets/images/ui/button_no.png");
    }
}

@:forward
abstract OkButton(Button) to Button
{
    public function new(x, y, ?onClick)
    {
        this = new Button(x, y, onClick, "assets/images/ui/button_ok.png");
    }
}

@:forward
abstract BackButton(Button) to Button
{
    public function new(x, y, ?onClick)
    {
        this = new Button(x, y, onClick, "assets/images/ui/back.png");
    }
}

class FullscreenButton extends Button
{
    public function new(x, y)
    {
        super(x, y, toggle, "assets/images/ui/fullscreen_off.png");
    }
    
    function toggle():Void
    {
        FlxG.fullscreen = !FlxG.fullscreen;
        this.setGraphic('assets/images/ui/fullscreen_${FlxG.fullscreen ? "on" : "off"}.png');
    }
}