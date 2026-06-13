import flixel.addons.display.FlxBackdrop;
import flixel.text.FlxTextBorderStyle;
import flixel.group.FlxTypedGroup;
import backend.Controls;
import backend.MusicBeatState;

var Control = Controls.instance;
var camEnd:FlxCamera = new FlxCamera(0, 0, 1280, 720, 1);
var backed;
var song = PlayState.SONG.song.split("\n").join().split("\r").join();

function onCreate() {
	FlxG.cameras.add(camEnd, false);
	game.luaDebugGroup.cameras.push(camEnd);
	// game.transitioning = true;
	// game.endCallback = function() {
	//	CustomSubstate.openCustomSubstate('END', true);
	// }
	// D3Main 820;
}

var isThis = false;

function onCustomSubstateCreate(name) {
	isThis = name == "END";
	if (!isThis)
		return;
	camEnd.y = -720;
	backed = new FlxBackdrop();

	backed.antialiasing = false;
	// backed.loadGraphic(Paths.image("anim/tv"));
	backed.frames = Paths.getSparrowAtlas("anim/tv");
	backed.velocity.set(-100, 100);
	backed.scale.set(3, 3);
	backed.animation.addByPrefix("pog", 'spr_dw_tv_starbgtile_', 16);
	backed.animation.play('pog', true);
	backed.camera = camEnd;
	customSubstate.add(backed);

    
}

function onCustomSubstateCreatePost(n) {
	if (!isThis)
		return;
	FlxTween.tween(camEnd, {y: 0}, 1.8 ,{
        ease: FlxEase.bounceOut,
        onComplete: (_) -> {
		    TW(0);
        }       
    });
}
var COOLText = null;
var Rating ;
var a = 0;
function onCustomSubstateUpdate(n, e) {
	if (!isThis)
		return;
    if (Control.CHAR_SELECT )
		MusicBeatState.resetState();
    if (COOLText!=null){
        a += e*Rating[1];
        COOLText.angle = Math.sin(a)*30*Rating[1];
        COOLText.scale.x = 1+Math.sin(a)*0.3*Rating[1];
        COOLText.scale.y = 1+Math.cos(a*1.2)*0.3*Rating[1];
        COOLText.color=FlxColor.fromHSB((a*100%360)*Rating[1],1,1);
    }
}

function onCustomSubstateDestroy(n) {
	if (!isThis)
		return;
}

function genText_(str,a,?x=0,?y=0,?size=60) {
    var text = new FlxText(0, 0, 0, str, 60, true);
	text.font = Paths.getPath("fronts/fnt_main.ttf");
	text.cameras = [camEnd];
	text.camera= camEnd;
    text.antialiasing = false;
    text.alignment = a;
    text.x = x;
    text.y = y;
    //text.size = size;
    //text = text.setBorderStyle(FlxTextBorderStyle.SHADOW_XY(1  , 1));
    customSubstate.add(text);
    return text;
}

function genText(str,a,?x=0,?y=0) {
    var text = [];

    text.push(genText_(str,a,x+3,y+3));
    text[0].color = 0x002467;
    text.push(genText_(str,a,x+0,y+0));
    //text[1].color = color;
    //trace("a");
    return text;
}

function getTVRating(p) {
    var c = 0;
    for (i in [[50,"Z"],[65,"C"],[80,"B"],[90,"A"],[98,"S"],[101,"T"]]){
        c+=i[0]>90?1:0;
        if (i[0]>p)
            return [i[1],c];
    }
}
 var T;
function TW(a) {
	if (a == 0) {
        var spD = PlayState.SONG.format.split("^");
        var RB = genText(song+" : "+spD[1]+" \n"+ [for (i in 0...song.length) "  "].join("")+"("+spD[0]+")","left",540,0);
        RB[0].alpha = 0;
        RB[1].alpha = 0;
        FlxTween.tween(RB[0], {alpha: 0.8}, 10 ,{
            startDelay: 0.5,
            onUpdate:()->{RB[1].alpha=RB[0].alpha;},   
        });
        var RT = genText("~~~~~~ CONCERT RESULTS ~~~~~~","center",220,100);
        RT[0].visible=false;
        RT[1].visible=false;
        FlxTween.tween(RT[0], {x: 260}, 0.5 ,{
            startDelay: 1,
            onUpdate:()->{RT[1].x=RT[0].x-3;},
            onStart:()->{RT[0].visible=true;RT[1].visible=true;},
            ease: FlxEase.elasticOut,
            onComplete: (_) -> {
                TW(1);
            }       
        });
        
        //MusicBeatState.startTransition();
    }
    if (a == 1){
        new FlxTimer().start(0.5,()->{
        var RT = genText("MISSED NOTES","left",320,150);
        RT[1].color = 0xFF0000;
        RT = genText(game.songMisses,"right",920,150);
        RT[1].color = 0xFF0000;
        TW(2);
        });
    }
    if (a == 2){
        new FlxTimer().start(0.5,()->{
        var RT = genText("NORMAL NOTES","left",320,200);
        var r = game.ratingsData;
        RT = genText(r[1].hits+"+"+(r[2].hits+r[3].hits),"right",920,200);
        TW(3);
        });
    }
    if (a == 3){
        new FlxTimer().start(0.5,()->{
        var RT = genText("GOLD NOTES","left",320,250);
        RT[1].color = 0xF6FF00;
        var r = game.ratingsData;
        RT = genText(r[0].hits,"right",920,250);
        RT[1].color = 0xF6FF00;
        TW(4);
        });
    }
    if (a == 4){
        new FlxTimer().start(0.5,()->{
        var RT = genText("LONGEST COMBO","left",320,300);
        RT = genText(game.maxCombo,"right",920,300);
        TW(5);
        });
    }
    if (a == 5){
        new FlxTimer().start(0.5,()->{
        var RT = genText("TOTAL SCORE","left",320,350);
        new FlxTimer().start(0.5,()->{TW(6);});
        });
    }
    if (a == 6){
        var RT = genText(0,"right",920,350);
        FlxTimer.loop(60/1500,(t)->{
            RT[0].text = Math.min(game.songScore,t*1000);
            RT[1].text = Math.min(game.songScore,t*1000);
        },Std.int(game.songScore/1000)+1);
        new FlxTimer().start((game.songScore/1000+1)*60/1500+2,()->{
            TW(7);
        });
    }
    if (a == 7){
        new FlxTimer().start(0.5,()->{
            var RT = genText("FC "+(Std.int(game.ratingPercent*1000)/10)+" - ","center",500,450);
            Rating = getTVRating(game.ratingPercent*100);
            COOLText = new FlxText(670, 435, 0, Rating[0], 90, true);
            COOLText.font = Paths.getPath("fronts/fnt_main.ttf");
            COOLText.cameras = [camEnd];
            COOLText.camera= camEnd;
            COOLText.antialiasing = false;
            COOLText.alignment = a;
            customSubstate.add(COOLText);                   
            new FlxTimer().start(15,()->{TW(8);});
        });

    }
    if (a == 8){
        game.camOther.bgColor=0xFF000000;
        //FlxTimer.loop(60/1000,(v)->{camEnd.alpha=v/(2*60*1000);},60*1000*2);
        //FlxTween.num(1,0,2,);
        new FlxTimer().start(0.1,()->{MusicBeatState.resetState();});
    }


    //if (T!=null)T.cancel();
    //T = new FlxTimer().start(10.0,()->{
	//	//MusicBeatState.resetState();
    //});
}
