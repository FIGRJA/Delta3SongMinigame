//package registry.cards;
import mikolka.vslice.freeplay.DifficultySprite;
import mikolka.compatibility.freeplay.FreeplaySongData;
import mikolka.compatibility.freeplay.FreeplayHelpers;
import mikolka.vslice.freeplay.pslice.BPMCache;
import mikolka.vslice.freeplay.FreeplayState;
import mikolka.funkin.custom.NativeFileSystem as NativeFileSystem;
import mikolka.funkin.sound.FlxPartialSound;
import mikolka.stages.cutscenes.dialogueBox.DialogueBoxPsych; // import haxe.Json;
import backend.CacheSystem;
import backend.StageData;
import backend.Highscore;
import backend.Song;
import backend.Mods;
import backend.Paths;
import states.LoadingState;
import tjson.TJSON;
import Reflect;

var songs = [];
var ExMap:Map = [""=>""];



function GenCapsule(SongData){
	//trace(SongData);
    var data = new FreeplaySongData(0, SongData.SongName, "dad", FlxColor.fromRGB(0, 0, 0));
    data.songDifficulties = SongData.diffs;
    data.songWeekName = SongData.modName;
	try{
    	Reflect.setProperty(data,"set_currentDifficulty",trace);//это пиздец...
		//data.set_currentDifficulty = (v)->{trace(v);};
	}catch(e:Dynamic){trace("you fall");}
    //data.isNew = true;
    Reflect.setField(data,"currentDifficulty",SongData.diffs[0]);//это пиздец...
	BPMCache.instance.bpmMap.set("assets/shared/data/"+Paths.formatToSongPath(SongData.SongName),SongData.bpm);
    var External = {
		"SongName":SongData.SongName,
		"modName":SongData.modName,
		"modDir":SongData.modDir,
        "diff" : data.currentDifficulty,
        "diffs" : data.songDifficulties,
        "rank" : data.scoringRank,
        "album" : SongData.album,
        "prewA" : SongData.prewA ?? SongData.songPlay,
        "prewB" : SongData.prewB ?? SongData.songMain
    };
    ExMap.set(SongData.SongName,External);
    songs.push([data,External]);
}

