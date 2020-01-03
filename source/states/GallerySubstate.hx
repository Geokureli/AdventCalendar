package states;

import data.Calendar;
import data.NGio;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.ui.FlxSpriteButton;
import flixel.util.FlxColor;
import flixel.input.gamepad.FlxGamepad;

/**
 * ...
 * @author NInjaMuffin99
 */
class GallerySubstate extends FlxSubState 
{
	
	private var data:ArtData;
	private var curAnimPlaying:Int = 0;
	private var imageText:FlxText;
	private var infoBox:FlxSpriteButton;
	private var bigPreview:FlxSprite;
	private var bigImage:FlxSpriteGroup;
	private var textBG:FlxSpriteButton;
	private var onClose:Null<()->Void>;
	
	// GET TOUCH CONTROLS FOR EXITING GOING HERE
	public function new(data, ?onClose:()->Void) 
	{
		this.data = data;
		this.onClose = onClose;
		super();
	}
	
	override public function create():Void 
	{
		FlxG.camera.bgColor = FlxColor.TRANSPARENT;
		
		bigImage = new FlxSpriteGroup();
		bigPreview = new FlxSprite();
		bigPreview.antialiasing = data.antiAlias;
		bigImage.add(bigPreview);
		bigImage.scrollFactor.set();
		
		
		imageText = new FlxText(0, FlxG.height - 16, FlxG.width - 6, "", 8);
		imageText.scale.set(0.5, 0.5);
		imageText.updateHitbox();
		imageText.alignment = FlxTextAlign.CENTER;
		imageText.scrollFactor.set();
		imageText.screenCenter(X);
		
		infoBox = new FlxSpriteButton(imageText.x - 2, imageText.y + 2, null, function(){
			FlxG.openURL(data.getProfileLink());
		});
		infoBox.makeGraphic(Std.int(imageText.width) + 4, Std.int(imageText.height) + 4, FlxColor.BLACK);
		infoBox.alpha = 0.5;
		infoBox.screenCenter(X);
		
		
		// offset because the safari search bar covers the game a bit i think
		var offset = 0;
		#if html5
			if (Std.string(FlxG.html5.browser) == "SAFARI")
				offset = 60;

		#end
		
		var msg = 'Current Pic - ${FlxG.onMobile ? "Tap" : "Click"} here to exit';
		var text:FlxText = new FlxText(10, 10 + offset, 0, msg, 8);
		text.scale.set(0.5, 0.5);
		text.updateHitbox();
		text.scrollFactor.set();
		
		textBG = new FlxSpriteButton(text.x - 2, text.y - 2, null, close);
		textBG.makeGraphic(Std.int(text.width) + 4, Std.int(text.height) + 5, FlxColor.BLACK);
		textBG.alpha = 0.5;
		textBG.scrollFactor.set();
		
		add(bigImage);
		
		add(textBG);
		add(infoBox);
		add(imageText);
		add(text);
		
		bigImage.visible = false;
		
		openImage();
		
		super.create();
	}
	
	
	private function openImage():Void
	{
		curAnimPlaying = 0;
		bigImage.visible = true;
		
		// regular artwork
		if (NGio.isNaughty)
			bigPreview.loadGraphic('assets/images/artwork/naughty.jpg');
		else
			bigPreview.loadGraphic(data.getPath());
		imageText.text = "Art by " + data.credit;
		
		
		var isAnimated = false;
		var horizSize:Int = Std.int(bigPreview.width);
		var vertSize:Int = Std.int(bigPreview.height);
		// checks if animated
		if (data.frames != null)
		{
			isAnimated = true;
			horizSize = Std.int(horizSize / data.frames);
		}
		
		if (isAnimated)
			bigPreview.loadGraphic(data.getPath(), isAnimated, horizSize, vertSize);
		
		bigPreview.setGraphicSize(0, Std.int(FlxG.height));
		bigPreview.updateHitbox();
		bigPreview.screenCenter();
		
		if (bigPreview.width >= FlxG.width)
			bigPreview.setGraphicSize(Std.int(FlxG.width));
		
		bigPreview.updateHitbox();
		bigPreview.screenCenter();
	}
	
	override public function update(elapsed:Float):Void 
	{
		// note to self: if this super.update() isnt at the top of this function
		// there's errors with the FlxSpriteButtons where it fuks some bullshit up with the mouse and nulls and shit 
		super.update(elapsed);
		
		#if !mobile
			keyboardControls();
			
			var gamepad:FlxGamepad = FlxG.gamepads.lastActive;
			if (gamepad != null)
			{
				gamepadControls(gamepad);
			}
		#end
		
		imageText.text
			= "Art by " + data.credit
			+ "\n" + (FlxG.onMobile ? "Tap" : "Click") + " here to open " + data.artist + "'s Newgrounds page";
		
		if (FlxG.keys.justPressed.ENTER)
			FlxG.openURL(data.getProfileLink());
		
		dragControls();
	}
	
	
	private function keyboardControls():Void
	{
		#if !mobile
		if (FlxG.mouse.wheel != 0)
		{
			bigPreview.setGraphicSize(Std.int(bigPreview.width + (FlxG.mouse.wheel * 1.5)));
			bigPreview.updateHitbox();
			bigPreview.screenCenter();
		}
		#end
		
		if (FlxG.keys.anyJustPressed([ESCAPE, SPACE, X]))
			close();
		
		// REPLACE THESE TO BE CLEANER LATER AND WITH MORE KEYS
		if (FlxG.keys.pressed.D)
		{
			bigPreview.offset.x += 5;
		}
		if (FlxG.keys.pressed.W)
		{
			bigPreview.offset.y -= 5;
		}	
		if (FlxG.keys.pressed.A)
		{
			bigPreview.offset.x -= 5;
		}
		if (FlxG.keys.pressed.S)
		{
			bigPreview.offset.y += 5;
		}
	}
	
