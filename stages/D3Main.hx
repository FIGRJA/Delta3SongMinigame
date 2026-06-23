import openfl.Lib;
import openfl.display.BitmapData;
import flixel.math.FlxMatrix;
import flixel.util.FlxTimer;
import flixel.addons.display.FlxBackdrop;
import mikolka.stages.cutscenes.dialogueBox.DialogueBoxPsych; // import haxe.Json;
import mikolka.funkin.custom.NativeFileSystem as NativeFileSystem;
import backend.MusicBeatState;
import backend.Mods;
import backend.Highscore;
import backend.ClientPrefs;
import backend.CacheSystem;
import psychlua.ModchartSprite;
import lime.graphics.opengl.GL;
import tjson.TJSON;

function setVF(Var,Fun) {
	if (getVar(Var).exists(Fun))
		this.set(Fun,getVar(Var).get(Fun));
	
}
setVF("songMenu","loadSongsLists");
setVF("load_delta_notes","loadSong");

var isMenuChart:Bool = PlayState.SONG.song == "songChart";
var susiNoteCam:FlxCamera;
var krisNoteCam:FlxCamera;
var ralseiNoteCam:FlxCamera;
var bmpDistant:FlxBackdrop;
var bmpDistant4:FlxBackdrop;
var maskBG:FlxSprite = new ModchartSprite(4,-10);
var plSplashKris:Array = [[new FlxSprite(-37,185),new FlxSprite(-18,315)],[new FlxSprite(80,185),new FlxSprite(99,315)]];
var plSplashSusi:Array = [[new FlxSprite(-37,185),new FlxSprite(-18,315)],[new FlxSprite(80,185),new FlxSprite(99,315)]];
var krisMissBack:FlxSprite = new ModchartSprite(-190, -200);
var susiMissBack:FlxSprite = new ModchartSprite(-190, -200);
var krisMute:FlxSprite = new ModchartSprite(-55, -195);
var susiMute:FlxSprite = new ModchartSprite(-55, -195);
var susiCombo:FlxText = new FlxText(-110, 80, 350, "0", 240, true);
var krisCombo:FlxText = new FlxText(-110, 80, 350, "0", 240, true);
var ralsCombo:FlxText = new FlxText(-110, 80, 350, "0", 240, true);
var wordCombo:FlxText = new FlxText(-115, 265, 350, "COMBO", 90, true);
var maxCombo:FlxText = new FlxText(960, 647, 0, "000000", 60, true);
var maxComboText:FlxText = new FlxText(857, 675, 0, "MAX COMBO", 25, true);
var SCORE:FlxText = new FlxText(180, 647, 0, "000000", 60, true);
var SCOREText:FlxText = new FlxText(345, 675, 0, "SCORE", 25, true);
var L1 = MusicBeatState.getVariables().get("L1");
var L2 = MusicBeatState.getVariables().get("L2");
var L3 = MusicBeatState.getVariables().get("L3");
var susiRofls:Bool = false;
var songScore = 0;
var SPcameras = [];

/*
	0- ch3_karaoke
	1- ch3-practice_song
	2- tenna_battle
	3- ch3_tvtime
	4- board4_rhythm
	5- rudebuster_boss
	6- battle_vapor
	7- tenna_battle_old

 */
// var castomTRY:String = "tenna";
// var songsList:Array<Dynamic> = [
//    [0,"karaoke",230,3],
//    [1,"practice",75,4],
//    [2,"tenna",148,4],
//    [3,"tvtime",190,4],
//    [4,"4board",60,4],
//    [5,"rudebuster",140,4],
//    [6,"vapor",200,4],
//    [7,"tenna_old",148,4],
//    [9,"feld",148,4],
//    [10,"knockdown",200,4]
//
// ];

function getShader(shaderName){
	var vert = testShader(shaderName+".vert");
	var frag = testShader(shaderName+".frag");
    trace(shaderName);
	trace(vert!=null);
	trace(frag!=null);
	if (!game.runtimeShaders.exists(shaderName))
		game.runtimeShaders.set(shaderName,[frag,vert]);
	return new FlxRuntimeShader(frag,vert);
}
function testShader(shaderName){
	var shader = Paths.getPath("shaders/"+shaderName);
	if (NativeFileSystem.exists(shader))
		    return NativeFileSystem.getContent(shader);
	return null;
}



