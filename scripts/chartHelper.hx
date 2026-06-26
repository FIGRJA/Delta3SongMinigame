//package scripts; //эбанный vs

import flixel.FlxG;
import backend.CacheSystem;
import Type;
import backend.Mods;
import mikolka.funkin.custom.NativeFileSystem as NativeFileSystem;
import states.editors.ChartingState;

function setVF(Var,Fun) {
	if (getVar(Var).exists(Fun))
		this.set(Fun,getVar(Var).get(Fun));
	
}

//var songI ;
//var songV ;
var unspawnNotes ;
var statusLoad = [true,true,true];

function writeNoteToSong() {
	trace("start write");
    if (PlayState.SONG.format == "psych_v1_convert") return;
	//PlayState.SONG.notes[0].sectionNotes = [];
	//PlayState.SONG.notes[0].bpm = PlayState.SONG.bpm;
	//var emty = 
    PlayState.SONG.notes = [];
	//trace(emty);
	//var notes:Int = 0;
	var section:Int = 1 / PlayState.SONG.bpm * 60 * 1000 * 4;
    for (i in 0...Math.round((FlxG.state.maxTime / section) + 0.5))
        PlayState.SONG.notes[i] = {
            sectionNotes: [],
            bpm: PlayState.SONG.bpm,
            mustHitSection: true,
            gfSection: false,
            altAnim: false,
            changeBPM: false,
            sectionBeats: 4
        };
	for (i in 0...unspawnNotes.length) {
		var note = unspawnNotes[i];
        //trace(Math.round((note.strumTime / section)));
		if (note.isSustainNote)
			continue;
		var simpleNote:Arry<Dynamic> = [0.0, 0, 0.0];
		simpleNote[0] = note.strumTime;
		simpleNote[1] = note.noteData + (note.noteType == "vocal" ? 3+((statusLoad[1]?3:0)) : 0) + (note.noteType == "drum" ? 3 : 0);
		simpleNote[2] = note.sustainLength;
		simpleNote[3] = note.animSuffix == "-alt" ? "Alt Animation" : null;
        //trace(simpleNote+note.noteType);

		//if (PlayState.SONG.notes[Math.round((note.strumTime / section) + 0.5)]==null)
		//	PlayState.SONG.notes.push(emty);
		if (PlayState.SONG.notes[Math.round((note.strumTime / section))]==null) {
			PlayState.SONG.notes[Math.round((note.strumTime / section))] = {
                sectionNotes: [],
                bpm: PlayState.SONG.bpm,
                mustHitSection: true,
                gfSection: false,
                altAnim: false,
                changeBPM: false,
                sectionBeats: 4
            };
		}
		PlayState.SONG.notes[Math.round((note.strumTime / section))].sectionNotes.push(simpleNote);
		//notes++;
	}
    //trace(PlayState.SONG.notes);
    //trace(PlayState.SONG.notes.length);
	//trace("end write");
}

function onCreatePost() {
//setVF("load_delta_notes","writeNoteToSong");
    //songI = getVar("SONG").songMain;
    //songV = getVar("SONG").songPlay;
    unspawnNotes = game.unspawnNotes.copy();
    //PlayState.SONG.notes = [];
    ChartingState.GRID_PLAYERS = 2;
    ChartingState.GRID_COLUMNS_PER_PLAYER = 4;
    this.set("Reflect",Type.resolveClass("Reflect"));
    if ( getVar("statusLoad")!=null)
        statusLoad = getVar("statusLoad");

        //writeNoteToSong();
   // this.fixScriptName("chartHelper");
    //debugPrint(Std.int(statusLoad[0])+Std.int(statusLoad[1])+Std.int(statusLoad[2]));
}

