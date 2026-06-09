import flixel.addons.display.FlxBackdrop;
import flixel.text.FlxTextBorderStyle;
import flixel.group.FlxTypedGroup;
import backend.Controls;
import backend.MusicBeatState;

var Control = Controls.instance;
var camEnd:FlxCamera = new FlxCamera(0, 0, 1280, 720, 1);
var backed;

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

function onCustomSubstateUpdate(n, e) {
	if (!isThis)
		return;
    if (Control.CHAR_SELECT )
		MusicBeatState.resetState();
}

function onCustomSubstateDestroy(n) {
	if (!isThis)
		return;
}

function genText_(str,a,?x=0,?y=0) {
    var text = new FlxText(0, 0, 0, str, 60, true);
	text.font = Paths.getPath("fronts/fnt_main.ttf");
	text.cameras = [camEnd];
	text.camera= camEnd;
    text.antialiasing = false;
    text.alignment = a;
    text.x = x;
    text.y = y;
    //text = text.setBorderStyle(FlxTextBorderStyle.SHADOW_XY(1  , 1));
    customSubstate.add(text);
    return text;
}

function genText(str,a,?x=0,?y=0) {
    var text = [];

    text.push(genText_(str,a,x+3,y+3));
    text[0].color = 0x000000;
    text.push(genText_(str,a,x+0,y+0));
    //text[1].color = color;
    //trace("a");
    return text;
}
 var T;
function TW(a) {
	if (a == 0) {
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
        var RT = genText("MISSED NOTES","left",340,150);
        RT[1].color = 0xFF0000;
        RT = genText(game.songMisses,"right",920,150);
        RT[1].color = 0xFF0000;
        TW(2);
        });
    }
    if (a == 2){
        new FlxTimer().start(0.5,()->{
        var RT = genText("NORMAL NOTES","left",340,200);
        var r = game.ratingsData;
        RT = genText(r[1].hits+r[2].hits+r[3].hits,"right",920,200);
        TW(3);
        });
    }
    if (a == 3){
        new FlxTimer().start(0.5,()->{
        var RT = genText("GOLD NOTES","left",340,250);
        RT[1].color = 0xF6FF00;
        var r = game.ratingsData;
        RT = genText(r[0].hits,"right",920,250);
        RT[1].color = 0xF6FF00;
        TW(4);
        });
    }
    if (a == 4){
        new FlxTimer().start(0.5,()->{
        var RT = genText("LONGEST COMBO","left",340,300);
        RT = genText(game.maxCombo,"right",920,300);
        TW(5);
        });
    }
    if (a == 5){
        new FlxTimer().start(0.5,()->{
        var RT = genText("TOTAL SCORE","left",340,350);
        new FlxTimer().start(0.5,()->{TW(6);});
        });
    }
    if (a == 6){
        var RT = genText(0,"right",920,350);
        FlxTimer.loop(60/1500,(t)->{
            RT[0].text = Math.min(game.songScore,t*1000);
            RT[1].text = Math.min(game.songScore,t*1000);
        },Std.int(game.songScore/1000)+1);
        new FlxTimer().start((game.songScore/1000+1)*60/10000+2,()->{
            game.camOther.bgColor=0xFF000000;
            //FlxTimer.loop(60/1000,(v)->{camEnd.alpha=v/(2*60*1000);},60*1000*2);
            //FlxTween.num(1,0,2,);
             new FlxTimer().start(0.1,()->{MusicBeatState.resetState();});
        });
    }


    //if (T!=null)T.cancel();
    //T = new FlxTimer().start(10.0,()->{
	//	//MusicBeatState.resetState();
    //});
}