var SONG:Dynamic;
var acurateDrums = 1;
var moddir = "";
var shader_;
var statusLoad;
setVar("D3Main",this);
function onCreate() // PlayState.SONG.bpm = 0.1;
{
	//
	if (isMenuChart)
		return;

for (mod in loadSongsLists()) for (song in mod[1].songs) {
	if (PlayState.SONG.song == song.name) {
		// Conductor.safeZoneOffset = game.ratingsData[0].hitWindow+game.ratingsData[1].hitWindow;
		var path:String = "";
		var index:Dynamic= song.index;
		if (song.hxModule != null) {
			path = song.hxModule;
		} else{
	//debugPrint(mod);
			for (diff in mod[1].dificulties){
				if (mod[0].name +"^"+ diff.name == PlayState.SONG.format) {
					path = "mods/"+mod[2]+"/"+diff.dir + diff.prefix + song.nameFile + diff.postfix;
				}
			}
		}
		// PlayState.SONG.format = "DELTA-ponos";
		if (index == null)
			continue;
		PlayState.SONG.bpm = song.bpm;
		Conductor.bpm = song.bpm;
		PlayState.SONG.speed = song.speed!=null?song.speed/150:1.1;
		//debugPrint(song.speed);*
		//PlayState.SONG.speed = 1;
		//game.songSpeed = 1.1;
		moddir = mod[2];
		//statusLoad = getVar("load_delta_notes").call("loadSong", [path, index, song.isFull]).returnValue;
		statusLoad = loadSong(path, index, song.isFull);
		//debugPrint(statusLoad);
		SONG = song;
		setVar("SONG",SONG);
	}
	// for (sos in songsList){
	//    if (game.songName == sos[1]){
	//        PlayState.SONG.bpm = sos[2];
	//        //Conductor.bpm = sos[2];
	//        PlayState.SONG.speed = 1.1;
	//        game.songSpeed = 1.1;//sos[3]/sos[2]
	//        Conductor.safeZoneOffset = game.ratingsData[0].hitWindow+game.ratingsData[1].hitWindow;
	//        //setVar("load_delta_notes","scripts/deltaCode/gml_ch"+sMusicBeatStateos[3]+"_scr_rhythmgame_notechart.hx");
	//        getVar("load_delta_notes").call("loadSong",["scripts/deltaCode/gml_ch4_scr_rhythmgame_notechart.hx",sos[0]]);
	//        //setVar("load_delta_notes","SongCharts/normal/music_timing_"+castomTRY+".txt");
	//        //setVar("load_delta_notes_index",sos[0]);
	//    }
	// }
	game.showRating = false;
	game.showComboNum = false;
}
}
var clear = function() {
	GL.clearColor(0, 0, 0, 0); 
	GL.enable(GL.ALPHA_TEST); 
	//trace("hi");
}

function getSong(mod,song) {
	var name = "mods/"+mod+"/mus/"+song+".ogg";
	if (NativeFileSystem.exists(name))
		return name;
	else
		return Paths.getPath("mus/"+song+".ogg");
	
}

