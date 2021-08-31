package;

import lime.utils.Assets;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.FlxSubState;
import flixel.tweens.FlxTween;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;

class GalleryState extends MusicBeatState {

    // Define image filename in the textfile (put in preload/data):
    static var textFilename:String = 'imagelist-newgrounds';
    // Structure: [code number stuff]_[artist username]_[title image].png
    // This is how the filename should be when you download images from Newgrounds

    // Gallery folder name:
    var folderName:String = 'gallery';
    // Put images in the folder named above

    var imgGrp:FlxTypedGroup<FlxSprite>;
    var shaGrp:FlxTypedGroup<FlxSprite>;

    var camFollow:FlxObject;

    var floatSh:Float = 0;

    public static var curSelect = 0;

    var imgFilename = CoolUtil.coolTextFile(Paths.txt(textFilename));

    public static function metaShit():Array<Dynamic> {
        var stringig:String = Assets.getText(Paths.txt(textFilename));
        var eachArray:Array<String> = stringig.split('\n');
        var wholeArray:Array<Dynamic> = [];
        for (i in eachArray){
            wholeArray.push(i.split('_'));
        }
        return wholeArray;
    }
    var cre:TextShit;
    var arrowDown:TextShit;
    var ins:TextShit;


    override function create() {
        super.create();

        imgGrp = new FlxTypedGroup<FlxSprite>();
        shaGrp = new FlxTypedGroup<FlxSprite>();
        
        var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
        bg.scrollFactor.set();
        bg.screenCenter();
        bg.antialiasing = true;
        bg.color = 0xFF999999;
        add(bg);

        camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

        var heightLim = Std.int(FlxG.height-100);

        for (i in 0...metaShit().length)
        {
            var imgPath = Paths.image(folderName+'/'+imgFilename[i]);
            // folder name + image filename in the folder

            var img:FlxSprite = new FlxSprite().loadGraphic(imgPath);
            img.setGraphicSize(0, heightLim);
            img.updateHitbox();
            img.centerOrigin();
            img.screenCenter(X);
            img.scrollFactor.set(0, 1);
            img.y = (i * (heightLim+20));
            img.ID = i;
            imgGrp.add(img);
            img.antialiasing = true;

            var shOff = 20;

            var shadow:FlxSprite = new FlxSprite().makeGraphic(Std.int(img.width),Std.int(img.height),0xff000000);
            shadow.setGraphicSize(0, heightLim);
            shadow.updateHitbox();
            shadow.centerOrigin();
            shadow.screenCenter(X);
            shadow.scrollFactor.set(0,1);
            shadow.y = (i * (heightLim+20)) + shOff;
            shadow.x += shOff;
            shadow.ID = i;
            shaGrp.add(shadow);
        }

        FlxG.camera.follow(camFollow, null, 0.5);

        changeImg();

        cre = new TextShit(10,FlxG.height-50, FlxG.width, "ARTIST: ", 30, LEFT);

        arrowDown = new TextShit(0, FlxG.height-100 ,0,"▼",50,CENTER);
        arrowDown.screenCenter(X);
        arrowDown.alpha = 1;

        ins = new TextShit(0, 20, FlxG.width, "ENTER: Open image's link - A: Open artist's profile", 25, CENTER);

        add(shaGrp);
        add(imgGrp);
        add(arrowDown);
        add(ins);
        add(cre);

        yeaDidPressArrow = false;
    }

    function changeImg(meme:Int=0) {
        curSelect += meme;
        if (curSelect >= imgGrp.length)
            curSelect = 0;
        if (curSelect < 0)
            curSelect = imgGrp.length - 1;

        imgGrp.forEach(function(img:FlxSprite) {
            img.alpha = 0.5;
            if (img.ID == curSelect)
            {
                img.alpha = 1;
                camFollow.setPosition(img.getMidpoint().x, img.getMidpoint().y);
            }
            img.updateHitbox();
        });

        shaGrp.forEach(function(sh:FlxSprite) {
            sh.alpha = 0.15;
            if (sh.ID == curSelect)
                sh.alpha = 0.3;
            sh.updateHitbox();
        });
    }

    var yeaDidPressArrow:Bool = false;

    override function update(elapsed:Float) {

        super.update(elapsed);

        floatSh += 0.1;
        arrowDown.y += Math.sin(floatSh);

        cre.text = "ARTIST: "+ metaShit()[curSelect][1].toUpperCase();

        if (controls.UP_P || controls.DOWN_P)
        {
            yeaDidPressArrow = true;

            if (controls.UP_P)
                changeImg(-1);
            if (controls.DOWN_P)
                changeImg(1);
        }

        var imgLink = "https://www.newgrounds.com/art/view/"+metaShit()[curSelect][1]+ "/"+metaShit()[curSelect][2];
        var artistLink = "https://"+metaShit()[curSelect][1]+ ".newgrounds.com";
        
        if (controls.BACK)
            FlxG.switchState(new MainMenuState());
        if (FlxG.keys.justPressed.ENTER)
            FlxG.openURL(imgLink);
        if (FlxG.keys.justPressed.A)
            FlxG.openURL(artistLink);
        
        if (yeaDidPressArrow)
        {
            new FlxTimer().start(3, function(tmr:FlxTimer) {
                FlxTween.tween(arrowDown, {alpha:0}, 0.5, {onComplete: function(twn:FlxTween) {
                        remove(arrowDown);
                }});
            });
        }
    }
}

class TextShit extends FlxText {
    public function new(x:Float=0, y:Float=0, wfield:Float=0, ?text:String, size:Int, ?align:FlxTextAlign) {
        super(x,y,wfield,text);
        setFormat("VCR OSD Mono", size, 0xFFffffff, align, OUTLINE, 0xFF000000);
        borderSize = 1.7;
        scrollFactor.set();
    }
}