function findERS(path,modName) {
	if (NativeFileSystem.isDirectory(path + "/SongCharts")){
		var dir = NativeFileSystem.readDirectory(path + "/SongCharts/");
		var diffs = ['play ERS'];
		for (n in dir){
			if (n.indexOf("_hard")>0){
			diffs = ['play ERS','Hard ERS'];
			}
		}
		for (n in dir){
			if (n.indexOf("music_timing_customsong_info")==0){
				//if (ok) s = s + ",";
				//ok = true;
				var data:Array<String> = File.getContent(path + "/SongCharts/"+n).split("\n");
				GenCapsule({
						"SongName":data[9],
						"diffs":diffs,
						"modName":modName,
						"modDir":path.split("/")[1],
						"bpm":data[3],
						"album":data[11],
						"songMain":data[0].split(".")[0].split("CUSTOM_SONGS").join("").split("/").join("").split("\\").join(""),
						"songPlay":data[1].split(".")[0].split("CUSTOM_SONGS").join("").split("/").join("").split("\\").join(""),
						"prewB":data[6].split(".")[0].split("CUSTOM_SONGS").join("").split("/").join("").split("\\").join(""),
						"prewA":data[7].split(".")[0].split("CUSTOM_SONGS").join("").split("/").join("").split("\\").join("")
					});
			}
		}
	}
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

function findNEO(path,modName) {
	for (n in NativeFileSystem.readDirectory(path)){
		if (n.indexOf(".neo")>0){
			var data = readNEOHead(path+"/"+n);
			GenCapsule({
				"SongName":n.split(".neo").join(""),
				"diffs":['play NEO'],
				"modName":modName,
				"modDir":path.split("/")[1],
				"bpm":data.BPM,
				"album":data.Album,
				"songMain":data.Music_file_no_guitar.split(".")[0],
				"songPlay":data.Music_file.split(".")[0],
				"prewB":data.Menu_preview.split(".")[0],
				"prewA":data.Menu_preview.split(".")[0]
			});
		}
	}
}
function findMIDI(path,modName) {
	for (n in NativeFileSystem.readDirectory(path)){
		if (n.indexOf(".mid")>0&&NativeFileSystem.exists(path+"/mus/"+n.split(".mid").join("")+".ogg")){
			GenCapsule({
				"SongName":n.split(".mid").join(""),
				"diffs":['play MIDI'],
				"modName":modName,
				"modDir":path.split("/")[1],
				"bpm":0,
				"album":"../"+n.split(".mid").join(""),
				"songMain":n.split(".mid").join(""),
				"songPlay":n.split(".mid").join(""),
				"prewB":null,
				"prewA":null
			});
		}
	}
}

function loadSongsLists() {

	Mods.updateModList();
	var list = Mods.parseList();
    var modName = "";
	//for (i in Mods.getModDirectories()) {
	for (i in list.enabled) {
		var path = "mods/" + i;
		try{
			if (NativeFileSystem.exists(path + "/pack.json"))
				modName = DialogueBoxPsych.parseDialogue(path + "/pack.json").name; // dymmy haxe.Json
			else
				modName = i;
		}catch(e:Dynamic){modName = i;}//mobile ...
		if (NativeFileSystem.exists(path + "/songList.json") ) {
			// debugPrint(path);&& 
			try {
				var list = DialogueBoxPsych.parseDialogue(path + "/songList.json"); // dymmy haxe.Json
				
                var diffs = [];
                for (diff in list.dificulties){
                    diffs.push(diff.name);
                }
                for (song in list.songs){

                    GenCapsule({
						"SongName":song.name,
						"diffs":diffs,
						"modName":modName,
						"modDir":i,
						"bpm":song.bpm,
						"album":song.album,
						"songMain":song.songMain,
						"songPlay":song.songPlay,
						"prewB":song.prewCh,
						"prewA":song.prew
					});
                }
			} catch (e:Dynamic) {
				debugPrint(e, FlxColor.BLACK);
			}
		}
		findERS(path,modName);
		findNEO(path,modName);
		findMIDI(path,modName);
		
	}
}
var isUpdatad = false;
var testet = 1;
var lastcursong = -1;
var FreePlayState ;
function init() {
    loadSongsLists();
	//FreePlayState = FlxG.state.subState;
	//introDone();
}

function introDone() {
    if(isUpdatad) return;
    FreePlayState = backingCard.instance;
	var diffs = [];
    for (data in songs){
        FreePlayState.songs.push(data[0]);
		for (i in data[1].diffs)
			if (!diffs.contains(i))
				diffs.push(i);
    }
    FreePlayState.diffIdsTotal = diffs;
    for (diffId in FreePlayState.diffIdsTotal)
		{
			//ModsHelper.loadModDir(diffIdsTotalModBinds.get(diffId));
			var diffSprite:DifficultySprite = new DifficultySprite(diffId);
			diffSprite.difficultyId = diffId;
			FreePlayState.grpDifficulties.add(diffSprite);
		}
    FreePlayState.changeSelection(0,true);
    FreePlayState.changeDiff(0,true);
    isUpdatad = true;
}
function onUpdate() {
    if (!isUpdatad) return;
    var updateDiffs = false;
    for (data in songs){
        if (data[0].currentDifficulty != data[1].diff){
            updateDiffs = true;
            Reflect.setField(data[0],"currentDifficulty", data[1].diff);
            data[0].songDifficulties = data[1].diffs;
            data[0].scoringRank = data[1].rank;
            data[0].difficultyRating = testet;
            //data[0].songStartingBpm = data[1].bpm;// BPMCache.bpmMap.set("assets/shared/data/name",bpm)
        }
    }
    if (updateDiffs){
        trace("иди нах");
        //testet +=1;
		//FreePlayState.changeDiff(0,true);
    }

    if ((lastcursong != FreePlayState.curSelected||updateDiffs)&&FreePlayState.curCapsule.songData!=null){
        lastcursong = FreePlayState.curSelected;
		var curSong = ExMap.get(FreePlayState.curCapsule.songData.songId);
		var song = "mods/"+curSong.modDir+"/mus/"+(getTmpScore()>0?curSong.prewA:curSong.prewB)+".ogg";
		FreePlayState.intendedScore = getTmpScore();
		FreePlayState.intendedCompletion = getTmpRating();
		FreePlayState.ostName.text = curSong.modDir;
        //trace(song);
		playPrew(song);
		//FlxG.sound.music.loadEmbedded(CacheSystem.loadSound(song,true,Paths.formatToSongPath(curSong.SongName)+'/Inst, PATH: mus'), true);
		//FlxG.sound.music.play();
		if (curSong.album!=null){
			var BG = getAlbumCover(curSong.modDir,curSong.album);
			if (BG!=null){
				AlbumCover = FreePlayState.albumRoll.newAlbumArt;
				AlbumCover.replaceFrameGraphic(0,BG );
				AlbumCover.antialiasing = false;
				//AlbumCover.loadGraphic(BG );
				//AlbumCover.angle = 10;
				//AlbumCover.offset.set(-60,-110);
				var scale = 280/(AlbumCover.width>AlbumCover.height?AlbumCover.width:AlbumCover.height);
				//AlbumCover.scale.set(scale,scale);
				FreePlayState.albumRoll.visible = true;
				FreePlayState.albumRoll.albumTitle.visible = false;
				//FreePlayState.albumRoll.applyExitMovers();
				//FreePlayState.albumRoll.refresh();
			}
		}else{
			//
		}
    }
    
}

function getTmpScore() {
		var ex = ExMap.get(FreePlayState.curCapsule.songData.songId);
	var path = ex.SongName + ex.modName + FreePlayState.currentDifficulty;
	if (Highscore.songScores.exists(path))
		return Highscore.songScores.get(path);
	return 0;
}
function getTmpRating() {
		var ex = ExMap.get(FreePlayState.curCapsule.songData.songId);
	var path = ex.SongName + ex.modName + FreePlayState.currentDifficulty;
	if (Highscore.songRating.exists(path))
		return Highscore.songRating.get(path);
	return 0;
}
function playPrew(path) {
	var future = FlxPartialSound.partialLoadFromFile(path,0,1);
	if(future == null){
		trace('Internal failure loading instrumentals for"');
		return false;
	}
	future.future.onComplete(function(sound:Sound)
		{
			//@:privateAccess{
				//if(!Std.isOfType(FlxG.state.subState,FreeplayState)) return;
				var fp = FreePlayState;

				var cap = fp.grpCapsules.activeSongItems[fp.curSelected];
				if(cap.songData == null  || fp.busy) return;
			//}
			
			trace("Playing preview!");
			FlxG.sound.playMusic(sound,0);
			// #if (lime_vorbis && linux)
			// prevSound?.close();
			// prevSound = sound;
			// #end
			FlxG.sound.music.fadeIn(FreePlayState.FADE_IN_DURATION, FreePlayState.FADE_IN_START_VOLUME, FreePlayState.endVolume);
		});
}
function getAlbumCover(mod,cover) {
	return CacheSystem.loadBitmap("SongAlbums/"+cover+".png",mod,false);
}

function confirm() {
    var level = FreePlayState.curCapsule;
    FreePlayState.styleData = {"getStartDelay":()->{return 2000;}};
    new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
            try{
                //freeplay sheat
                FreePlayState.persistentUpdate = false;
		        Mods.currentModDirectory = "Delta3SongMinigame";
                var songLowercase:String = Paths.formatToSongPath("loadCharts");
		        var poop:String = Highscore.formatSong(songLowercase, 1);
                //trace(poop);
                PlayState.SONG = Song.loadFromJson(poop, songLowercase);
                if(PlayState.SONG == null) throw "Song parsing failed!";
                PlayState.isStoryMode = false;
                PlayState.storyDifficulty = 0;
                //var directory = StageData.forceNextDirectory;
                //LoadingState.loadNextDirectory();
                //StageData.forceNextDirectory = directory;
                LoadingState.loadAndSwitchState(new PlayState(), true);
			    //new FreeplayHelpers().moveToPlaystate(st, data, "",null);
                PlayState.SONG.song = level.songData.songId;//song name
                PlayState.SONG.format = level.songData.songWeekName +"^"+ FreePlayState.currentDifficulty;// mod name + dificult
                trace(PlayState.SONG.song);
                trace(PlayState.SONG.format);
            }catch(e:Dynamic){trace(e);}
		});
    
}


function onCreate(){
    FlxG.signals.preUpdate.add(onUpdate);
}
function applyExitMovers(a,b){
    //maybe soon 
    if (isUpdatad)
        destroy();
}
function destroy() {
    
FlxG.signals.preUpdate.remove(onUpdate);
}