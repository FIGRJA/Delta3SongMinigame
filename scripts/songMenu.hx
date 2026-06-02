import haxe.macro.Expr.Catch;
import backend.Controls;
import backend.MusicBeatState;
import backend.Mods;
import backend.Highscore;
import backend.CacheSystem;
import psychlua.CustomSubstate;
import flixel.addons.display.FlxBackdrop;
import flixel.util.FlxSpriteUtil;
import flixel.sound.FlxSound;
import mikolka.stages.cutscenes.dialogueBox.DialogueBoxPsych; // import haxe.Json;
import mikolka.vslice.StickerSubState;
import mikolka.vslice.freeplay.FreeplayState;
import mikolka.funkin.custom.NativeFileSystem as NativeFileSystem;

import tjson.TJSON;
var isAllowed:Bool = PlayState.SONG.song == "songChart";
var Control = Controls.instance;
var backed:FlxBackdrop;
var inst:FlxSound = new FlxSound();
var freePlay:FlxSound = new FlxSound();
var curAction:Int = 0;
var freeAction:Array = [];
var timer:Float;
var menu:FlxCamera = new FlxCamera(0, 0, 1280, 720, 1);
var modInfoText:FlxText;
var songScoreText:FlxText;

function onCreate() {
	setVar("songMenu",this);
	if (!isAllowed)
		return;

	//PlayState.startAndEnd = () -> {
	//	if(game.endingSong)
	//		//endSong();
	//		trace("you fool");
	//	else
	//		game.startCountdown();
	//};

	PlayState.SONG.bpm = 0.1;

	backed = new FlxBackdrop();
	backed.antialiasing = false;
	// backed.loadGraphic(Paths.image("anim/tv"));
	backed.frames = Paths.getSparrowAtlas("anim/tv");
	backed.velocity.set(-100, 100);
	backed.scale.set(3, 3);
	backed.animation.addByPrefix("pog", 'spr_dw_tv_starbgtile_', 16);
	backed.animation.play('pog', true);
	backed.camera = menu;
	// backed.alpha = 0.8;
	insert(0, backed);

	game.luaDebugGroup.cameras = [game.camOther, menu];
	FlxG.cameras.add(menu, false);
	try {
        FlxG.sound.music.destroy();
        //FlxG.sound.list.clear();
		// debugPrint(FlxG.sound.list);
		if (FlxG.random.bool(5)){
			//inst.loadEmbedded(Paths.returnSound("glacier", "mus"), true);
			//inst.loadEmbedded(Paths.returnSound("northernlight", "mus"), true);
			inst.loadEmbedded(Paths.returnSound("tinnitus", "mus"), true);
			inst.pitch = 1;
			backed.velocity.set(10, -10);
			backed.scale.set(2, 2);
			backed.color = FlxG.random.color(0x222222,0x000000,255);
			//var bb1 = new FlxBackdrop();
			//var bb2 = new FlxBackdrop();
			//var bb3 = new FlxBackdrop();
			var max = 100;	
			backed.spacing.set(80*(Math.sqrt(max)-1),80*(Math.sqrt(max)-1));
			for (i in 0...(max-1)){
				var b = new FlxBackdrop();
				b.antialiasing = false;
				b.loadGraphic(Paths.image("anim/tv"));
				b.frames = Paths.getSparrowAtlas("anim/tv");
				b.velocity.set(10, -10);			
				b.spacing.set(80*(Math.sqrt(max)-1),80*(Math.sqrt(max)-1));
				b.scale.set(2, 2);
				b.animation.addByPrefix("pog", 'spr_dw_tv_starbgtile_', 8	);
				b.animation.play('pog', true);
				b.camera = menu;
				b.x = 80*2*(i+1)%Math.sqrt(max);	
				b.y = 80*2*Std.int((i+1)/Math.sqrt(max));
				b.color = FlxG.random.color(0x475A46,0x0C0C0C,255	);
				//debugPrint(240*(i+1)%2);
				insert(0, b);
			}}
		else if (FlxG.random.bool(10)){	
			inst.loadEmbedded(Paths.returnSound("church_lw_night", "mus"), true);
			inst.pitch = 0.9;
			backed.velocity.set(30, -30);
			backed.color = FlxG.random.color(0xFFFFFF,0x000000,255);
			//var bb1 = new FlxBackdrop();
			//var bb2 = new FlxBackdrop();
			//var bb3 = new FlxBackdrop();
			var max = 25;	
			backed.spacing.set(80*(Math.sqrt(max)-1),80*(Math.sqrt(max)-1));
			for (i in 0...(max-1)){
				var b = new FlxBackdrop();
				b.antialiasing = false;
				b.loadGraphic(Paths.image("anim/tv"));
				b.frames = Paths.getSparrowAtlas("anim/tv");
				b.velocity.set(30, -30);			
				b.spacing.set(80*(Math.sqrt(max)-1),80*(Math.sqrt(max)-1));
				b.scale.set(3, 3);
				b.animation.addByPrefix("pog", 'spr_dw_tv_starbgtile_', 16);
				b.animation.play('pog', true);
				b.camera = menu;
				b.x = 240*(i+1)%Math.sqrt(max);	
				b.y = 240*Std.int((i+1)/Math.sqrt(max));
				b.color = FlxG.random.color(0xFFFFFF,0x8A8989,255	);
				//debugPrint(240*(i+1)%2);
				insert(0, b);
			}
			//bb1.x += 240;
			//bb1.y += 240;
			//bb1.color = 0x00FF44;
			//bb2.color = 0xFF8282;
			//bb2.x = 240;
			//bb3.y = 240;
			//bb3.color = 0x093660;
			//insert(1, bb1);
			//insert(2, bb2);
			//insert(3, bb3);

		}else if (FlxG.random.bool(20)){
			inst.loadEmbedded(Paths.returnSound("tv_results_screen", "mus"), true);
			inst.pitch = 0.3;
			backed.velocity.set(-30, 30);
		}else
			inst.loadEmbedded(Paths.returnSound("greenroom_detune", "mus"), true);
		inst.volume = 0;
		inst.play();
		inst.fadeIn(2);
		FlxG.sound.list.add(inst);
	} catch (e:Dynamic) {}


	modInfoText = new FlxText(700, 0, 580, "", 60, true);
	modInfoText.font = Paths.getPath("fronts/fnt_main.ttf");
	modInfoText.cameras = [menu];
	modInfoText.antialiasing = false;
	modInfoText.alignment = "right";
	add(modInfoText);

	songScoreText = new FlxText(700, 660, 580, "000000", 60, true);
	songScoreText.font = Paths.getPath("fronts/fnt_main.ttf");
	songScoreText.cameras = [menu];
	songScoreText.antialiasing = false;
	songScoreText.alignment = "right";
	add(songScoreText);

	for (mod in loadSongsLists())
		for (song in mod[1].songs) {
			var action = new FlxText(0, 0, 1200, song.name, 100, true);
			action.font = Paths.getPath("fronts/fnt_main.ttf");
			action.cameras = [menu];
			// action.angle = 10;
			// action.screenCenter(0x11);//XY
			action.x = 150 + freeAction.length * 30;
			action.y = freeAction.length * 100 + 600;
			action.antialiasing = false;
			action.alignment = "left";
			add(action);
			freeAction.push([mod, action, song]);
		}

	game.endCallback = function() {
		debugPrint("bep");
	};
	game.skipCountdown = true;
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

function loadSongsLists() {
	//return getVar("D3Main").call("loadSongsLists",[]);
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
				debugPrint(e, FlxColor.BLACK);
			}
		}
		else if (NativeFileSystem.isDirectory(path + "/SongCharts")){
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
					s = s+'	"bpm":'+data[4]+',';
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
			//debugPrint(i);
			var list = TJSON.parse(s);
			var pack = TJSON.parse('{"name":"'+i+'"}');
			result.push([pack, list,i]);
		}
	}
	return result;
}

