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

var songI ;
var songV ;
var unspawnNotes ;

function writeNoteToSong() {
	trace("start write");
	PlayState.SONG.notes[0].sectionNotes = [];
	PlayState.SONG.notes[0].bpm = PlayState.SONG.bpm;
	var emty = PlayState.SONG.notes[0];
	trace(emty);
	//var notes:Int = 0;
	var section:Int = 1 / PlayState.SONG.bpm * 60 * 1000 * 4;
    for (i in 0...1000)
        PlayState.SONG.notes.push(emty);
	for (i in 0...unspawnNotes.length) {
		var note = unspawnNotes[i];
        trace(Math.round((note.strumTime / section) - 0.5));
		if (note.isSustainNote)
			continue;
		var simpleNote:Arry<Dynamic> = [0.0, 0, 0.0];
		simpleNote[0] = note.strumTime;
		simpleNote[1] = note.noteData + (note.mustPress ? 4 : 0) + (note.noteType == "drum" ? 2 : 0);
		simpleNote[2] = note.sustainLength;
		//simpleNote[3] = note.animSuffix == "-alt" ? "Alt Animation" : null;
        trace(simpleNote);

		//if (PlayState.SONG.notes[Math.round((note.strumTime / section) + 0.5)]==null)
		//	PlayState.SONG.notes.push(emty);
		//if (PlayState.SONG.notes.length > Math.round((note.strumTime / section) + 1.5)) {
		//	PlayState.SONG.notes[Math.round((note.strumTime / section) + 0.5)] = emty;
		//}
		PlayState.SONG.notes[Math.round((note.strumTime / section) - 0.5)].sectionNotes.push(simpleNote);
		//notes++;
	}
    //trace(PlayState.SONG.notes);
    //trace(PlayState.SONG.notes.length);
	trace("end write");
}

function onCreatePost() {
//setVF("load_delta_notes","writeNoteToSong");
    songI = getVar("SONG").songMain;
    songV = getVar("SONG").songPlay;
    unspawnNotes = game.unspawnNotes;
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
Helper = ()->{
    try{
        //trace("hi");
        setVar("chartHelper",Helper);
        if (Type.getClassName(Type.getClass(FlxG.state))=="states.editors.ChartingState"){
            if (FlxG.sound.music.length<1000){
                var state =  FlxG.state;
                trace(getSong("mus/"+songI+".ogg"));
                if (!songEx){
                    writeNoteToSong();
                    //state.reloadNotes();
                    //state.destroy();
                    //trace("h1");
                    //FlxG.state = new ChartingState();
                    songEx = true;
                    //FlxG.resetState();
                    //state =  FlxG.state;
                    //trace("h2");
                    //state.create();
                }
                FlxG.sound.music.loadEmbedded(CacheSystem.loadSound(getSong("mus/"+songI+".ogg"),true,"nice Try"));
                state.maxTime = FlxG.sound.music.length;
			    state.prevEndInput.max = FlxMath.roundDecimal(state.maxTime/1000,2);
                //trace("h3");
                state.vocals.loadEmbedded(CacheSystem.loadSound(getSong("mus/"+songV+".ogg"),true,"nice Try"));
                state.updateAudioVolume();
                state.setPitch();
                state._cacheSections();

                for (secNum in 0...PlayState.SONG.notes.length){
                    var section = PlayState.SONG.notes[secNum];
                    for (note in section.sectionNotes)
                        if(note != null)
                            state.notes.push(state.createNote(note, secNum));}
                //FlxG.sound.play();
            }
        }
    }catch (e:Dynamic) {trace(e);FlxG.signals.preUpdate.remove(Helper);}
}

var ema = -1;
function onUpdate(e) {
    ema += e;
    if (ema>0&&ema<200){
        songEx = false;
        //writeNoteToSong();
        if (getVar("chartHelper")==null){
            if (game.songName!="songchart"){
                trace("added");
                FlxG.signals.preUpdate.add(Helper);
            }
        }else{
            if (game.songName=="songchart"){
                trace("removed");
                FlxG.signals.preUpdate.remove(getVar("chartHelper"));
            }
            
        }
        //trace(game.songName);
        ema = 1000;
    }
}

