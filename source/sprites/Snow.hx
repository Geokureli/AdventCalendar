package sprites;

import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.effects.particles.*;

abstract Snow(FlxEmitter) to FlxEmitter
{
    inline public function new(layerNum:Int)
    {
        FlxG.log.add("add emitter");
        var parallax:Float = layerNum * 5.0;
        var size = Math.ceil(5 / parallax);
        
        this = new FlxEmitter(288 - 36 - 10, 162 - 11, 200);
        this.makeParticles(size, size, FlxColor.WHITE, 200);
        this.start(false, 0.3);
        
        this.velocity.active = false;
        this.lifespan.set(20);
        this.acceleration.start.min.x = 2  / parallax;
        this.acceleration.start.max.x = 10 / parallax;
        this.acceleration.start.min.y = 25 / parallax;
        this.acceleration.start.max.y = 40 / parallax;
        this.acceleration.end.min.x = 1  / parallax;
        this.acceleration.end.max.x = 30 / parallax;
        this.acceleration.end.min.y = 25 / parallax;
        this.acceleration.end.max.y = 40 / parallax;
        this.width = 400;
        
        // _emitterBG.cameras = [uiCamera];
        // emitter.forEach(function(p:FlxParticle)
        // {
        //     p.cameras = [uiCamera]; 
        //     p.scrollFactor.x = snowLayer / 2;
        // });
    }
}