function getSong(song) {

	for (i in Mods.getModDirectories()){
        var path = "mods/"+i+"/";
        if (NativeFileSystem.exists(path+song))
            return path+song;
    }
    
}
var songEx = false;
var Helper ;
var icons = ["kris","susi","ralsei"];
var section = 0;
Helper = ()->{
    try{
        //trace("hi");
        setVar("chartHelper",Helper);

        ChartingState.GRID_PLAYERS = Std.int(statusLoad[0])+Std.int(statusLoad[1])+Std.int(statusLoad[2]);
        ChartingState.GRID_COLUMNS_PER_PLAYER = Math.max((statusLoad[0]?2:0),Math.max((statusLoad[1]?3:0),(statusLoad[2]?3:0)));
        if (Type.getClassName(Type.getClass(FlxG.state))=="states.editors.ChartingState"){
            if (FlxG.sound.music.length<1000){
                var state =  FlxG.state;
                //trace(getSong("mus/"+songI+".ogg"));
                FlxG.sound.music.loadEmbedded(CacheSystem.loadSound(getSong("mus/"+PlayState.SONG.gameOverLoop+".ogg"),true,"nice Try"));
                state.maxTime = FlxG.sound.music.length;
			    state.prevEndInput.max = FlxMath.roundDecimal(state.maxTime/1000,2);
                state._cacheSections();
                //if (!songEx){
                writeNoteToSong();
                    //songEx = true;
                //}
                //trace("h3");
                state.vocals.loadEmbedded(CacheSystem.loadSound(getSong("mus/"+PlayState.SONG.gameOverEnd+".ogg"),true,"nice Try"));
                state.updateAudioVolume();
                state.setPitch();
            
                // ВАЖНО: Перезагружаем ноты в UI//deepseak
                state.reloadNotes();
                state.loadSection();
                state.updateGridVisibility();
                state.waveformSprite.x = state.gridBg.x - ChartingState.GRID_SIZE*ChartingState.GRID_COLUMNS_PER_PLAYER;
                //trace(ChartingState.GRID_PLAYERS);
                var i = 0;
                for (m in 0...3){
                    if (!statusLoad[m]) continue;
                    state.icons[i].changeIcon(icons[m]);
                    Reflect.setProperty(state.characterData,'iconP'+(i+1),icons[m]);
                    state.icons[i].scale.set(2,2);
                    state.icons[i].updateHitbox();
                    state.icons[i].antialiasing=false;
                    i += 1;
                }
                //FlxG.sound.play();
            }
            if (FlxG.state.curSec!=section){
                section = FlxG.state.curSec;
                FlxG.state.waveformSprite.x = FlxG.state.gridBg.x - ChartingState.GRID_SIZE*ChartingState.GRID_COLUMNS_PER_PLAYER;
                for (i in 0...ChartingState.GRID_PLAYERS){
                    //FlxG.state.icons[i].changeIcon(icons[i]);
                    FlxG.state.icons[i].antialiasing=false;
                }
            }
        }
        try{
            if (PlayState.SONG.stage!="D3Main"){
                FlxG.signals.preUpdate.remove(Helper);
                ChartingState.GRID_PLAYERS = 2;
                ChartingState.GRID_COLUMNS_PER_PLAYER = 4;
            }
        }catch (e:Dynamic){}
    }catch (e:Dynamic) {trace(e);FlxG.signals.preUpdate.remove(Helper);}
}

var ema = 0;
function onUpdate(e) {
    ema += e;
    if (ema>(e*10)&&ema<(e*12)){
        songEx = false;
        if (getVar("chartHelper")==null){
            if (game.songName!="songchart"){
                trace("added");
                FlxG.signals.preUpdate.add(Helper);
            }
        }else{
            if (game.songName=="songchart"){
                trace("removed");
                FlxG.signals.preUpdate.remove(getVar("chartHelper"));
                setVar("chartHelper",null);
            }
            
        }
        //trace(game.songName);
        ema += e;
    }
}
function onDestroy() {
    if (getVar("chartHelper")!=null) return;
    ChartingState.GRID_PLAYERS = 2;
    ChartingState.GRID_COLUMNS_PER_PLAYER = 4;
}
