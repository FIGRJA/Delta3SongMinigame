import openfl.Lib;
import flixel.util.FlxTimer;
import flixel.addons.display.FlxBackdrop;
import mikolka.stages.cutscenes.dialogueBox.DialogueBoxPsych; // import haxe.Json;
import backend.MusicBeatState;
import backend.Mods;
import backend.Highscore;
import backend.ClientPrefs;
import backend.CacheSystem;
import psychlua.ModchartSprite;
import mikolka.funkin.custom.NativeFileSystem as NativeFileSystem;
import lime.graphics.opengl.GL;
import tjson.TJSON;

var isMenuChart:Bool = PlayState.SONG.song == "songChart";
var susiNoteCam:FlxCamera;
var krisNoteCam:FlxCamera;
var ralseiNoteCam:FlxCamera;
var bmpDistant:FlxBackdrop;
var maskBG:FlxSprite = new ModchartSprite(4,-10);
var krisMissBack:FlxSprite = new ModchartSprite(-190, 9800);
var susiMissBack:FlxSprite = new ModchartSprite(-190, 9800);
var krisMute:FlxSprite = new ModchartSprite(-85, 9780);
var susiMute:FlxSprite = new ModchartSprite(-85, 9780);
var susiCombo:FlxText = new FlxText(-90, 10080, 350, "0", 250, true);
var krisCombo:FlxText = new FlxText(-90, 10080, 350, "0", 250, true);
var ralsCombo:FlxText = new FlxText(-90, 10080, 350, "0", 250, true);
var wordCombo:FlxText = new FlxText(-95, 10280, 350, "COMBO", 120, true);
var maxCombo:FlxText = new FlxText(960, 647, 0, "000000", 60, true);
var maxComboText:FlxText = new FlxText(857, 675, 0, "MAX COMBO", 25, true);
var SCORE:FlxText = new FlxText(180, 647, 0, "000000", 60, true);
var SCOREText:FlxText = new FlxText(345, 675, 0, "SCORE", 25, true);
var L1 = MusicBeatState.getVariables().get("L1");
var L2 = MusicBeatState.getVariables().get("L2");
var L3 = MusicBeatState.getVariables().get("L3");
var susiRofls:Bool = false;

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

//function testShader(shaderName){
//	var shader = Paths.getPath("shaders/"+shaderName);
//	if (NativeFileSystem.exists(shader))
//		return shader;
//	return null;
//}
//
//function getShader(shaderName){
//	var vert = testShader(shaderName+".vert");
//	var frag = testShader(shaderName+".frag");
//	trace(vert);
//	trace(frag);
//	if (!game.runtimeShaders.exists(shaderName))
//		game.runtimeShaders.set(shaderName,[frag,vert]);
//	return new FlxRuntimeShader([frag,vert]);
//
//}

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

//function getShader(shaderName){
//	if(!game.runtimeShaders.exists(shaderName) &&! game.initLuaShader(shaderName))
//		{
//			return null;
//		}
//		return new ShaderFilter(game.runtimeShaders.get(shaderName));
//}

