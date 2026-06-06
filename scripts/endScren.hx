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
    text.antialiasing = false;
    text.alignment = a;
    text = text.setBorderStyle(FlxTextBorderStyle.SHADOW_XY(1  , 1));
    customSubstate.add(text);
    return text;
}

function genText(str,a) {
    var text = new FlxTypedGroup();

    text.add(genText_(str,a,5,5));
    text.members[0].color = 0x000000;
    text.add(genText_(str,a,0,0));
    //trace("a");
    return text;
}
 var T;
function TW(a) {
	if (a == 0) {
        var RT = genText_("~~~~~~ concert results ~~~~~~","center");
        RT.x = 220;
        RT.y = 100;
        RT.visible=false;
        FlxTween.tween(RT, {x: 260}, 0.5 ,{
            startDelay: 1,
            onStart:()->{RT.visible=true;},
            ease: FlxEase.elasticOut,
            onComplete: (_) -> {
                TW(1);
            }       
        });
        
        //MusicBeatState.startTransition();
    }
    if (T!=null)T.cancel();
    T = new FlxTimer().start(10.0,()->{
		MusicBeatState.resetState();
    });
}