	private function gamepadControls(gamepad:FlxGamepad):Void
	{
		//Close Substate
		if (gamepad.anyPressed(["B"]))
			close();
		
		if (gamepad.anyPressed(["DOWN", "DPAD_DOWN", "LEFT_STICK_DIGITAL_DOWN"]))
		{
			bigPreview.offset.y += 5;
		}
		if (gamepad.anyPressed(["UP", "DPAD_UP", "LEFT_STICK_DIGITAL_UP"]))
		{
			bigPreview.offset.y -= 5;
		}	
		if (gamepad.anyPressed(["LEFT", "DPAD_LEFT", "LEFT_STICK_DIGITAL_LEFT"]))
		{
			bigPreview.offset.x -= 5;
		}
		if (gamepad.anyPressed(["RIGHT", "DPAD_RIGHT", "LEFT_STICK_DIGITAL_RIGHT"]))
		{
			bigPreview.offset.x += 5;
		}
		
		//Zooms
		if (gamepad.anyPressed(["RIGHT_TRIGGER", "RIGHT_STICK_DIGITAL_UP"]))
		{
			bigPreview.setGraphicSize(Std.int(bigPreview.width + 10));
			bigPreview.updateHitbox();
			bigPreview.screenCenter();
		}
		if (gamepad.anyPressed(["LEFT_TRIGGER", "RIGHT_STICK_DIGITAL_DOWN"]))
		{
			bigPreview.setGraphicSize(Std.int(bigPreview.width - 10));
			bigPreview.updateHitbox();
			bigPreview.screenCenter();
		}
	}
	
	private var dragPos:FlxPoint = new FlxPoint();
	private var picPosOld:FlxPoint = new FlxPoint();
	
	private var touchesLength:Float = 0;
	private var touchesAngle:Float = 0;
	private var picAngleOld:Float = 0;
	private var picWidthOld:Float = 0;
	
	private function dragControls():Void
	{	
		var pressingButton:Bool = false;
		var zoomPressingButton:Bool = false;
		var buttonJustPressed:Bool = false;
		var zoomButtonJustPressed:Bool = false;
		var buttonPos:FlxPoint = new FlxPoint();
		
		// its called touchNew, but really its the length of the line between the two touches
		// or the length between the center of the image and the mouse on right click
		var touchNew:Float = 0;
		var rads:Float = 0;
		var midScreen:FlxPoint = new FlxPoint();
		midScreen.set(FlxG.width / 2, FlxG.height / 2);
				
		
		#if !mobile
			if (FlxG.mouse.pressed)
			{
				if (FlxG.mouse.justPressed)
				{
					dragPos = FlxG.mouse.getPosition();
					buttonJustPressed = true;
				}
				
				pressingButton = true;
				buttonPos = FlxG.mouse.getPosition();
			}
			
			if (FlxG.mouse.pressedRight)
			{
				if (FlxG.mouse.justPressedRight)
				{
					zoomButtonJustPressed = true;
				}
				
				zoomPressingButton = true;
				
				rads = Math.atan2(midScreen.y - FlxG.mouse.y, midScreen.x - FlxG.mouse.x);
				touchNew = FlxMath.vectorLength(midScreen.x - FlxG.mouse.x, midScreen.y - FlxG.mouse.y);
			}
			
		#else
			if (FlxG.touches.list.length == 1)
			{
				if (FlxG.touches.list[0].justPressed)
				{
					dragPos = FlxG.touches.list[0].getPosition();
					buttonJustPressed = true;
				}
				
				pressingButton = true;
				buttonPos = FlxG.touches.list[0].getPosition();
			}
			if (FlxG.touches.list.length == 2)
			{
				
				if (FlxG.touches.list[1].justPressed)
				{
					zoomButtonJustPressed = true;
				}
				
				zoomPressingButton = true;
				
				rads = Math.atan2(FlxG.touches.list[0].y - FlxG.touches.list[1].y, FlxG.touches.list[0].x - FlxG.touches.list[1].x);
				touchNew = FlxMath.vectorLength(FlxG.touches.list[0].x - FlxG.touches.list[1].x, FlxG.touches.list[0].y - FlxG.touches.list[1].y);
			}
		#end
		
		// drag behaviour
		if (pressingButton)
		{
			if (buttonJustPressed)
			{
				picPosOld.x = bigPreview.offset.x;
				picPosOld.y = bigPreview.offset.y;
			}
		
			
			var xPos:Float = buttonPos.x - dragPos.x;
			var yPos:Float = buttonPos.y - dragPos.y;
			
			bigPreview.offset.x = picPosOld.x - xPos;
			bigPreview.offset.y = picPosOld.y - yPos;
			
		}
		
		// zoom behaviour
		if (zoomPressingButton)
		{	
			if (zoomButtonJustPressed)
			{
				touchesLength = touchNew;
				touchesAngle = FlxAngle.asDegrees(rads);
				picAngleOld = bigPreview.angle;
				picWidthOld = bigPreview.width;
			}
			
			
			var degs = FlxAngle.asDegrees(rads);
			// bigPreview.angle = (picAngleOld + degs - touchesAngle);
			
			FlxG.watch.addQuick("Degs/Angle", degs);
			
			bigPreview.setGraphicSize(Std.int(picWidthOld * (touchNew / touchesLength)));
			bigPreview.updateHitbox();
			bigPreview.screenCenter();
			
		}
	}
	
	override function close()
	{
		super.close();
		
		if (onClose != null)
		{
			onClose();
			onClose = null;
		}
	}
	
}