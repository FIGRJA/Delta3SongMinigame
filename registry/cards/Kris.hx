//package registry.cards;
import mikolka.vslice.freeplay.DifficultySprite;
import mikolka.compatibility.freeplay.FreeplaySongData;
import mikolka.compatibility.freeplay.FreeplayHelpers;
import mikolka.vslice.freeplay.pslice.BPMCache;
import mikolka.funkin.custom.NativeFileSystem as NativeFileSystem;
import mikolka.stages.cutscenes.dialogueBox.DialogueBoxPsych; // import haxe.Json;
import backend.CacheSystem;
import backend.StageData;
import backend.Highscore;
import backend.Song;
import backend.Mods;
import states.LoadingState;
import tjson.TJSON;
import Reflect;


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

var songs = [];
var ExMap:Map = [""=>""];
var GlobalID = 0;

function GenCapsule(SongData){
	trace(SongData);
    var data = new FreeplaySongData(GlobalID, SongData.SongName, "gf", FlxColor.fromRGB(0, 0, 0));
    GlobalID += 1;
    data.songDifficulties = SongData.diffs;
    data.songWeekName = SongData.modName;
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
        "prewA" : SongData.prewA ?? SongData.songPlay,
        "prewB" : SongData.prewB ?? SongData.songMain
    };
    ExMap.set(SongData.SongName,External);
    songs.push([data,External]);
}

function findERS(path,modName) {
	if (NativeFileSystem.isDirectory(path + "/SongCharts")){
		var dir = NativeFileSystem.readDirectory(path + "/SongCharts/");
		for (n in dir){
			if (n.indexOf("music_timing_customsong_info")==0){
				//if (ok) s = s + ",";
				//ok = true;
				var data:Array<String> = File.getContent(path + "/SongCharts/"+n).split("\n");
				GenCapsule({
						"SongName":data[9],
						"diffs":['play ERS'],
						"modName":modName,
						"modDir":path.split("/")[1],
						"bpm":data[3],
						"songMain":data[0].split(".")[0].split("CUSTOM_SONGS").join("").split("/").join("").split("\\").join(""),
						"songPlay":data[1].split(".")[0].split("CUSTOM_SONGS").join("").split("/").join("").split("\\").join(""),
						"prewB":data[6].split(".")[0].split("CUSTOM_SONGS").join("").split("/").join("").split("\\").join(""),
						"prewA":data[7].split(".")[0].split("CUSTOM_SONGS").join("").split("/").join("").split("\\").join("")
					});
			}
		}
	}
}

function findNEO(path,modName) {
	//var s = "";
	//var IsE = false; 
	//var h = ()->{
	//	if (!IsE){
	//		s = '{
	//			"dificulties":[
	//				{
	//					"name":"play NEO",
	//					"prefix":"",
	//					"postfix":"",
	//					"dir":""
	//				}
	//			],
	//			"songs":[';
	//		IsE = true;
	//	}
	//}
	for (n in NativeFileSystem.readDirectory(path)){
		if (n.indexOf(".neo")>0){
			//if (IsE) s = s + ",";
			//	
			//h();
			var data = readNEOHead(path+"/"+n);
			GenCapsule({
					"SongName":n.split(".neo").join(""),
					"diffs":['play NEO'],
					"modName":modName,
					"modDir":path.split("/")[1],
					"bpm":data.BPM,
					"songMain":data.Music_file_no_guitar.split(".")[0],
					"songPlay":data.Music_file.split(".")[0],
					"prewB":data.Menu_preview.split(".")[0],
					"prewA":data.Menu_preview.split(".")[0]
				});
			//debugPrint(data);
			//s = s+'{';
			//s = s+'	"name":"'+n.split(".neo").join("")+'",';
			//s = s+'	"nameFile":"'+n+'",';
			//s = s+'	"bpm":'+data.BPM+',';
			//s = s+'	"speed":'+data.Note_speed+',';
			//s = s+'	"songMain":"'+data.Music_file_no_guitar.split(".")[0]+'",';
			//s = s+'	"songPlay":"'+data.Music_file.split(".")[0]+'",';
			//s = s+'	"prewCh":"'+data.Menu_preview.split(".")[0]+'",';
			//s = s+'	"prew":"'+data.Menu_preview.split(".")[0]+'",';
			//s = s+'	"album":'+data.Album+',';
			//s = s+'	"index":"",';
			//s = s+'	"hxModule":null,';
			//s = s+'	"dynamic_solo":false';
			//s = s+'}';
		}
	}
	//if (IsE){
	//	s = s + "]}";
	//	var list = TJSON.parse(s);
	//	//debugPrint(list);
	//	var pack = TJSON.parse('{"name":"'+i+'"}');
	//	result.push([pack, list,i]);
	//}
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

	Mods.updateModList();
	var list = Mods.parseList();
    var modName = "";
	//for (i in Mods.getModDirectories()) {
	for (i in list.enabled) {
		var path = "mods/" + i;
		if (NativeFileSystem.exists(path + "/pack.json"))
			modName = DialogueBoxPsych.parseDialogue(path + "/pack.json").name; // dymmy haxe.Json
		else
			modName = i;
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
		//findMIDI(result,path,i);
		
	}
}
var isUpdatad = false;
var testet = 0;
var lastcursong = -1;
var FreePlayState ;
function init() {
    loadSongsLists();
}

function introDone() {
    if(isUpdatad) return;
    FreePlayState = backingCard.instance;
    for (data in songs){
        FreePlayState.songs.push(data[0]);
    }
    FreePlayState.diffIdsTotal = ["play ERS","play NEO","play"];
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

    if (lastcursong != FreePlayState.curSelected&&FreePlayState.curCapsule.songData!=null){
        lastcursong = FreePlayState.curSelected;
		var curSong = ExMap.get(FreePlayState.curCapsule.songData.songId);
		var song = "mods/"+curSong.modDir+"/mus/"+(getTmpScore(curSong)>0?curSong.prewA:curSong.prewB)+".ogg";
		FreePlayState.intendedScore = getTmpScore(curSong);
		FreePlayState.intendedCompletion = getTmpRating(curSong);
        //trace(song);
		FlxG.sound.music.loadEmbedded(CacheSystem.loadSound(song,true,Paths.formatToSongPath(curSong.SongName)+'/Inst, PATH: mus'), true);
		FlxG.sound.music.play();
    }
    
}

function getTmpScore(ex) {
	var path = ex.SongName + ex.modName + ex.diff;
	if (Highscore.songScores.exists(path))
		return Highscore.songScores.get(path);
	return 0;
}
function getTmpRating(ex) {
	var path = ex.SongName + ex.modName + ex.diff;
	if (Highscore.songRating.exists(path))
		return Highscore.songRating.get(path);
	return 0;
}
function confirm() {
    var level = FreePlayState.curCapsule;
    FreePlayState.styleData = {"getStartDelay":()->{return 2000;}};
    new FlxTimer().start(0.1, function(tmr:FlxTimer)
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
                PlayState.SONG.format = level.songData.songWeekName +"^"+ level.songData.currentDifficulty;// mod name + dificult
                trace(PlayState.SONG.song);
                trace(PlayState.SONG.format);
            }catch(e:Dynamic){trace(e);}
		});
    
}


function onCreate(){
    FlxG.signals.postUpdate.add(onUpdate);
}
function applyExitMovers(a,b){
    //maybe soon 
    if (isUpdatad)
        destroy();
}
function destroy() {
    
FlxG.signals.postUpdate.remove(onUpdate);
}