function onCreatePost() {
	if (isMenuChart)
		return;

	//game.moveCamera(false);
	//game.camFollow.y = 0;
	//game.camHUD.scroll.x += 100;
	game.noteKillOffset = 120;
	// getVar("load_delta_notes").call("loadSong",["scripts/deltaCode/gml_ch4_scr_rhythmgame_notechart.hx",2]);
	// PlayState.SONG.bpm = 148;
	// Conductor.bpm = 148;
	// PlayState.SONG.speed = 1.1;
	// game.songSpeed = 1.1;//sos[3]/sos[2]
	try {
		//debugPrint("mods/"+moddir+"/mus/"+SONG.songMain+".ogg");
		game.inst.loadEmbedded(CacheSystem.loadSound(getSong(moddir,SONG.songMain),true,Paths.formatToSongPath(SONG.songMain)+'/Inst, PATH: songs'));
		game.vocals.loadEmbedded(CacheSystem.loadSound(getSong(moddir,SONG.songPlay),true,Paths.formatToSongPath(SONG.songPlay)+'/Vocals, PATH: songs'));
	} catch (e:Dynamic) {}

	susiNoteCam = new FlxCamera(361, 55, 120, 390, 1);
	krisNoteCam = new FlxCamera(578, 55, 120, 390, 1);
	ralseiNoteCam = new FlxCamera(796, 55, 120, 390, 1);

	FlxG.cameras.insert(susiNoteCam, 1, false);
	FlxG.cameras.insert(krisNoteCam, 2, false);
	FlxG.cameras.insert(ralseiNoteCam, 3, false);
	
	var createCamSP = (camera:FlxCamera)->{
		var bitmapData:BitmapData = new BitmapData(camera.width*2, camera.height*2, true, 0x00FFFFFF);
		//bitmapData.draw(camera.canvas);
		bitmapData.scroll(-camera.width,-camera.height);
		var SPCam = new FlxSprite(0,-87,bitmapData);
		SPCam.scale.set(0.35,0.35);
		SPCam.updateHitbox();
		SPCam.camera = game.camGame;
		var matrix = new FlxMatrix();
		matrix.translate(camera.width/2, camera.height/2);
		///camera.visible = false;
		camera.y = 1000;
		add(SPCam);
		//debugPrint(SPCam);
		return [bitmapData,SPCam,camera,matrix];
	}

	susiNoteCam.zoom = 0.5;
	susiNoteCam.bgColor = 0x00;
	//susiNoteCam.visible = false;
	//var sp1 = susiNoteCam.canvas;
	//sp1.camera = game.camGame;
	//add(sp1);
	//susiNoteCam.scroll.y = 10000;
	var cams = createCamSP(susiNoteCam);
	cams[1].x =145;
	SPcameras.push(cams);
	
	krisNoteCam.zoom = 0.5;
	krisNoteCam.bgColor = 0x00;
	//krisNoteCam.visible = false;
	//var sp2 = krisNoteCam.canvas;
	//sp2.camera = game.camGame;
	//add(sp2);
	//krisNoteCam.scroll.y = 10000;
	var cams = createCamSP(krisNoteCam);
	cams[1].x =295;
	SPcameras.push(cams);
	
	ralseiNoteCam.zoom = 0.5;
	ralseiNoteCam.bgColor = 0x00;
	//ralseiNoteCam.visible = false;
	//var sp3 = ralseiNoteCam.canvas;
	//sp3.camera = game.camGame;
	//add(sp3);
	//ralseiNoteCam.scroll.y = 10000;
	var cams = createCamSP(ralseiNoteCam);
	cams[1].x =445;
	SPcameras.push(cams);

	//FlxG.stage.alpha = 1;
	FlxG.stage.color = 0x00000000;
	//FlxG.stage.background = 0x00000000;
	//debugPrint(FlxG.stage.application.window.__attributes);
	//FlxG.stage.application.window.__backend.flags |= cast WindowFlags.WINDOW_FLAG_STENCIL_BUFFER;
	FlxG.camera.bgColor = 0x8EEE0000;
	shader_ = getShader("grayT");
	//shader_ = game.createRuntimeShader("wiggle");
	//trace(shader_);
	game.camGame.bgColor = 0x00;
	game.camGame.filtersEnabled = true;
	//game.camGame.filters = [ new ShaderFilter(shader_)];
	for (cam in FlxG.cameras.list) {
		cam.bgColor = 0x00000000;
		//cam.visible =false;
	}
	//FlxG.game.setFilters(null);
	//FlxG.game.setFilters([ new ShaderFilter(shader_)]);
	//Lib.current.alpha = 1;
	//Lib.current.shader = [shader_];
	
	//var gameSprite = cast FlxG.game;
	//gameSprite.sahder = [shader_];
	//FlxG.game.alpha = 0.5;
	//Lib.application.window.opacity = 0.5;
	//FlxG.signals.postDraw.add(clear);
	//debugPrint(Lib.application.window.display.supportedModes );
	//var a = Lib.application.window.displayMode;
	//a.pixelFormat = 1; 
	//Lib.application.window.display.supportedModes = [a];
	//Lib.application.window.background =  0x00FF0000;
	Lib.application.window.context.attributes.background = null;// = 0x00FF0000;
	//Lib.application.window.context.attributes.alpha = true;// = 0x00FF0000;
	Lib.application.window.context.attributes.depth = false;// = 0x00FF0000;
	Lib.application.window.context.attributes.stencil = false;// = 0x00FF0000;
	////Lib.application.window.context.gles2.SRC_ALPHA = 1;
	//GL.enable(GL.BLEND);
	//GL.enable(GL.ALPHA_TEST);        
    //GL.enable(GL.DEPTH_TEST);        
    //GL.enable(GL.COLOR_MATERIAL);

    //GL.enable(GL.LIGHTING);          
    //GL.enable(GL.LIGHT0);  
	// 
	////GL.blendFunc(0x0302, 0x0303);
    //GL.clearColor(0, 0, 0, 0);  
	// dad.flipX = false;
	// gf.flipX = false;
	// susiNoteCam.follow(gf);
	// krisNoteCam.follow(boyfriend);
	// ralseiNoteCam.follow(dad);

	game.healthBar.visible = false;
	game.iconP1.visible = false;
	game.iconP2.visible = false;
	game.scoreTxt.visible = false;
	game.endCallback = onEndSong;

	var gog:Int = 0;
	for (i in playerStrums) {
		
		//i.copyScale = false;
		if (gog<2)
			i.x = -57;
		else
			i.x = 60;

		if (gog == 0 || gog == 3) {
			i.camera = krisNoteCam;
			//i.cameras = [krisNoteCam,game.camHUD];
			//i.x = -48 + gog * 45;
			if (gog == 0)
				i.color = 0x4CFF9D;
			if (gog == 3)
				i.color = 0x07E2FF;
		} else if (gog == 1 || gog == 2) {
			i.camera = susiNoteCam;
			if (gog == 1)
				i.color = 0xFF073D;
			if (gog == 2)
				i.color = 0xFF07A0;
		}
		i.y = 428
		;
		i.visible = false;
		gog += 1;
		var fakeNS = new FlxSprite(i.x+40,i.y);
		//fakeNS.x = 0;
		//fakeNS.y = 440;
		fakeNS.loadGraphic(Paths.image("sp/spr_rhythmgame_button_4"));
		fakeNS.scale.set(2.9,3);
		//fakeNS.updateHitbox();
		fakeNS.camera = i.camera;
		//fakeNS.cameras = i.cameras;
		//fakeNS.cameras = [krisNoteCam,game.camHUD];
		fakeNS.color = i.color;
		//i.add(fakeNS);
		insert(1,fakeNS);
	}
	var gog:Int = 0;
	for (i in opponentStrums) {
		i.camera = ralseiNoteCam;
		i.y = 390;
		//i.alpha = 0.1;
		if (gog == 0)
			i.x = -90 + 90 * 0;
		if (gog == 2)
			i.x = -90 + 90 * 1;
		if (gog == 3)
			i.x = -90 + 90 * 2;
		if (gog == 1)
			i.visible = false;
			//i.x = -400;
		gog += 1;
	}

	plSplashKris[0][0].loadGraphic(Paths.image("sp/spr_rhythmgame_chart_mask_0"));
	plSplashKris[0][1].loadGraphic(Paths.image("sp/spr_whitegradientdown_rhythm_0"));
	plSplashKris[1][0].loadGraphic(Paths.image("sp/spr_rhythmgame_chart_mask_0"));
	plSplashKris[1][1].loadGraphic(Paths.image("sp/spr_whitegradientdown_rhythm_0"));
	plSplashKris[0][0].camera = krisNoteCam;
	plSplashKris[0][1].camera = krisNoteCam;
	plSplashKris[1][0].camera = krisNoteCam;
	plSplashKris[1][1].camera = krisNoteCam;
	insert(members.indexOf(game.noteGroup),plSplashKris[0][0]);
	insert(members.indexOf(game.noteGroup),plSplashKris[0][1]);
	insert(members.indexOf(game.noteGroup),plSplashKris[1][0]);
	insert(members.indexOf(game.noteGroup),plSplashKris[1][1]);
	noteSplash(0);
	noteSplash(1);
	plSplashSusi[0][0].loadGraphic(Paths.image("sp/spr_rhythmgame_chart_mask_0"));
	plSplashSusi[0][1].loadGraphic(Paths.image("sp/spr_whitegradientdown_rhythm_0"));
	plSplashSusi[1][0].loadGraphic(Paths.image("sp/spr_rhythmgame_chart_mask_0"));
	plSplashSusi[1][1].loadGraphic(Paths.image("sp/spr_whitegradientdown_rhythm_0"));
	plSplashSusi[0][0].camera = susiNoteCam;
	plSplashSusi[0][1].camera = susiNoteCam;
	plSplashSusi[1][0].camera = susiNoteCam;
	plSplashSusi[1][1].camera = susiNoteCam;
	insert(members.indexOf(game.noteGroup),plSplashSusi[0][0]);
	insert(members.indexOf(game.noteGroup),plSplashSusi[0][1]);
	insert(members.indexOf(game.noteGroup),plSplashSusi[1][0]);
	insert(members.indexOf(game.noteGroup),plSplashSusi[1][1]);
	susiPressed(0,0x000000);
	susiPressed(1,0x000000);
	
	krisMissBack.loadGraphic(Paths.image("sp/spr_whitegradientdown_rhythm_0"));
	krisMissBack.color = 0xFF0000;
	krisMissBack.scale.x = 10.5;
	krisMissBack.scale.y = 7;
	krisMissBack.alpha = 0;
	krisMissBack.cameras = [krisNoteCam];
	krisMissBack.updateHitbox();
	add(krisMissBack);
	susiMissBack.loadGraphic(Paths.image("sp/spr_whitegradientdown_rhythm_0"));
	susiMissBack.color = 0xFF0000;
	susiMissBack.scale.x = 10.5;
	susiMissBack.scale.y = 7;
	susiMissBack.alpha = 0;
	susiMissBack.cameras = [susiNoteCam];
	susiMissBack.updateHitbox();
	add(susiMissBack);

	// debugPrint(Paths.getPath("fronts/fnt_main.ttf"));
	susiCombo.font = Paths.getPath("fronts/fnt_main.ttf");
	susiCombo.cameras = [susiNoteCam];
	// susiCombo.scale.y = 4;
	susiCombo.antialiasing = false;
	susiCombo.alignment = "center";
	insert(0, susiCombo);
	susiCombo.visible = statusLoad[1];
	
	krisCombo.font = Paths.getPath("fronts/fnt_main.ttf");
	krisCombo.cameras = [krisNoteCam];
	// krisCombo.scale.y = 4;
	krisCombo.antialiasing = false;
	krisCombo.alignment = "center";
	insert(0, krisCombo);
	krisCombo.visible = statusLoad[0];

	ralsCombo.font = Paths.getPath("fronts/fnt_main.ttf");
	ralsCombo.cameras = [ralseiNoteCam];
	// ralsCombo.scale.y = 4;
	ralsCombo.antialiasing = false;
	ralsCombo.alignment = "center";
	insert(0, ralsCombo);
	ralsCombo.visible = statusLoad[2];

	wordCombo.font = Paths.getPath("fronts/fnt_main.ttf");
	wordCombo.cameras = [];
	if (statusLoad[0]) wordCombo.cameras.push(krisNoteCam);
	if (statusLoad[1]) wordCombo.cameras.push(susiNoteCam);
	if (statusLoad[2]) wordCombo.cameras.push(ralseiNoteCam);
	// ralsCombo.scale.y = 4;
	wordCombo.antialiasing = false;
	wordCombo.alignment = "center";
	insert(0, wordCombo);

	var blackbacknotes = new ModchartSprite(-85, -220);
	blackbacknotes.makeGraphic(350, 1000, FlxColor.BLACK);
	blackbacknotes.alpha = 0.6;
	blackbacknotes.cameras = [ralseiNoteCam, susiNoteCam, krisNoteCam];
	insert(4, blackbacknotes);

	//var distant = 60 / Conductor.bpm * 450;
	var distant = 0.45 * (60 / Conductor.bpm* 1000) * (game.songSpeed/game.playbackRate)*1;
	bmpDistant = new FlxBackdrop(null, 0x10, 0, (distant*4)-10); // 0x10 = Y
	// bmpDistant.y = 0;
	bmpDistant.x = -200;
	// bmpDistant.scale.y = 1;
	bmpDistant.scale.x = 50;
	bmpDistant.loadGraphic(Paths.image("sp/spr_rhythmgame_note_0"));
	bmpDistant.cameras = [krisNoteCam, susiNoteCam, ralseiNoteCam];
	// bmpDistant.velocity.y = (0.45 * (1000) * game.songSpeed * 1);
	// bmpDistant.velocity.y = distant/(60 / Conductor.bpm)*game.songSpeed ;
	// 60/Conductor.bpm *game.songSpeed*1000;
	insert(6, bmpDistant);

	bmpDistant4 = new FlxBackdrop(null, 0x10, 0, distant-10); // 0x10 = Y
	bmpDistant4.x = -200;
	bmpDistant4.scale.x = 50;
	bmpDistant4.loadGraphic(Paths.image("sp/spr_rhythmgame_note_2"));
	bmpDistant4.cameras = [krisNoteCam, susiNoteCam, ralseiNoteCam];
	bmpDistant4.alpha = 0.6;
	insert(6, bmpDistant4);

	krisMute.loadGraphic(Paths.image("sp/spr_rhythmgame_mute_0"));
	// krisMute.color = 0xFF0000;
	krisMute.scale.x = 3.15;
	krisMute.scale.y = 3.2;
	krisMute.antialiasing = false;
	krisMute.alpha = 0;
	krisMute.cameras = [krisNoteCam];
	krisMute.updateHitbox();
	add(krisMute);
	susiMute.loadGraphic(Paths.image("sp/spr_rhythmgame_mute_0"));
	// susiMute.color = 0xFF0000;
	susiMute.scale.x = 3.15; // #42
	susiMute.scale.y = 3.2;
	susiMute.antialiasing = false;
	susiMute.alpha = 0;
	susiMute.cameras = [susiNoteCam];
	susiMute.updateHitbox();
	add(susiMute);

	maxCombo.font = Paths.getPath("fronts/fnt_main.ttf");
	maxCombo.cameras = [game.camOther];
	maxCombo.antialiasing = true;
	maxCombo.alignment = "center";
	maxCombo.color = 0x07E2FF;
	add(maxCombo);
	maxComboText.font = Paths.getPath("fronts/fnt_main.ttf");
	maxComboText.cameras = [game.camOther];
	maxComboText.antialiasing = true;
	maxComboText.alignment = "center";
	maxComboText.color = 0x07E2FF;
	add(maxComboText);

	SCORE.font = Paths.getPath("fronts/fnt_main.ttf");
	SCORE.cameras = [game.camOther];
	SCORE.antialiasing = true;
	SCORE.alignment = "center";
	SCORE.color = 0x4CFF9D;
	add(SCORE);
	SCOREText.font = Paths.getPath("fronts/fnt_main.ttf");
	SCOREText.cameras = [game.camOther];
	SCOREText.antialiasing = true;
	SCOREText.alignment = "center";
	SCOREText.color = 0x4CFF9D;
	add(SCOREText);
	// for (no in game.unspawnNotes){
	//    PreSpawnNote(no);
	// }
	susiRofls = FlxG.random.bool(10);
	debugPrint(game.songName);
	if (game.songName == "practice"){
		susiRofls = false;
	}
	game.boyfriend.idleSuffix = "-alt";
	game.boyfriend.recalculateDanceIdle();

	if (!statusLoad[0]&&FlxG.random.bool(42)){
		game.boyfriend.visible = false;
		krisNoteCam.visible = false;
		L1.visible = false;
	}
	if (!statusLoad[1]&&!FlxG.random.bool(42)){
		game.gf.visible = false;
		susiNoteCam.visible = false;
		L3.visible = false;
	}
	if (!statusLoad[2]&&FlxG.random.bool(42)){
		game.dad.visible = false;
		ralseiNoteCam.visible = false;
		L2.visible = false;
	}

	Conductor.songPosition = -3000;
	//game.grpHoldSplashes.visible =false;
}


