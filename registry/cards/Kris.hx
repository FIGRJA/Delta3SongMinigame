//package registry.cards;
import mikolka.vslice.freeplay.DifficultySprite;
import mikolka.compatibility.freeplay.FreeplaySongData;
import mikolka.compatibility.freeplay.FreeplayHelpers;
import backend.StageData;
import backend.Highscore;
import backend.Song;
import backend.Mods;
import states.LoadingState;
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

function findERS(result,path,i) {
	if (NativeFileSystem.isDirectory(path + "/SongCharts")){
		var dir = NativeFileSystem.readDirectory(path + "/SongCharts/");
		var ok = false;
		var s = '{
			"dificulties":[
				{
					"name":"play ERS",
					"prefix":"music_timing_customsong",
					"postfix":".txt",
					"dir":"SongCharts/"
				}
			],
			"songs":[';
		for (n in dir){
			if (n.indexOf("music_timing_customsong_info")==0){
				if (ok) s = s + ",";
				ok = true;
				var data:Array<String> = File.getContent(path + "/SongCharts/"+n).split("\n");
				s = s+'{\n';
				s = s+'	"name":"'+data[9]+'",\n';
				s = s+'	"nameFile":"",\n';
				s = s+'	"bpm":'+data[3]+',\n';
				s = s+'	"speed":'+data[4]+',\n';
				s = s+'	"songMain":"'+data[0].split(".")[0].split("CUSTOM_SONGS").join("").split("/").join("").split("\\").join("")+'",\n';
				s = s+'	"songPlay":"'+data[1].split(".")[0].split("CUSTOM_SONGS").join("").split("/").join("").split("\\").join("")+'",\n';
				s = s+'	"prewCh":"'+data[6].split(".")[0].split("CUSTOM_SONGS").join("").split("/").join("").split("\\").join("")+'",\n';
				s = s+'	"prew":"'+data[7].split(".")[0].split("CUSTOM_SONGS").join("").split("/").join("").split("\\").join("")+'",\n';
				s = s+'	"album":'+data[11]+',\n';
				s = s+'	"index":"'+n.split("customsong_info")[1].split(".")[0]+'",\n';
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
var songs = [];
function init() {
    var data = new FreeplaySongData(0, "tutorialus    (infinity)", "bf", FlxColor.fromRGB(0, 0, 0));
    data.songDifficulties = ["play"];
    data.isNew = true;
    Reflect.setField(data,"currentDifficulty","play");//это пиздец...
    var External = {
        "diff" : data.currentDifficulty,
        "rank" : data.scoringRank
    };

    songs.push([data,External]);
}

var isUpdatad = false;
function introDone() {
    if(isUpdatad) return;
    for (data in songs){
        backingCard.instance.songs.push(data[0]);
    }
    backingCard.instance.diffIdsTotal = ["play ERS","play NEO","play"];
    for (diffId in backingCard.instance.diffIdsTotal)
		{
			//ModsHelper.loadModDir(diffIdsTotalModBinds.get(diffId));
			var diffSprite:DifficultySprite = new DifficultySprite(diffId);
			diffSprite.difficultyId = diffId;
			backingCard.instance.grpDifficulties.add(diffSprite);
		}
    backingCard.instance.changeSelection(0,true);
    backingCard.instance.changeDiff(0,true);
    isUpdatad = true;
    
}
function onUpdate() {
    if (!isUpdatad) return;
    var updateDiffs = false;
    for (data in songs){
        if (data[0].currentDifficulty != data[1].diff){
            updateDiffs = true;
            Reflect.setField(data[0],"currentDifficulty", data[1].diff);
            data[0].songDifficulties = [data[1].diff];
            data[0].scoringRank = data[1].rank;
        }
    }
    if (updateDiffs){
        trace("иди нах");
        //backingCard.instance.changeDiff(0,true);
    }
    
}
FlxG.signals.postUpdate.add(onUpdate);
function confirm() {
    var level = backingCard.instance.curCapsule;
    backingCard.instance.styleData = {"getStartDelay":()->{return 2000;}};
    new FlxTimer().start(0.1, function(tmr:FlxTimer)
		{
            try{
                //freeplay sheat
                backingCard.instance.persistentUpdate = false;
		        Mods.currentModDirectory = "Delta3SongMinigame";
                var songLowercase:String = Paths.formatToSongPath("loadCharts");
		        var poop:String = Highscore.formatSong(songLowercase, 1);
                //trace(poop);
                PlayState.SONG = Song.loadFromJson(poop, songLowercase);
                if(PlayState.SONG == null) throw "Song parsing failed!";
                PlayState.isStoryMode = false;
                PlayState.storyDifficulty = 0;
                var directory = StageData.forceNextDirectory;
                LoadingState.loadNextDirectory();
                StageData.forceNextDirectory = directory;
                LoadingState.loadAndSwitchState(new PlayState(), true);
			    //new FreeplayHelpers().moveToPlaystate(st, data, "",null);
                PlayState.SONG.song = level.songData.songId;//song name
                PlayState.SONG.format = level.songData.levelName +"^"+ level.songData.currentDifficulty;// mod name + dificult
                trace(PlayState.SONG.song);
                trace(PlayState.SONG.format);
            }catch(e:Dynamic){trace(e);}
		});
    
}
function applyExitMovers(a,b){
    if (isUpdatad)
        destroy();
}
function destroy() {
    
FlxG.signals.postUpdate.remove(onUpdate);
}