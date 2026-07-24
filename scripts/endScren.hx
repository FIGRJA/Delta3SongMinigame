if (PlayState.SONG.stage!="D3Main") return;
import flixel.addons.display.FlxBackdrop;
import flixel.text.FlxTextBorderStyle;
import flixel.group.FlxTypedGroup;
import backend.Controls;
import backend.MusicBeatState;
//import flash.media.SoundTransform; // not unvalible
import Reflect;


function setVF(Var,Fun) {
	if (getVar(Var).exists(Fun))
		this.set(Fun,getVar(Var).get(Fun));
	
}

var Control = Controls.instance;
var camEnd:FlxCamera = new FlxCamera(0, 0, 1280, 720, 1);
var backed;
var isShader = false;
var song = PlayState.SONG.song.split("\n").join().split("\r").join();
var isThis = false;
var songs = {
    "bump":                 [0.5,Paths.sound("snd_bump")],
    "closet_impact":        [0.3,Paths.sound("snd_closet_impact")],
    "coin":                 [0.3,Paths.sound("snd_coin")],
    "crowd_cheer_single":   [1  ,Paths.sound("snd_crowd_cheer_single")],
    "drumroll":             [0.3,Paths.sound("snd_drumroll")],
    "punchmed":             [0.3,Paths.sound("snd_punchmed")],
    "splat":                [0.3,Paths.sound("snd_splat")],
};  
function getS() {
    var T = songs.bump[1].play();
    var R = T.soundTransform.clone();
    T.stop();
    return R;
}
var soundV = getS();
soundV.pan = -1;
function playSnd(Strs) {
    var snd = Reflect.field(songs,Strs);
    //var snd = songs.get(Strs);
    //trace(snd.length);
    //snd.stop();
    if (!isThis){
        soundV.volume = snd[0];
    }else{
        soundV.volume = 1;
    }
    soundV.volume *= FlxG.sound.volume;
    snd[1].play(0,0,soundV);
}
setVar("endScreen",this);
var sideTerminalB2;
function onCreate() {
   // trace(songs);
	FlxG.cameras.add(camEnd, false);
	game.luaDebugGroup.cameras.push(camEnd);
	// game.transitioning = true;
	// game.endCallback = function() {
	//	CustomSubstate.openCustomSubstate('END', true);
	// }
	// D3Main 820;

}
function onCreatePost() {
    setVF("D3Main","getShader");
    sideTerminalB2 = getShader("Dglsl/shd_crt3");
	//sideTerminalB2.setFloat("aberation_amount"	,0.8);
	sideTerminalB2.setFloat("noise_amount"	,0.007);
    sideTerminalB2.setFloatArray("resolution",[1280/2,720/3.75]);
    
}


function onCustomSubstateCreate(name) {
	isThis = name == "END";
	if (!isThis)
		return;
	camEnd.y = -720;
    camEnd.bgColor = 0xFF000000;
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
    if (!(FlxG.random.bool(game.endingSong?10:88)&&ClientPrefs.data.shaders)){
        var lastY = -720;
        var vec = 1;
        FlxTween.tween(camEnd, {y: 0}, 1.8 ,{
            ease: FlxEase.bounceOut,
            onComplete: (_) -> {
                playSnd("bump");
                TW(0);
            } ,
            onUpdate: ()->{
                if (vec>0&&camEnd.y-lastY<0)
                    playSnd("bump");
                vec = camEnd.y-lastY;
                lastY = camEnd.y;
            }      
        });
    }else {
        isShader = true;
        camEnd.y = 0;
        camEnd.filters = [ new ShaderFilter(sideTerminalB2)];
        backed.visible = false;
        new FlxTimer().start(3,()->{
            backed.visible = true;
            FlxTween.num(9, 0.88, 3,  null,num -> sideTerminalB2.data.aberation_amount.value = [num] );
            //FlxTween.num(0.3, 0.07, 2,  null,num -> sideTerminalB2.data.noise_amount.value = [num] );
            sideTerminalB2.setFloat("noise_amount"	,0.07);
        });
        new FlxTimer().start(5,()->{
            TW(0);
        });
    }
}
var COOLText = null;
var Rating ;
var a = 0;
var TimeUp = 0;
var isEnd = false;
function onCustomSubstateUpdate(n, e) {
	if (!isThis)
		return;

    getVar("D3Main").call("onUpdate",[e]);
    if (Control.CHAR_SELECT ){
		playSnd("splat");
		MusicBeatState.resetState();}

	TimeUp +=e;
	if (isShader)
	    sideTerminalB2.setFloat("time",TimeUp);

    if (Control.ACCEPT &&isEnd)
        TW(8);
		//MusicBeatState.resetState();
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
    var text = new FlxText(0, 0, 0, str, 15*4, true);
	text.font = Paths.getPath("fronts/fnt_main.ttf");
	text.cameras = [camEnd];
	text.camera= camEnd;
    text.antialiasing = false;
    text.alignment = a;
    text.x = x*4;
    text.y = y*4;
    //text.size = size;
    //text = text.setBorderStyle(FlxTextBorderStyle.SHADOW_XY(1  , 1));
    customSubstate.add(text);
    return text;
}

var textAr = [];
function genText(str,a,?x=0,?y=0) {
    var text = [];

    text.push(genText_(str,a,x+1,y+1));
    text[0].color = 0x00102D;
    text.push(genText_(str,a,x+0,y+0));
    //text[1].color = color;
    //trace("a");
    textAr.push(text);
    return text;
}
var lSnd = ["splat","splat","coin","coin","crowd_cheer_single","crowd_cheer_single"];
function getTVRating(p) {
    var c = 0;
    var targ = [[50,"Z"],[65,"C"],[80,"B"],[90,"A"],[98,"S"],[101,"T"]];
    for (i in targ){
        c+=i[0]>90?1:0;
        if (i[0]>p){
            playSnd(lSnd[targ.indexOf(i)]);
            return [i[1],c];}
    }
}
 var T;