function onDestroy() {
	FlxG.signals.preDraw.remove(clear);
}

function findChildAtClass(bob:Sprite, classs:String) {
	var len = bob.numChildren;
	for (i in 0...len) {
		var obj = bob.getChildAt(i);
		var cll = Type.getClassName(Type.getClass(obj));
		trace(cll);
		if (cll == classs) {
			trace("     true");
			return obj;
		}
	}
}

//var main:Sprite = findChildAtClass(Lib.current, "Main");
//var border:GameBorder = findChildAtClass(main, "mikolka.GameBorder");

function onSongStart() {
	//main.graphics.clear();
	//border.graphics.clear();
	game.inst.volume = 1;
	// game.vocals.volume = 0;
}

var tmpTweenkris:FlxTween;
var tmpTweensusi:FlxTween;
var tmpMissKris:Int = 0;
var tmpMissSusi:Int = 0;

function noteMiss(daNote) {
	if (daNote.isSustainNote) {
		for (no in daNote.parent.tail) {
			no.blockHit = true;
			no.alpha = 0.6;
		}
		game.vocals.volume = 1;
		return;
	}
	// debugPrint("danote");
	if (daNote.gfNote) {
		game.totalPlayed--;
		game.songMisses--;
		game.songScore += 10;
		game.vocals.volume = 1;
		susiMissBack.alpha = 1;
		tmpMissSusi += 1;
		if (tmpTweensusi != null)
			tmpTweensusi.cancel();
		tmpTweensusi = FlxTween.tween(susiMissBack, {alpha: 0}, 0.5);
		susiCombo.text = "0";
	} else {
		tmpMissKris += 1;
		shareSprite(game.boyfriend,10);
		krisMissBack.alpha = 1;
		if (tmpTweenkris != null)
			tmpTweenkris.cancel();
		tmpTweenkris = FlxTween.tween(krisMissBack, {alpha: 0}, 0.5);
		krisCombo.text = "0";
	}
	for (mo in [[tmpMissKris, krisMute], [tmpMissSusi, susiMute]]) {
		if (mo[0] == 3) {
			FlxTimer.loop(0.3, (tim) -> {
				mo[1].alpha = (tim + 1) % 2;
			}, 4);
			// runTimer(1,"pog");
			mo[1].alpha = 1;
		}
	}
}

