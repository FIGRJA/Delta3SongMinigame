if (PlayState.SONG.stage!="D3Main") return;
//import haxe.macro.Expr.Catch;
import backend.Controls;
import backend.MusicBeatState;
import backend.Mods;
import backend.Highscore;
import backend.CacheSystem;
import psychlua.CustomSubstate;
import flixel.addons.display.FlxBackdrop;
import flixel.util.FlxSpriteUtil;
import flixel.sound.FlxSound;
import mikolka.stages.cutscenes.dialogueBox.DialogueBoxPsych; // import haxe.Json;//or TJSON
import mikolka.vslice.StickerSubState;
import mikolka.vslice.freeplay.FreeplayState;
import mikolka.funkin.utils.MathUtil;
import mikolka.funkin.custom.NativeFileSystem as NativeFileSystem;

import mobile.objects.TouchZone;
if (Controls.instance.mobileC)
	import mobile.objects.ScrollableObject;

import tjson.TJSON;
var isAllowed:Bool = PlayState.SONG.song == "songChart";
var practicN = "practice"+"deltarun 3 MiniGame"+"play";
//debugPrint(Highscore.songScores.get(practicN));
if ((!Highscore.songScores.exists(practicN)||Highscore.songScores.get(practicN)<1)&&isAllowed){
	PlayState.SONG.song = "tutorialus    (infinity)";//song name
	PlayState.SONG.format = "deltarun 3 MiniGame" +"^"+ "play";// mod name + dificult
	game.songName = "tutorialus-- --(infinity)";
	isAllowed = false;
	//MusicBeatState.resetState();
}
var Control = Controls.instance;
var backed:FlxBackdrop;
var AlbumCover:FlxSprite = new FlxSprite((FlxG.width)-210,60);
var inst:FlxSound = new FlxSound();
var freePlay:FlxSound = new FlxSound();
var freeAction:Array = [];
var curAction:Int = 0;
var diffAction:Array;
var curDiffAction:Int = 0;
var timer:Float;
var menu:FlxCamera = new FlxCamera(0, 0, FlxG.width, FlxG.height, 1);
var modInfoText:FlxText;
var songScoreText:FlxText;
var butArray = [];

function setVF(Var,Fun) {
	if (getVar(Var).exists(Fun))
		this.set(Fun,getVar(Var).get(Fun));
	
}
setVar("songMenu",this);