function onCreatePost() {
	try{
		onCreatePosts();
	} catch (e:Dynamic){
		debugPrint(e,FlxColor.RED);
	}
}

function onCreatePosts() {
	if (!isAllowed)
		return;
	for (i in 0...freeAction.length) {
		FlxTween.tween(freeAction[i][1], {y: 350 + (i - curAction) * 100, x: 150 + (i - curAction) * 20, alpha: 1 - (Math.abs(curAction - i) / 4)}, 0.2,
			{ease: FlxEase.circOut});
	}
	modInfoText.text = freeAction[curAction][0][0].name;
	game.startingSong = false;
}

function onSongStart() {
	if (!isAllowed)
		return;
}

var diffAction:Array;
var curDiffAction:Int = 0;

function onUpdate(e) {
	if (!isAllowed)
		return;
	if (timer > 0) {
		timer -= e;
		return;
	}
	if (Control.BACK) {
		if (diffAction != null) {
			onCreatePost();
			for (diff in diffAction) {
				diff.destroy();
			}
			diffAction = null;
			curDiffAction = 0;

			inst.fadeOut(2, 1);
			freePlay.fadeOut(1, 0);
			FlxG.sound.list.remove(freePlay);
		} else {
			CustomSubstate.closeCustomSubstate();
			PlayState.deathCounter = 0;
			PlayState.seenCutscene = false;

			PlayState.instance.canResync = false;
			PlayState.changedDifficulty = false;
			PlayState.chartingMode = false;
			FlxG.camera.followLerp = 0;
			inst.fadeOut(0.5);
			openSubState(new StickerSubState(null, (sticker) -> FreeplayState.build(null, sticker)));
		}
	}
	if (Control.ACCEPT) {
		if (diffAction == null) {
			diffAction = [];

			inst.fadeOut(2, 0.1);
			for (diff in freeAction[curAction][0][1].dificulties) {
				// debugPrint(diff);
				var action = new FlxText(0, 0, 700, diff.name, 100, true);
				action.font = Paths.getPath("fronts/fnt_main.ttf");
				action.cameras = [menu];
				// action.angle = 10;
				// action.screenCenter(0x11);//XY
				action.x = 150 + diffAction.length * 30;
				action.y = diffAction.length * 100 + 350;
				action.alpha = 1 - (diffAction.length / 4);
				action.antialiasing = false;
				action.alignment = "left";
				add(action);
				FlxTween.tween(action, {x: 550 + diffAction.length * 20, alpha: 1 - (diffAction.length / 4)}, 0.2, {ease: FlxEase.circOut});
				diffAction.push(action);
			}
			for (i in 0...freeAction.length) {
				FlxTween.tween(freeAction[i][1], {y: 350 + (i - curAction) * 100, x: 400-38*freeAction[curAction][1].text.length -Math.abs(i - curAction) * 30, alpha: 1 - (Math.abs(curAction - i) / 4)},
					0.2, {ease: FlxEase.circOut});
			}
			try {
				//FlxG.sound.music.destroy();
				//FlxG.sound.list.clear();
				//debugPrint("mods/"+freeAction[curAction][0][2]+"/mus/"+freeAction[curAction][2].songMain+".ogg");
				//debugPrint(CacheSystem.loadSound("mods/"+freeAction[curAction][0][2]+"/mus/"+freeAction[curAction][2].songMain+".ogg",true,freeAction[curAction][2].songMain+', PATH: mus'+freeAction[curAction][0][2]));
				freePlay.loadEmbedded(CacheSystem.loadSound("mods/"+freeAction[curAction][0][2]+"/mus/"+freeAction[curAction][2].songMain+".ogg",false,freeAction[curAction][2].songMain+', PATH: mus'+freeAction[curAction][0][2]), true);
				freePlay.volume = 0;
				freePlay.play();
				freePlay.fadeOut(2,0.7);
				FlxG.sound.list.add(freePlay);
			} catch (e:Dynamic) {}
		} else {
			inst.fadeOut(0.5);
			PlayState.SONG.song = freeAction[curAction][2].name;
			PlayState.SONG.format = freeAction[curAction][0][0].name + diffAction[curDiffAction].text;
			MusicBeatState.resetState();
		}
		// switch(freeAction[curAction].text){
		//    case "play":
		//        PlayState.SONG.song = "karaoke";
		//        MusicBeatState.resetState();
		//	//PlayState.nextReloadAll = true;
		//    case "exit":
		// }
	}
	if (Control.UI_UP) {
		if (diffAction == null)
			curAction -= 1;
		else
			curDiffAction -= 1;
		timer = 0.15;
	}
	if (Control.UI_DOWN) {
		if (diffAction == null)
			curAction += 1;
		else
			curDiffAction += 1;
		timer = 0.15;
	}
	curAction = Math.abs(freeAction.length + curAction) % freeAction.length;
	if (diffAction != null)
		curDiffAction = Math.abs(diffAction.length + curDiffAction) % diffAction.length;
	// debugPrint("                                                           "+curAction);
	songScoreText.text = formatIntToString(getTmpScore(), 6);
	if (timer > 0) {
		modInfoText.text = freeAction[curAction][0][0].name;
		if (diffAction == null)
			for (i in 0...freeAction.length)
				FlxTween.tween(freeAction[i][1], {y: 350 + (i - curAction) * 100, x: 150 + (i - curAction) * 20, alpha: 1 - (Math.abs(curAction - i) / 4)},
					0.2, {ease: FlxEase.circOut});
		else {
			for (i in 0...freeAction.length)
				FlxTween.tween(freeAction[i][1], {y: 350 + (i - curAction) * 100, x: 400-38*freeAction[curAction][1].text.length -Math.abs(i - curAction) * 30, alpha: 1 - (Math.abs(curAction - i) / 4)},
					0.2, {ease: FlxEase.circOut});
			for (i in 0...diffAction.length)
				FlxTween.tween(diffAction[i],
					{y: 350 + (i - curDiffAction) * 100, x: 550 + (i - curDiffAction) * 20, alpha: 1 - (Math.abs(curDiffAction - i) / 4)}, 0.2,
					{ease: FlxEase.circOut});
		}
	}
}

function getTmpScore() {
	var path = freeAction[curAction][2].name + freeAction[curAction][0][0].name + freeAction[curAction][0][1].dificulties[curDiffAction].name;
	// debugPrint(Highscore.songScores.exists(path));
	// trace(path);
	if (Highscore.songScores.exists(path))
		return Highscore.songScores.get(path);
	return 0;
}

function onDestroy() {
	 //FlxTimer.start(2,(tim)->{inst.stop();});
	 inst.stop();
	// ();
}