var ralsClap = false;
function onSpawnNote(daNote) {
	daNote.noteSplashData.disabled = true;
	daNote.lateHitMult = 1;
	daNote.rgbShader.enabled = false;
	// daNote.rgbShader.mult = 0.5;
	// daNote.noteHoldSplash.alpha = 0;
	rawType = daNote.noteData;

	daNote.scale.set(2.9,3.5);
	daNote.updateHitbox();
	daNote.copyScale = false;
	daNote.offsetY = -200;
	daNote.offsetX = -105;
	daNote.loadGraphic(Paths.image("sp/spr_rhythmgame_note_0"));
	
	if (daNote.isSustainNote) {
		daNote.scale.set(1.5,2.5);
		daNote.loadGraphic(Paths.image("sp/spr_rhythmgame_note_0"));
		daNote.angle = 90;
		daNote.offsetX = -5;
		daNote.offsetY = -100;
		//daNote.scale.y = 0.5;
	}
	if (daNote.noteType == "lead") {
		daNote.mustPress = true;
		daNote.noteData = rawType * 3;
		daNote.camera = krisNoteCam;
		// daNote.reloadNote();
		// daNote.x = 0;
		if (rawType == 0) {
			//daNote.rgbShader.r = 0x4CFF9D;
			daNote.color = 0x4CFF9D;
		}
		if (rawType == 1) {
			daNote.color = 0x07E2FF;
		}
		// if (krisMute.alpha == 1)daNote.ignoreNote = true;
		//daNote.loadGraphic(Paths.image("sp/spr_rhythmgame_note_2"));
	} else if (daNote.noteType == "drum") {
		daNote.mustPress = true;
		daNote.noteData = rawType + 1;
		if (daNote.noteData > 2) {
			daNote.noteData = 2;
		//	//daNote.destroy();
		//	//return;
		}
		daNote.camera = susiNoteCam;
		daNote.gfNote = true;
		daNote.blockHit = true;
		daNote.ratingDisabled = true;
		daNote.hitsoundDisabled = true;
		daNote.extraData.set("hit", FlxG.random.int(Conductor.safeZoneOffset*(acurateDrums/100), Conductor.safeZoneOffset * (1.6*(100-acurateDrums)/100)) - Conductor.safeZoneOffset);
		//if (susiRofls)
		//	daNote.extraData.set("hit", 1000);
		// daNote.reloadNote();
		if (rawType == 0) {
			daNote.color = 0xFF073D;
		}
		else if (rawType == 1) {
			daNote.color = 0xFF07A0;
		}
		else if (rawType == 2) {
			daNote.color = 0x833B00;
			daNote.alpha = 0.1;
			daNote.animSuffix = "-alt";
			daNote.scale.x = daNote.scale.x*6;
			daNote.scale.y = daNote.scale.y/2;
		}
		//daNote.loadGraphic(Paths.image("sp/spr_rhythmgame_note_2"));
		//daNote.scale.x *= 5;
		//daNote.width = 100;
		// daNote.mustPress= false;
		// daNote.hitByOpponent=true;
	} else if (daNote.noteType == "vocal") {
		daNote.noteData = rawType + 1;
		if (rawType == 0)
			daNote.noteData = 0;
		daNote.camera = ralseiNoteCam;
		daNote.loadGraphic(Paths.image("sp/spr_rhythmgame_note_1"));
		daNote.scale.set(1.2,2.8);
		daNote.alpha = 1;
		// daNote.reloadNote();
		if (rawType == 0) {
			daNote.color = 0x008F1F;
		}
		if (rawType == 1) {
			daNote.color = 0xD0FF00;
		}
		if (rawType == 2) {
			daNote.color = 0x00FF37;
		}
		if (daNote.sustainLength>0)
			daNote.visible = false;
		if (!daNote.isSustainNote){
			//daNote.visible = ralsClap;

			daNote.offsetY = -160;
			daNote.scale.x = daNote.scale.x*6;
			daNote.scale.y = daNote.scale.y/2;
		}
	}
	if (daNote.extraData.get("lolTag") != null)
		daNote.color = 0x000000;
	//debugPrint(daNote.multSpeed);
	// else { daNote.blockHit = true;}
	// daNote.noteType = "";
	// daNote.animation.play("purpleholdend",true);
}
var susiSkills = ["singDOWN-alt", "singUP", "singDOWN"];
function onUpdate(e) {
	if (isMenuChart)
		return;

	//debugPrint(ralseiNoteCam.canvas.graphics);
	//shader_.setFloat("iTime",Conductor.songPosition);
	//shader_.setFloat("pix",1);
	//shader_.setFloat("hue",Math.sin(Conductor.songPosition/10000));
	for (light in [L1, L2, L3]) {
		light.y = Math.sin(Conductor.songPosition / 650) * 25 + 230;
	}

	game.health = 2;
	// debugPrint(ranSUMI);
	var DadDead = true;
	var BFDead = true;
	//var tempClap = true;
	var fn = 0;
	for (i in notes) {
		//debugPrint(i.y);
		//if (i.isSustainNote){
			//var swagRect:FlxRect = i.clipRect;
			//debugPrint(i.width);
			//if(swagRect != null) {
			//	i.clipRect.height = swagRect.width;
			//	i.clipRect.width = swagRect.height;
			//}
		//}
		//i.width = 100;
		if (i.strumTime + i.extraData.get("hit") <= Conductor.songPosition && i.canBeHit && i.noteType == "drum") {
			// /debugPrint(i);
			susiGoodHit(i);
		}
		//if(i.noteType == "vocal"&&i.strumTime > Conductor.songPosition){
		//	DadDead = false;
		//}
		if(i.noteType == "lead"){
			BFDead = false;
		}
		if (i.noteType =="vocal"){
			//if (i.strumTime+500 >= Conductor.songPosition)
				DadDead = i.sustainLength<0;
			//if(i.noteData ==2&&!i.isSustainNote){
			//	fn += 1;
			//}else{
			//	//debugPrint(note.noteData);
			//	DadDead = false;
			//	fn = 0;
			//}
		}
		//else if (fn==3){
		//	tempClap = true;
		//	//bpm = fn[1].strumTime - fn[0].strumTime;
		//	//debugPrint(bpm);
		//}
	}
	ralsClap = DadDead;
	//DadDead = DadDead||tempClap;
	if (!BFDead&&game.boyfriend.idleSuffix=="-alt"){
		game.boyfriend.idleSuffix = "";
		game.boyfriend.recalculateDanceIdle();
	} if (DadDead&&game.dad.idleSuffix==""){
		game.dad.idleSuffix = "-alt";
		game.dad.recalculateDanceIdle();
	} if(!DadDead&&game.dad.idleSuffix=="-alt"){
		game.dad.idleSuffix = "";
		game.dad.recalculateDanceIdle();
	}
	for (co in [susiCombo, krisCombo, ralsCombo]) {
		if (co.text.length > 3) {
			co.scale.x = 0.4;
		} else if (co.text.length > 2) {
			co.scale.x = 0.6;
		} else {
			co.scale.x = 1;
		}
	}

	bmpDistant.y = (0.45 * ((Conductor.songPosition + (60 / Conductor.bpm * 1000)) % (60 / Conductor.bpm * 4000)) * (game.songSpeed/game.playbackRate)) - 25;
	bmpDistant4.y = (0.45 * (Conductor.songPosition % (60 / Conductor.bpm * 1000)) * (game.songSpeed/game.playbackRate)) - 25;

	if (susiRofls) {
		game.gf.stunned = true;
		if (game.gf.animation.finished) {
			var anim = susiSkills[FlxG.random.int(0, 2)];
			// debugPrint(anim);
			game.gf.animation.play(anim, true);

			susiPressed(anim=="singUP",0xFF5757);
		}
	}

	SCORE.text = formatIntToString(Std.int(songScore), 6);
	if (susiMute.alpha == 1)
		susiRofls = true;

	for (m in SPcameras){
		m[0].scroll(-m[2].width,-m[2].height);
		m[0].disposeImage();
		m[0].fillRect(m[0].rect,0x00000000);
		m[0].draw(m[2].canvas,m[3]);
	}
	
}