var glitchAr = [];
var limitD = 0;
function onCreate() {
	//setVar("songMenu",this);
	if (!isAllowed)
		return;

	//PlayState.startAndEnd = () -> {
	//	if(game.endingSong)
	//		//endSong();
	//		trace("you fool");
	//	else
	//		game.startCountdown();
	//};

	PlayState.SONG.bpm = 0.001;
	PlayState.chartingMode = false;
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
    	//FlxG.sound.music.destroy();
        //FlxG.sound.music.pause();
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
			glitchAr.push(backed);
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
				glitchAr.push(b);
				insert(0, b);
			}}
		else if (FlxG.random.bool(8)){	
			inst.loadEmbedded(Paths.returnSound("church_lw_night", "mus"), true);
			inst.pitch = 0.9;
			backed.velocity.set(30, -30);
			backed.color = FlxG.random.color(0xFFFFFF,0x000000,255);
			//var bb1 = new FlxBackdrop();
			//var bb2 = new FlxBackdrop();
			//var bb3 = new FlxBackdrop();
			var max = 25;	
			glitchAr.push(backed);
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
				glitchAr.push(b);
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

		}else if (FlxG.random.bool(15)){
			inst.loadEmbedded(Paths.returnSound("tv_results_screen", "mus"), true);
			inst.pitch = 0.3;
			backed.velocity.set(-30, 30);
			glitchAr.push(backed);
			var max = 16;
			backed.spacing.set(80*(Math.sqrt(max)-1),80*(Math.sqrt(max)-1));
			for (i in 0...(max-1)){
				var b = new FlxBackdrop();
				b.antialiasing = false;
				b.loadGraphic(Paths.image("anim/tv"));
				b.frames = Paths.getSparrowAtlas("anim/tv");
				b.velocity.set(-30, 30);			
				b.spacing.set(80*(Math.sqrt(max)-1),80*(Math.sqrt(max)-1));
				b.scale.set(3, 3);
				b.animation.addByPrefix("pog", 'spr_dw_tv_starbgtile_', 16);
				b.animation.play('pog', true);
				b.camera = menu;
				b.x = 240*(i+1)%Math.sqrt(max);	
				b.y = 240*Std.int((i+1)/Math.sqrt(max));
				//b.color = FlxG.random.color(0xFFFFFF,0x8A8989,255	);
				//debugPrint(240*(i+1)%2);
				glitchAr.push(b);
				insert(0, b);
			}
		}else
			inst.loadEmbedded(Paths.returnSound("greenroom_detune", "mus"), true);
		inst.volume = 0;
		inst.play();
		inst.fadeIn(2);
		FlxG.sound.list.add(inst);
		//game.inst = inst;	
	} catch (e:Dynamic) {}


	modInfoText = new FlxText((FlxG.width)-580, 0, 580, "", 60, true);
	modInfoText.font = Paths.getPath("fronts/fnt_main.ttf");
	modInfoText.cameras = [menu];
	modInfoText.antialiasing = false;
	modInfoText.alignment = "right";
	add(modInfoText);

	//AlbumCover.x = 700;
	AlbumCover.cameras = [menu];
	AlbumCover.width = 120;
	AlbumCover.height = 90;
	add(AlbumCover);

	songScoreText = new FlxText((FlxG.width)-580, 660, 580, "000000", 60, true);
	songScoreText.font = Paths.getPath("fronts/fnt_main.ttf");
	songScoreText.cameras = [menu];
	songScoreText.antialiasing = false;
	songScoreText.alignment = "right";
	add(songScoreText);


	for (mod in loadSongsLists()){
		//if (!list.enabled.contains(mod[2]))continue;
		for (song in mod[1].songs) {
			var action = new FlxText(0, 0, 12000, song.name, 100, true);
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
	}

	game.endCallback = function() {
		debugPrint("bep");
	};
	game.skipCountdown = true;
	limitD = glitchAr.length;

	if (Control.mobileC){
		var button = new TouchZone( 70, (FlxG.height/2),  FlxG.width/1.5,  100);
		button.cameras = [menu];
		//button.alpha = 0.3;
		var back = new TouchZone(-930,0,  1000, FlxG.height,0xFFFF2C2C);
		back.cameras = [menu];
		back.alpha = 0.1;
		add(back);
		butArray.push(back);

		var scroll = new ScrollableObject(0.02, 70, 0, FlxG.width/1.5, FlxG.height, button);
		//scroll.alpha = 0.3;
		scroll.cameras = [menu];
		scroll.onPartialScroll.add(delta ->
		{
			
			if (diffAction == null)
				curAction -= delta;
			else
				curDiffAction -= delta;
			//timer = 0.1;
			updateText(true);
		});
		scroll.onFullScrollSnap.add(() -> {
			curAction = Std.int(curAction);
			updateText();
		});
		//scroll.onFullScroll.add(delta ->
		//{
		//	if (diffAction == null)
		//		curAction -= delta;
		//	else
		//		curDiffAction -= delta;
		//	timer = 0.001;
		//});
		scroll.onTap.add(() ->
		{
			pressAccept();
			updateText();
		});
		add(scroll);
		butArray.push(scroll);
		add(button);
		butArray.push(button);
	}
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

function readNEOHead(_File) {
	var d = File.getContent(_File);
	d = d.split("(/!\\ Chart saved below /!\\)")[0].split("\n");
	//debugPrint(d);
	var s = "{";
	for(i in d){
		m = i.split(":");
		s += '"'+m[0].split(" ").join("_")+'":'+m[1]+",";
	}
	s += "}";
	return TJSON.parse(s);
}

function findERS(result,path,i) {
	if (NativeFileSystem.isDirectory(path + "/SongCharts")){
		var dir = NativeFileSystem.readDirectory(path + "/SongCharts/");
		var ok = false;
		var diffsH = false;
		for (n in dir){
			if (n.indexOf("_hard")>0){
			diffsH = true;
			}
		}
		var s = '{
			"dificulties":[
				{
					"name":"play ERS",
					"prefix":"music_timing_customsong",
					"postfix":".txt",
					"dir":"SongCharts/"
				}';
		s +=diffsH?(',{
				"name":"Hard ERS",
				"prefix":"music_timing_customsong",
				"postfix":"_hard.txt",
				"dir":"SongCharts/"
			}'):"";
		s +='],
			"songs":[';
		for (n in dir){
			if (n.indexOf("music_timing_customsong_info")==0){
				if (ok) s = s + ",";
				ok = true;
				var data:Array<String> = File.getContent(path + "/SongCharts/"+n).split("\n");
				s = s+'{\n';
				s = s+'	"name":"'+data[9]+'",\n';
				s = s+'	"nameFile":"'+n.split("customsong_info")[1].split(".")[0]+'",\n';
				s = s+'	"bpm":'+data[3]+',\n';
				s = s+'	"speed":'+data[4]+',\n';
				s = s+'	"songMain":"'+data[0].split(".")[0].split("CUSTOM_SONGS").join("").split("/").join("").split("\\").join("")+'",\n';
				s = s+'	"songPlay":"'+data[1].split(".")[0].split("CUSTOM_SONGS").join("").split("/").join("").split("\\").join("")+'",\n';
				s = s+'	"prewCh":"'+data[6].split(".")[0].split("CUSTOM_SONGS").join("").split("/").join("").split("\\").join("")+'",\n';
				s = s+'	"prew":"'+data[7].split(".")[0].split("CUSTOM_SONGS").join("").split("/").join("").split("\\").join("")+'",\n';
				s = s+'	"album":'+data[11]+',\n';
				s = s+'	"index":null,\n';
				s = s+'	"hxModule":null,\n';
				s = s+'	"dynamic_solo":false\n';
				s = s+'}\n';
			}
		}
		if (ok){
			s = s + "]}";
			//debugPrint(s);
			//debugPrint(i);
			var list = TJSON.parse(s);
			var pack = TJSON.parse('{"name":"'+i+'"}');
			result.push([pack, list,i]);
		}
	}
}

function findNEO(result,path,i) {
	var s = "";
	var IsE = false; 
	var h = ()->{
		if (!IsE){
			s = '{
				"dificulties":[
					{
						"name":"play NEO",
						"prefix":"",
						"postfix":"",
						"dir":""
					}
				],
				"songs":[';
			IsE = true;
		}
	}
	for (n in NativeFileSystem.readDirectory(path)){
		if (n.indexOf(".neo")>0){
			if (IsE) s = s + ",";
				
			h();
			var data = readNEOHead(path+"/"+n);
			//debugPrint(data);
			s = s+'{';
			s = s+'	"name":"'+n.split(".neo").join("")+'",';
			s = s+'	"nameFile":"'+n+'",';
			s = s+'	"bpm":'+data.BPM+',';
			s = s+'	"speed":'+data.Note_speed+',';
			s = s+'	"songMain":"'+data.Music_file_no_guitar.split(".")[0]+'",';
			s = s+'	"songPlay":"'+data.Music_file.split(".")[0]+'",';
			s = s+'	"prewCh":"'+data.Menu_preview.split(".")[0]+'",';
			s = s+'	"prew":"'+data.Menu_preview.split(".")[0]+'",';
			s = s+'	"album":'+data.Album+',';
			s = s+'	"index":"",';
			s = s+'	"hxModule":null,';
			s = s+'	"dynamic_solo":false';
			s = s+'}';
		}
	}
	if (IsE){
		s = s + "]}";
		var list = TJSON.parse(s);
		//debugPrint(list);
		var pack = TJSON.parse('{"name":"'+i+'"}');
		result.push([pack, list,i]);
	}
}
function findMIDI(result,path,i) {
	var s = "";
	var IsE = false; 
	var h = ()->{
		if (!IsE){
			s = '{
				"dificulties":[
					{
						"name":"play MIDI",
						"prefix":"",
						"postfix":"",
						"dir":""
					}
				],
				"songs":[';
			IsE = true;
		}
	}
	for (n in NativeFileSystem.readDirectory(path)){
		if (n.indexOf(".mid")>0&&NativeFileSystem.exists(path+"/mus/"+n.split(".mid").join("")+".ogg")){
			if (IsE) s = s + ",";
				
			h();
			var data = readNEOHead(path+"/"+n.split(".mid").join("")+".txt");
			//debugPrint(data);
			s = s+'{';
			s = s+'	"name":"'+n.split(".mid").join("")+'",';
			s = s+'	"nameFile":"'+n+'",';
			s = s+'	"bpm":0,';
			s = s+'	"speed":120,';
			s = s+'	"songMain":"'+n.split(".mid").join("")+'.ogg",';
			s = s+'	"songPlay":"'+n.split(".mid").join("")+'.ogg",';
			s = s+'	"album":../'+n.split(".mid").join("")+',';
			s = s+'	"index":"",';
			s = s+'	"hxModule":null,';
			s = s+'	"dynamic_solo":false';
			s = s+'}';
		}
	}
	if (IsE){
		s = s + "]}";
		var list = TJSON.parse(s);
		//debugPrint(list);
		var pack = TJSON.parse('{"name":"'+i+'"}');
		result.push([pack, list,i]);
	}
}

function loadSongsLists() {
	//return getVar("D3Main").call("loadSongsLists",[]);
	var result:Array = [];

	Mods.updateModList();
	var list = Mods.parseList();
	//for (i in Mods.getModDirectories()) {
	for (i in list.enabled) {
		var path = "mods/" + i;
		if (NativeFileSystem.exists(path + "/songList.json") ) {
			// debugPrint(path);&& 
			try {
				var list = DialogueBoxPsych.parseDialogue(path + "/songList.json"); // dymmy haxe.Json
				if (NativeFileSystem.exists(path + "/pack.json"))
					var pack = DialogueBoxPsych.parseDialogue(path + "/pack.json"); // dymmy haxe.Json
				else
					var pack = TJSON.parse('{"name":"'+i+'"}');
				result.push([pack, list,i]);
			} catch (e:Dynamic) {
				debugPrint(e, FlxColor.BLACK);
			}
		}
		findERS(result,path,i);
		findNEO(result,path,i);
		//findMIDI(result,path,i);
		
	}
	return result;
}

function onCreatePost() {
setVF("endScreen","playSnd");
setVF("extraVar","setStaticVar");
setVF("extraVar","getStaticVar");
	if (getStaticVar("test")!=null)
		curAction = getStaticVar("test");
	try{
		onCreatePosts();
	} catch (e:Dynamic){
		debugPrint(e,FlxColor.RED);
	}
}

function getAlbumCover(mod,cover) {
	//var name = "mods/"+mod+"/SongAlbums/"+cover+".png";
	//if (NativeFileSystem.exists(name)){
		//trace("found!");
		//FlxG.bitmap.add(name);
	return CacheSystem.loadBitmap("SongAlbums/"+cover+".png",mod,true);
	//}
}

function onCreatePosts() {
	if (!isAllowed)
		return;
	updateText();
	game.startingSong = false;

        FlxG.sound.music.pause();
}

function onSongStart() {
	if (!isAllowed)
		return;
}

function pressAccept() {
	for (b in butArray){
		b.x+=400;
	}
	if (diffAction == null) {
		curAction = Std.int(curAction);
		playSnd("coin");
		diffAction = [];

		inst.fadeOut(2, 0.1);
		for (diff in freeAction[Std.int(curAction)][0][1].dificulties) {
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
			FlxTween.tween(freeAction[i][1], {y: 350 + (i - curAction) * 100, x: 400-38*freeAction[Std.int(curAction)][1].text.length -Math.abs(i - curAction) * 30, alpha: 1 - (Math.abs(curAction - i) / 4)},
				0.2, {ease: FlxEase.circOut});
		}
		try {
			//FlxG.sound.music.destroy();
			//FlxG.sound.list.clear();
			//debugPrint("mods/"+freeAction[Std.int(curAction)][0][2]+"/mus/"+freeAction[Std.int(curAction)][2].songMain+".ogg");
			//debugPrint(CacheSystem.loadSound("mods/"+freeAction[Std.int(curAction)][0][2]+"/mus/"+freeAction[Std.int(curAction)][2].songMain+".ogg",true,freeAction[Std.int(curAction)][2].songMain+', PATH: mus'+freeAction[Std.int(curAction)][0][2]));
			//freePlay.loadEmbedded(CacheSystem.loadSound("mods/"+freeAction[Std.int(curAction)][0][2]+"/mus/"+freeAction[Std.int(curAction)][2].songMain+".ogg",false,freeAction[Std.int(curAction)][2].songMain), true);
			//trace(Paths.formatToSongPath(freeAction[Std.int(curAction)][2].name)+'/Inst, PATH: mus');
			//debugPrint(getTmpScore()>0?(freeAction[Std.int(curAction)][2].prew==null?freeAction[Std.int(curAction)][2].songMain:freeAction[Std.int(curAction)][2].prew):(freeAction[Std.int(curAction)][2].prewCh==null?freeAction[Std.int(curAction)][2].songPlay:freeAction[Std.int(curAction)][2].prewCh));
			var songT = freeAction[Std.int(curAction)][2];
			freePlay.loadEmbedded(CacheSystem.loadSound("mods/"+freeAction[Std.int(curAction)][0][2]+"/mus/"+(getTmpScore()>0?((songT.prew==null||songT.prew=="NONE")?songT.songMain:songT.prew):((songT.prewCh==null||songT.prewCh=="NONE")?songT.songPlay:songT.prewCh))+".ogg",true,Paths.formatToSongPath(songT.name)+'/Inst, PATH: mus'), true);
			freePlay.volume = 0;
			freePlay.play();
			freePlay.fadeOut(2,1);
			FlxG.sound.list.add(freePlay);
		} catch (e:Dynamic) {}
	} else {
		setStaticVar("test",curAction);
		inst.fadeOut(0.5);
		PlayState.SONG.song = freeAction[Std.int(curAction)][2].name;
		PlayState.SONG.format = freeAction[Std.int(curAction)][0][0].name +"^"+ diffAction[curDiffAction].text;
		MusicBeatState.resetState();
	}
}
var targetScore = 0;
function updateText(?Simpy=false) {

	curAction = Math.abs(freeAction.length + curAction) % freeAction.length;
	if (diffAction != null)
		curDiffAction = Math.abs(diffAction.length + curDiffAction) % diffAction.length;
	// debugPrint("                                                           "+curAction);
	//songScoreText.text = formatIntToString(getTmpScore(), 6);
	targetScore = getTmpScore();
	trace(targetScore);

	var bg = getAlbumCover(freeAction[Std.int(curAction)][0][2],freeAction[Std.int(curAction)][2].album);
	AlbumCover.loadGraphic(bg);
	AlbumCover.visible = bg != null;
	//trace(120/AlbumCover.width+" 	"+90/AlbumCover.height);
	var scale = 200/(AlbumCover.width>AlbumCover.height?AlbumCover.width:AlbumCover.height);
	AlbumCover.scale.set(scale,scale);
	AlbumCover.updateHitbox();
	//AlbumCover.width = 120;
	//AlbumCover.height = 90;
	modInfoText.text = freeAction[Std.int(curAction)][0][0].name;
	if (Simpy)
		SetText();
	else
		tweenText();
	
}
function tweenText() {
	if (diffAction == null)
		for (i in 0...freeAction.length)
			FlxTween.tween(freeAction[i][1], {y: 350 + (i - curAction) * 100, x: 150 + (i - curAction) * 20, alpha: 1 - (Math.abs(Std.int(curAction) - i) / 4)},
				0.2, {ease: FlxEase.circOut});
	else {
		for (i in 0...freeAction.length)
			FlxTween.tween(freeAction[i][1], {y: 350 + (i - curAction) * 100, x: 400-38*freeAction[Std.int(curAction)][1].text.length -Math.abs(i - curAction) * 30, alpha: 1 - (Math.abs(Std.int(curAction) - i) / 4)},
				0.2, {ease: FlxEase.circOut});
		for (i in 0...diffAction.length)
			FlxTween.tween(diffAction[i],
				{y: 350 + (i - curDiffAction) * 100, x: 550 + (i - curDiffAction) * 20, alpha: 1 - (Math.abs(Std.int(curDiffAction) - i) / 4)}, 0.2,
				{ease: FlxEase.circOut});
	}
}
function SetText() {
	if (diffAction == null)
		for (i in 0...freeAction.length){
			freeAction[i][1].y = 350 + (i - curAction) * 100;
			freeAction[i][1].x = 150 + (i - curAction) * 20;
			freeAction[i][1].alpha = 1 - (Math.abs(Std.int(curAction) - i) / 4);
		}
	else {
		for (i in 0...freeAction.length){
			freeAction[i][1].y = 350 + (i - curAction) * 100;
			freeAction[i][1].x = 400-38*freeAction[Std.int(curAction)][1].text.length -Math.abs(i - curAction) * 30;
			freeAction[i][1].alpha = 1 - (Math.abs(Std.int(curAction) - i) / 4);
		}
		for (i in 0...diffAction.length){
			diffAction[i].y = 350 + (i - curDiffAction) * 100;
			diffAction[i].x = 550 + (i - curDiffAction) * 20;
			diffAction[i].alpha = 1 - (Math.abs(Std.int(curDiffAction) - i) / 4);
		}
	}
	
}
function onUpdate(e) {
	if (!isAllowed)
		return;
	game.inst.pause();
	game.vocals	.pause();
	timer -= e;
	if (timer > 0) {
		return;
	}
	if (timer%(1000/limitD)<e){
		if (FlxG.random.bool(limitD-glitchAr.length/limitD)&&glitchAr.length>0){
			//debugPrint("coc");
			var b = glitchAr[FlxG.random.int(0,glitchAr.length-	1)];
			b.alpha = b.alpha -FlxG.random.float(0.001,0.025);
			//debugPrint(b.alpha);
			if (b.alpha<0.05*100/limitD)
				glitchAr.remove(b);
			if (glitchAr.length==0&&limitD>50){
				var r = FlxG.random.int(0,freeAction.length-1);
				PlayState.SONG.song = freeAction[r][2].name;//song name
				//PlayState.SONG.format = freeAction[r][0][0].name +"^"+ freeAction[r][0][1].dificulties[0].text;// mod name + dificult
				PlayState.SONG.format = freeAction[r][0][0].name +"^";// no different
				MusicBeatState.resetState();

			}
		}
	}

	if (Control.BACK||butArray[0]?.justPressed) {
		if (diffAction != null) {
			
			playSnd("splat");
			for (diff in diffAction) {
				diff.destroy();
			}
			for (b in butArray){
				b.x-=400;
			}
			diffAction = null;
			curDiffAction = 0;
			updateText();

			inst.fadeOut(2, 1);
			freePlay.fadeOut(1, 0);
			FlxG.sound.list.remove(freePlay);
		} else {
			//CustomSubstate.closeCustomSubstate();
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
		pressAccept();
		updateText();
	}
	if (Control.UI_UP) {
		if (diffAction == null)
			curAction -= 1;
		else
			curDiffAction -= 1;
		timer = 0.12;
		updateText();
		playSnd("bump");
	}
	if (Control.UI_DOWN) {
		if (diffAction == null)
			curAction += 1;
		else
			curDiffAction += 1;
		timer = 0.12;
		updateText();
		playSnd("bump");
	}
	if (FlxG.mouse.wheel != 0){
		if (diffAction == null)
			curAction -= FlxG.mouse.wheel;
		else
			curDiffAction -= FlxG.mouse.wheel;
		//timer = 0.04;
		updateText(true);
		playSnd("bump");
	}
	if (Control.NOTE_RIGHT){
		resetSong();
		timer = 0.05;
		playSnd("crowd_cheer_single");
	}

	songScoreText.text = formatIntToString(Std.int(MathUtil.smoothLerp(Std.int(songScoreText.text),targetScore,e,0.5)), 6);
	
}

function getTmpScore() {
	var path = freeAction[Std.int(curAction)][2].name + freeAction[Std.int(curAction)][0][0].name + freeAction[Std.int(curAction)][0][1].dificulties[curDiffAction].name;
	// debugPrint(Highscore.songScores.exists(path));
	//debugPrint(path);
	if (Highscore.songScores.exists(path))
		return Highscore.songScores.get(path);
	return 0;
}

function resetSong(?path) {
	if (path == null ) path =freeAction[Std.int(curAction)][2].name + freeAction[Std.int(curAction)][0][0].name + freeAction[Std.int(curAction)][0][1].dificulties[curDiffAction].name;
	//debugPrint(path);
	Highscore.setScore(path,0);
	Highscore.setRating(path,0);
}

function onDestroy() {
	 //FlxTimer.start(2,(tim)->{inst.stop();});
	 inst.stop();
	// ();
}