function loadSongsLists() {
	//return getVar("songMenu").call("loadSongsLists",[]);
	var result:Array = [];
	for (i in Mods.getModDirectories()) {
		var path = "mods/" + i;
		if (NativeFileSystem.exists(path + "/songList.json") && NativeFileSystem.exists(path + "/pack.json")) {
			// debugPrint(path);
			try {
				var list = DialogueBoxPsych.parseDialogue(path + "/songList.json"); // dymmy haxe.Json
				var pack = DialogueBoxPsych.parseDialogue(path + "/pack.json"); // dymmy haxe.Json
				result.push([pack, list,i]);
			} catch (e:Dynamic) {
				debugPrint(e, FlxColor.RED);
			}
		}else if (NativeFileSystem.isDirectory(path + "/SongCharts")){
			var dir = NativeFileSystem.readDirectory(path + "/SongCharts/");
			var ok = false;
			var s = '{
				"dificulties":[
					{
						"name":"play ERS",
						"prefix":"music_timing_customsong",
						"postfix":"",
						"dir":"SongCharts/"
					}
				],
				"songs":[';
			for (n in dir){
				if (n.indexOf("music_timing_customsong_info")==0){
					if (ok) s = s + ",";
					ok = true;
					var data:Array<String> = File.getContent(path + "/SongCharts/"+n).split("\n");
					s = s+'{';
					s = s+'	"name":"'+data[9]+'",';
					s = s+'	"nameFile":"",';
					s = s+'	"bpm":'+data[3]+',';
					s = s+'	"speed":'+Std.int(data[4])+',';
					s = s+'	"songMain":"'+data[0].split(".")[0].split("CUSTOM_SONGS/")[1]+'",';
					s = s+'	"songPlay":"'+data[1].split(".")[0].split("CUSTOM_SONGS/")[1]+'",';
					s = s+'	"album":'+data[11]+',';
					s = s+'	"index":"'+n.split("customsong_info")[1].split(".")[0]+'",';
					s = s+'	"hxModule":null,';
					s = s+'	"isFull":false';
					s = s+'}';
				}
			}
			if (!ok)continue;
			s = s + "]}";
			//debugPrint(s);
			var list = TJSON.parse(s);
			var pack = TJSON.parse('{"name":"'+i+'"}');
			result.push([pack, list,i]);
		}
	}
	return result;
}

var SONG:Dynamic;
var acurateDrums = 1;
var moddir = "";
var shader_;
var statusLoad;
function onCreate() // PlayState.SONG.bpm = 0.1;
{
	//setVar("D3Main",this);
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
				if (mod[0].name + diff.name == PlayState.SONG.format) {
					path = "mods/"+mod[2]+"/"+diff.dir + diff.prefix + song.nameFile + ".txt";
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
		statusLoad = getVar("load_delta_notes").call("loadSong", [path, index, song.isFull]).returnValue;
		//debugPrint(statusLoad);
		SONG = song;
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
	game.noteKillOffset = 120;
	// getVar("load_delta_notes").call("loadSong",["scripts/deltaCode/gml_ch4_scr_rhythmgame_notechart.hx",2]);
	// PlayState.SONG.bpm = 148;
	// Conductor.bpm = 148;
	// PlayState.SONG.speed = 1.1;
	// game.songSpeed = 1.1;//sos[3]/sos[2]
	try {
		//debugPrint("mods/"+moddir+"/mus/"+SONG.songMain+".ogg");
		game.inst.loadEmbedded(CacheSystem.loadSound(getSong(moddir,SONG.songMain),true,SONG.songMain));
		game.vocals.loadEmbedded(CacheSystem.loadSound(getSong(moddir,SONG.songPlay),true,SONG.songPlay));
	} catch (e:Dynamic) {}

	susiNoteCam = new FlxCamera(345, 40, 150, 400, 1);
	krisNoteCam = new FlxCamera(570, 40, 150, 400, 1);
	ralseiNoteCam = new FlxCamera(790, 40, 150, 400, 1);

	FlxG.cameras.insert(susiNoteCam, 1, false);
	FlxG.cameras.insert(krisNoteCam, 2, false);
	FlxG.cameras.insert(ralseiNoteCam, 3, false);
	susiNoteCam.zoom = 0.5;
	susiNoteCam.bgColor = 0x00;
	susiNoteCam.scroll.y = 10000;
	krisNoteCam.zoom = 0.5;
	krisNoteCam.bgColor = 0x00;
	krisNoteCam.scroll.y = 10000;
	ralseiNoteCam.zoom = 0.5;
	ralseiNoteCam.bgColor = 0x00;
	ralseiNoteCam.scroll.y = 10000;

	FlxG.stage.alpha = 1;
	FlxG.stage.color = 0x00000000;
	//FlxG.stage.background = 0x00000000;
	//debugPrint(FlxG.stage.application.window.__attributes);
	//FlxG.stage.application.window.__backend.flags |= cast WindowFlags.WINDOW_FLAG_STENCIL_BUFFER;
	FlxG.camera.bgColor = 0x8EEE0000;
	shader_ = getShader("grayT");
	//shader_ = game.createRuntimeShader("wiggle");
	trace(shader_);
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
	//Lib.application.window.opacity = 1;
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
		if (gog == 0 || gog == 3) {
			i.camera = krisNoteCam;
			i.x = -48 + gog * 45;
			if (gog == 0)
				i.rgbShader.r = 0x4CFF9D;
			if (gog == 3)
				i.rgbShader.r = 0x07E2FF;
		} else if (gog == 1 || gog == 2) {
			i.camera = susiNoteCam;
			if (gog == 1)
				i.x = -48;
			if (gog == 2)
				i.x = 88;
		}
		i.y = 390;
		i.alpha = 1;
		gog += 1;
	}
	var gog:Int = 0;
	for (i in opponentStrums) {
		i.camera = ralseiNoteCam;
		i.y = 390;
		i.alpha = 1;
		if (gog == 0)
			i.x = -68 + 90 * 0;
		if (gog == 2)
			i.x = -68 + 90 * 1;
		if (gog == 3)
			i.x = -68 + 90 * 2;
		if (gog == 1)
			i.x = -400;
		gog += 1;
	}


	
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
	wordCombo.cameras = [statusLoad[2]?ralseiNoteCam:camGame, statusLoad[1]?susiNoteCam:camGame,statusLoad[0]?krisNoteCam:camGame];
	// ralsCombo.scale.y = 4;
	wordCombo.antialiasing = false;
	wordCombo.alignment = "center";
	insert(0, wordCombo);

	var blackbacknotes = new ModchartSprite(-85, 9780);
	blackbacknotes.makeGraphic(350, 1000, FlxColor.BLACK);
	blackbacknotes.alpha = 0.4;
	blackbacknotes.cameras = [ralseiNoteCam, susiNoteCam, krisNoteCam];
	insert(4, blackbacknotes);

	//var distant = 60 / Conductor.bpm * 450;
	var distant = 0.45 * (60 / Conductor.bpm* 1000) * (game.songSpeed/game.playbackRate)*1;
	bmpDistant = new FlxBackdrop(null, 0x10, 0, distant-10); // 0x10 = Y
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

	krisMute.loadGraphic(Paths.image("sp/spr_rhythmgame_mute_0"));
	// krisMute.color = 0xFF0000;
	krisMute.scale.x = 4.2;
	krisMute.scale.y = 3.4;
	krisMute.antialiasing = false;
	krisMute.alpha = 0;
	krisMute.cameras = [krisNoteCam];
	krisMute.updateHitbox();
	add(krisMute);
	susiMute.loadGraphic(Paths.image("sp/spr_rhythmgame_mute_0"));
	// susiMute.color = 0xFF0000;
	susiMute.scale.x = 4.2; // #42
	susiMute.scale.y = 3.4;
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
	if (game.songName == "practice")
		susiRofls = false;
	game.boyfriend.idleSuffix = "-alt";
	game.boyfriend.recalculateDanceIdle();
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
	// daNote.rgbShader.enabled = true;
	// daNote.rgbShader.mult = 0.5;
	// daNote.noteHoldSplash.alpha = 0;
	rawType = daNote.noteData;
	if (daNote.noteType == "lead") {
		daNote.mustPress = true;
		daNote.noteData = rawType * 3;
		daNote.camera = krisNoteCam;
		// daNote.reloadNote();
		// daNote.x = 0;
		if (rawType == 0) {
			daNote.rgbShader.r = 0x4CFF9D;
		}
		if (rawType == 1) {
			daNote.rgbShader.r = 0x07E2FF;
		}
		// if (krisMute.alpha == 1)daNote.ignoreNote = true;
		// daNote.loadGraphic(Paths.image("sp/spr_rhythmgame_note_2"));
	} else if (daNote.noteType == "drum") {
		daNote.mustPress = true;
		daNote.noteData = rawType + 1;
		if (daNote.noteData > 2) {
			daNote.destroy();
			return;
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
			daNote.rgbShader.r = 0xFF073D;
		}
		if (rawType == 1) {
			daNote.rgbShader.r = 0xFF07A0;
		}
		// daNote.loadGraphic(Paths.image("sp/spr_rhythmgame_note_2"));
		// daNote.mustPress= false;
		// daNote.hitByOpponent=true;
	} else if (daNote.noteType == "vocal") {
		daNote.noteData = rawType + 1;
		if (rawType == 0)
			daNote.noteData = 0;
		daNote.camera = ralseiNoteCam;
		// daNote.reloadNote();
		if (rawType == 0) {
			daNote.rgbShader.r = 0x008F1F;
		}
		if (rawType == 1) {
			daNote.rgbShader.r = 0xD0FF00;
		}
		if (rawType == 2) {
			daNote.rgbShader.r = 0x00FF37;
		}
		if (daNote.sustainLength>0)
			daNote.visible = false;
		if (!daNote.isSustainNote)
			//daNote.visible = ralsClap;
			daNote.scale.x = daNote.scale.x*3;
	}
	if (!daNote.isSustainNote) {
		daNote.scale.y = 0.5;
	}
	if (daNote.extraData.get("lolTag") != null)
		daNote.rgbShader.r = 0x000000;
	//debugPrint(daNote.multSpeed);
	// else { daNote.blockHit = true;}
	// daNote.noteType = "";
	// daNote.animation.play("purpleholdend",true);
}

var susiSkills = ["singDOWN-alt", "singUP", "singDOWN"];
function onUpdate(e) {
	//shader_.setFloat("iTime",Conductor.songPosition);
	//shader_.setFloat("pix",1);
	//shader_.setFloat("hue",Math.sin(Conductor.songPosition/10000));
	for (light in [L1, L2, L3]) {
		light.y = Math.sin(Conductor.songPosition / 650) * 25 + 230;
	}

	if (isMenuChart)
		return;
	game.health = 2;
	// debugPrint(ranSUMI);
	var DadDead = true;
	var BFDead = true;
	//var tempClap = true;
	var fn = 0;
	for (i in notes) {
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
			if(i.noteData ==2&&!i.isSustainNote){
				fn += 1;
			}else{
				//debugPrint(note.noteData);
				DadDead = false;
				fn = 0;
			}
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

	bmpDistant.y = (0.45 * (Conductor.songPosition % (60 / Conductor.bpm * 1000)) * (game.songSpeed/game.playbackRate)) + 5;

	if (susiRofls) {
		game.gf.stunned = true;
		if (game.gf.animation.finished) {
			var anim = susiSkills[FlxG.random.int(0, 2)];
			// debugPrint(anim);
			game.gf.animation.play(anim, true);
		}
	}

	SCORE.text = formatIntToString(game.songScore, 6);
	if (susiMute.alpha == 1)
		susiRofls = true;

	
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
	}
	if (ralsClap){
		game.dad.stunned = true;
		game.dad.playAnim("idle-alt", true);
	}
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
		} else {
			susiCombo.text = Std.int(susiCombo.text) + 1;
			tmpMissSusi = 0;
		}
	} else if (daNote.nextNote == null) {
		daNote.parent.visible = false;
		daNote.parent.alpha = 0;
	} else {
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
	var scoreB:Int = game.songScore;
	// game.showRating = !game.showRating;
	// game.showComboNum = !game.showComboNum;
	game.goodNoteHit(daNote);
	// game.showRating = !game.showRating;
	// game.showComboNum = !game.showComboNum;
	game.vocals.volume = bob;
	game.combo = comboB;
	game.songScore = scoreB;
	game.totalNotesHit -= daNote.ratingMod;
}

function onKeyPress(key:Int) {
	if (key==0){
		game.boyfriend.playAnim("singLEFT");
	} else
	if (key==3){
		game.boyfriend.playAnim("singRIGHT");
	}
	
}

function onEndSong() {
	if (game.chartingMode)
		return;
	if (!ClientPrefs.getGameplaySetting('practice') && !ClientPrefs.getGameplaySetting('botplay')) {
		var daSong = PlayState.SONG.song + PlayState.SONG.format;
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

	PlayState.SONG.song = "songChart";
	//FlxG.sound.music.destroy();
	//MusicBeatState.startTransition();
	CustomSubstate.openCustomSubstate('END', true);
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