function onUpdatePost(e){

    //var context = Lib.current.stage.context3D;
    //if (context != null) {
    //    context.clear(0, 0, 0, 0);  // очищаем с прозрачностью
    //}
}
function opponentNoteHit(daNote) {
	if (!daNote.isSustainNote) {
		ralsCombo.text = Std.int(ralsCombo.text) + 1;
		for (note in daNote.tail){
			note.color = 0xFBAE1F;
			note.alpha = 1;
		}
	}
	if (ralsClap){
		game.dad.stunned = true;
		game.dad.playAnim("idle-alt", true);
	}
	//trace(daNote.strumTime+" "+daNote.isSustainNote);
}
function opponentNoteHitPost(daNote) {
	
}

function formatIntToString(val:Int, count:Int) {
	if (val < 0)
		count -= 1;
	var s:String = "";
	// val = Math.abs(val);
	for (i in 0...count) {
		s = val % 10 + s;
		val = Std.int(val / 10);
	}
	return s;
}

function goodNoteHit(daNote) {
	if (!daNote.isSustainNote) {
		if (!daNote.gfNote) {
			krisCombo.text = Std.int(krisCombo.text) + 1;
			tmpMissKris = 0;
			if (Std.int(krisCombo.text) > Std.int(maxCombo.text)) {
				maxCombo.text = formatIntToString(Std.int(krisCombo.text), 6);
				game.maxCombo = Std.int(krisCombo.text);
			}
			//debugPrint(((Std.int(Std.int(krisCombo.text)/32)/10)+1));
			var color ;
			var color2 ;
			if (daNote.rating=="sick"){
				songScore += 100;
				color = 0xFBAE1F;
				color2 = 0xEDF100;
			}
			else if (daNote.rating=="good"){
				songScore += 50;
				color = 0xE8E8E8;
				color2 = 0xE8E8E8;
			}
			//songScore += Std.int(krisCombo.text)>=32?10:0;
			noteSplash(daNote.noteData==3);
			plSplashKris[daNote.noteData==3][0].color = color2;
			plSplashKris[daNote.noteData==3][0].alpha = 1;
			for (note in daNote.tail){
				note.color = color;
				note.alpha = 1;
			}
		} else {
			susiCombo.text = Std.int(susiCombo.text) + 1;
			tmpMissSusi = 0;
		}
	} else if (daNote.nextNote == null) {
		daNote.parent.visible = false;
		daNote.parent.alpha = 0;
		var co = 10-(songScore-0.99)%10;
		songScore +=co+20;
	} else {
		noteSplash(daNote.noteData==3,true);
		plSplashKris[daNote.noteData==3][0].color =  0xEDF100;
		plSplashKris[daNote.noteData==3][0].alpha = 1;
		//songScore += 60 / PlayState.SONG.bpm *10 / 4.0;
		songScore += 0.5;
		daNote.parent.visible = true;
		daNote.parent.alpha = 1;
	}
}

