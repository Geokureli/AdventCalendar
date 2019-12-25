package sprites;

import data.NGio;
import flixel.FlxG;
import flixel.tweens.FlxTween;
import sprites.Font;
import flixel.text.FlxBitmapText;
import flixel.group.FlxSpriteGroup;

class Credits extends flixel.group.FlxSpriteGroup
{
    inline static var SPEED = 25;
    public function new()
    {
        super();
        
        var text = "TEST TEST";
        for (header=>names in data)
            text += header.toUpperCase() + "\n\n" + names.join("\n") + "\n\n\n";
        
        text += "\n\n\n\n\n\n\n\n\nAnd a very special thanks to\n\n".toUpperCase()
            + (NGio.isLoggedIn ? NGio.userName : "Tom Fulp");
        
        var field = new Text(text);
        add(field);
        field.y = FlxG.height + 50;
        FlxTween.tween(field, { y:field.y - field.height - FlxG.height / 2 }, 51.0);
    }
    
    static var data:Map<String, Array<String>> = 
    [ "Producer"                =>["GeoKureli"    ]
    , "Art, Producer’s Intern"  =>["BrandyBuizel" ]
    , "Tree Decorator"          =>["TheDyingSun"  ]
    , "Snow Statue Sculptor"    =>["NickConter"   ]
    , "Programmer, OG Has-Been" =>["NinjaMuffin99"]
    , "Illustrations"=>
        [ "Cymbourine"
        , "Mintyeggs"
        , "GallowJolt"
        , "MalikJack(PieSaus)"
        , "MrShmoods"
        , "DanFromBavaria"
        , "MKMaffo"
        , "Snackers"
        , "Figburn"
        , "Chdonga"
        , "HenryEYES"
        , "Krinkels"
        , "Mix-Muffin"
        , "ShiroGaia"
        , "Boomnm"
        , "IVOanimations"
        , "dogl"
        , "Mimny"
        , "RGPAnims"
        , "Camuri"
        , "Oddlem"
        , "OniShaggy"
        , "Chobiluck"
        , "ZetoSoul"
        , "WDY25"
        , "snailpirate"
        , "Sevi"
        ]
    , "Music"=>
        [ "Czyszy"
        , "ColeBob"
        , "Carmet"
        , "AlbeGian"
        , "SplatterDash"
        , "SethSkoda"
        ]
    , "Characters based on"=>
        [ "TomFulp"
        , "DanPaladin"
        , "ChutneyGlaze"
        , "BlueBaby(Edmund McMillen)"
        , "Doki(David Firth)"
        , "The-Swain"
        , "Krinkels"
        , "SpazKid"
        , "Oney"
        , "PsychicPebbles"
        , "RicePirate"
        , "chluaid"
        , "aalong64"
        , "FraserMcNiven"
        , "HappyHarry"
        , "IanMichaelMiller"
        , "SomeonesEx"
        , "SrPelo"
        , "TomFulp(again)"
        ]
    , "special thanks"=>
        [ "Tom Fulp(again)"
        , "Newgrounds"
        , "Sky Cross"
        , "ThotThoughts"
        , "SPECIAL THANKS TO BORAT"
        , "TomFulp(4th time)"
        , "Mimny's friends"
        , "TurkeyOnAStick"
        , "Green Pepper Studios"
        , "NG Discord Server"
        , "HotBun"
        , "Newgrounds Supporters"
        ]
    , "In loving Memory of"=>["Cynthia Kurelic"]
    ];
}

@:forward
abstract Text(FlxBitmapText) to FlxBitmapText
{
    inline public function new (text:String)
    {
        this = new FlxBitmapText(new NokiaFont16());
        this.alignment = CENTER;
        this.scrollFactor.set();
        reset(text);
    }
    
    inline function reset(text:String)
    {
        this.text = text;
        this.screenCenter(X);
    }
}