function TW(a) {
	if (a == 0) {
        var spD = PlayState.SONG.format.split("^");
        var RB = genText(song+" : "+spD[1]+" \n("+spD[0]+")","left",170,0);
        RB[0].alpha = 0;
        RB[1].alpha = 0;
        FlxTween.tween(RB[0], {alpha: 0.8}, 10 ,{
            startDelay: 0.5,
            onUpdate:()->{RB[1].alpha=RB[0].alpha;},   
        });
        var RT = genText("~~~~~~ CONCERT RESULTS ~~~~~~","center",55,25);
        Test = RT;
        RT[0].visible=false;
        RT[1].visible=false;
        FlxTween.tween(RT[0], {x: 260}, 0.5 ,{
            startDelay: 1,
            onUpdate:()->{
                RT[1].x=RT[0].x-3;
            },
            onStart:()->{
                RT[0].visible=true;
                RT[1].visible=true;
                playSnd("closet_impact");
                if (isShader) {
                    FlxTween.num(3, 0.22, 2,  null,num -> sideTerminalB2.data.aberation_amount.value = [num] );
                }
            },
            ease: FlxEase.elasticOut,
            onComplete: (_) -> {
                TW(1);
            }       
        });
        
        //MusicBeatState.startTransition();
    }
    if (a == 1){
        new FlxTimer().start(0.4,()->{
        var RT = genText("MISSED NOTES","left",80,40);
        RT[1].color = 0xFF0000;
        RT = genText(game.songMisses,"right",230,40);
        RT[1].color = 0xFF0000;
        playSnd("punchmed");
        TW(2);
        });
    }
    if (a == 2){
        new FlxTimer().start(0.45,()->{
        var RT = genText("NORMAL NOTES","left",80,55);
        var r = game.ratingsData;
        RT = genText(r[1].hits+"+"+(r[2].hits+r[3].hits),"right",230,55);
        playSnd("punchmed");
        TW(3);
        });
    }
    if (a == 3){
        new FlxTimer().start(0.45,()->{
        var RT = genText("GOLD NOTES","left",80,70);
        RT[1].color = 0xF6FF00;
        var r = game.ratingsData;
        RT = genText(r[0].hits,"right",230,70);
        RT[1].color = 0xF6FF00;
        playSnd("punchmed");
        TW(4);
        });
    }
    if (a == 4){
        new FlxTimer().start(0.45,()->{
        var RT = genText("LONGEST COMBO","left",80,85);
        RT = genText(game.maxCombo,"right",230,85);
        playSnd("punchmed");
        TW(5);
        });
    }
    if (a == 5){
        new FlxTimer().start(0.45,()->{
        var RT = genText("TOTAL SCORE","left",80,100);
        new FlxTimer().start(0.5,()->{TW(6);});
        playSnd("punchmed");
        });
    }
    if (a == 6){
        var RT = genText(0,"right",230,100);
        FlxTimer.loop(60/1500,(t)->{
            RT[0].text = Math.min(game.songScore,t*1000);
            RT[1].text = Math.min(game.songScore,t*1000);
            playSnd("bump");
        },Std.int(game.songScore/1000)+1);
        new FlxTimer().start((game.songScore/1000+1)*60/1500+0.2,()->{
            TW(7);
        });
    }
    if (a == 7){  
            playSnd("drumroll"); 
        new FlxTimer().start(1.2,()->{
            var RT = genText("FC "+(Std.int(game.ratingPercent*1000)/10)+" - ","center",125,120);
            Rating = getTVRating(game.ratingPercent*100);
            COOLText = new FlxText(670, 467, 0, Rating[0], 90, true);
            COOLText.font = Paths.getPath("fronts/fnt_main.ttf");
            COOLText.cameras = [camEnd];
            COOLText.camera= camEnd;
            COOLText.antialiasing = false;
            COOLText.alignment = a;
            customSubstate.add(COOLText);  
            isEnd = true;                 
            //new FlxTimer().start(15,()->{TW(8);});
        });

    }
    if (a == 8){
        game.camOther.bgColor=0xFF000000;
        var l = isShader? 5:1;
        FlxTween.num(1, 0, 0.65*l,  null,num -> backed.alpha = num );
        FlxTween.num(-100, -200*l, 0.5*l,  null,num -> backed.velocity.x = num );
        FlxTween.num(100, 200*l, 0.5*l,  null,num -> backed.velocity.y = num );
        if (isShader) 
            FlxTween.num(0.07, 0.8, 0.5*l,  null,num -> sideTerminalB2.data.noise_amount.value = [num] );
        for (t in textAr)
            FlxTween.num(1, 0, 0.65*l,  null,num -> t[0].alpha = num );
        //backed.visible = false;
        //FlxTimer.loop(60/1000,(v)->{camEnd.alpha=v/(2*60*1000);},60*1000*2);
        //FlxTween.num(1,0,2,);
        if (isShader) 
            new FlxTimer().start(0.60*l,()->{
                game.camOther.scroll.x = 10000;
                FlxTween.num(0.8, 0.1, 0.2*l,  null,num -> sideTerminalB2.data.noise_amount.value = [num] );
                FlxTween.num(1, 0, 0.2*l,  null,num -> camEnd.alpha = num );
            });
        new FlxTimer().start(0.80*l,()->{camEnd.filters = [];MusicBeatState.resetState();});
    }


    //if (T!=null)T.cancel();
    //T = new FlxTimer().start(10.0,()->{
	//	//MusicBeatState.resetState();
    //});
}
function onDestroy() {}