function susiGoodHit(daNote) {
	if (susiRofls)
		return;
	acurateDrums += 0.2;
	acurateDrums = Math.min(acurateDrums,100);
	var bob:Int = game.vocals.volume;
	var comboB:Int = game.combo;
	var rating = game.totalNotesHit;
	//var scoreB:Int = game.songScore;
	// game.showRating = !game.showRating;
	// game.showComboNum = !game.showComboNum;
	game.goodNoteHit(daNote);
	susiPressed(daNote.noteData-1,0xF5F5F5);
	// game.showRating = !game.showRating;
	// game.showComboNum = !game.showComboNum;
	game.vocals.volume = bob;
	game.combo = comboB;
	//game.songScore = scoreB;
	game.totalNotesHit = rating;
}

function susiPressed(key:Int,color) {
	plSplashSusi[key][0].color = color;
	plSplashSusi[key][0].scale.x = 1.3;
	plSplashSusi[key][1].scale.x = 1.3*2;
	FlxTween.cancelTweensOf(plSplashSusi[key][0]);
	FlxTween.tween(plSplashSusi[key][0], {"scale.x": 0}, 0.18
	 ,{
		onUpdate:()->{plSplashSusi[key][1].scale.x=plSplashSusi[key][0].scale.x*2;},   
		onComplete:()->{plSplashSusi[key][1].scale.x=plSplashSusi[key][0].scale.x;}   
	});
}
var tw = [false,false];
function noteSplash(key:Int,?mini=false) {
		plSplashKris[key][0].color = 0xFFFFFF;
		plSplashKris[key][0].alpha = 0.3;
		plSplashKris[key][0].scale.x = mini?0.5:1.3;
		plSplashKris[key][1].scale.x = (mini?0.5:1.3)*2;
		if (tw[key]==mini||!mini)FlxTween.cancelTweensOf(plSplashKris[key][0]);
		tw[key] = mini;
		var t = FlxTween.tween(plSplashKris[key][0], {"scale.x": 0}, 0.18 ,{
            onUpdate:()->{plSplashKris[key][1].scale.x=plSplashKris[key][0].scale.x*2;},   
            onComplete:()->{plSplashKris[key][1].scale.x=plSplashKris[key][0].scale.x;}   
        });
		//debugPrint(t);
}

function onKeyPress(key:Int) {
	if (key==0){
		game.boyfriend.playAnim("singLEFT");
	} else
	if (key==3){
		game.boyfriend.playAnim("singRIGHT");
	}
	//noteSplash(key==3,false);
	
}

function onEndSong() {
	if (game.chartingMode)
		return;
	game.songScore = songScore;
	if (!ClientPrefs.getGameplaySetting('practice') && !ClientPrefs.getGameplaySetting('botplay')) {
		var daSong = PlayState.SONG.song + PlayState.SONG.format.split("^").join();
		// trace(daSong);
		if (Highscore.songScores.exists(daSong)) {
			// trace("false");

			if (game.songScore > Highscore.songScores.get(daSong)) {
				// trace("true2");
				Highscore.setScore(daSong, game.songScore);
				Highscore.setFC(daSong, game.songMisses == 0);
				Highscore.setRating(daSong, game.percent);
			}
		} else {
			//  trace("true");
			Highscore.setScore(daSong, game.songScore);
			Highscore.setFC(daSong, game.songMisses == 0);
			Highscore.setRating(daSong, game.percent);
		}
	}
		CustomSubstate.openCustomSubstate('END', true);
		PlayState.SONG.song = "songChart";

	//FlxG.sound.music.destroy();
	//MusicBeatState.startTransition();
}
var ShapeTM;
function shareSprite(sp:FlxSprite,x) {
	if (ShapeTM!=null){
		return;
	}
	var orgX = sp.x;
	ShapeTM = FlxTimer.loop(0.06,(tim) -> {
		//debugPrint(x/((tim+1)/2-tim%2*0.5)*(tim%2*-1)+orgX+" "+tim);
		sp.x = x/((tim+1)/2-tim%2*0.5)*(tim%2*-1)+orgX;
		if (tim==7){
			sp.x= orgX;
			ShapeTM = null;
		}
	},7);
	
}

function onStepHit() {
	if (game.songName == "practice") {
		if (curStep == 72)
			susiRofls = true;
		if (curStep == 110)
			susiRofls = false;
	} else if (game.songName == "tenna") {
		if (curStep == 1570) {}
	}
}
