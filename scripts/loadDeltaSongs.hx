if (PlayState.SONG.stage!="D3Main") return;
// import haxe.macro.Expr.Case;
import sys.thread.EventLoop.NextEventTime;
import psychlua.HScript;
import crowplexus.iris.Iris;
// import objects.Note.EventNote;
import psychlua.FunkinLua;
import mikolka.funkin.custom.NativeFileSystem as NativeFileSystem;

// import std.StringTools;

var curStepCrochet:Int;
var DeltaRuneCode:HScript;
var songTxt:FlxText;
var StausLoad = [true,true,true]; // lead,drums,vocal,lyric
function setVF(Var,Fun) {
	if (getVar(Var).exists(Fun))
		this.set(Fun,getVar(Var).get(Fun));
	
}
setVar("load_delta_notes", this);
function onCreate() {

	game.startHScriptsNamed('custom_events/' + "ill make lyric" + '.hx');
}

function loadSong(file:String, ?index:Dynamic, ?isFull:Bool = false) {
	PlayState.SONG.notes = [];
	PlayState.SONG.events = [];
	// PlayState.instance.clearNotesBefore(0);
	// PlayState.instance.setSongTime(0);
	//curStepCrochet = 60 / PlayState.SONG.bpm * 1000 / 4.0;
	curStepCrochet = 50;
	// var file:String = getVar("load_delta_notes");
	// var index = getVar("load_delta_notes_index");
	if (file != null) {
		if (file.lastIndexOf(".hx") == file.length - 3)
			loadHXNotes(file, index, isFull);
		else if (file.lastIndexOf(".txt") == file.length - 4)
			load_all_posible_notes_txt(file, index);
		else if (file.lastIndexOf(".neo") == file.length - 4)
			load_all_posible_notes_neo(file);
		else if (file.lastIndexOf(".mid") == file.length - 4)
			load_all_posible_notes_mid(file);

		game.unspawnNotes.sort(function(a, b) {
			return a.strumTime - b.strumTime;
		});

		// var foundBPM = findClapRals();
		// if (foundBPM>0){
		//	PlayState.SONG.bpm = foundBPM;
		//	Conductor.bpm = foundBPM;
		// }
		//var i:Int = 1;
		//while (i < game.unspawnNotes.length)
		//{
		//	var current = game.unspawnNotes[i];
		//	var previous = game.unspawnNotes[i - 1]; // Проверяем только предыдущую ноту
//
		//	if (current.noteData == previous.noteData && 
		//		current.noteType == previous.noteType && 
		//		current.strumTime == previous.strumTime&&
		//		current.tail.length==0&&!current.isSustainNote) 
		//	{
		//		current.destroy();
		//		game.unspawnNotes.splice(i, 1);
		//	} else {
		//		i+=1;
		//	}
		//	//trace("helpMe "+i+" "+game.unspawnNotes.length);
		//}
		///writeNoteToSong();
		// game.unspawnNotes = [];
		// PlayState.generateSong();
		debugPrint("loaded " + game.unspawnNotes.length + " notes");
		// debugPrint("created "+PlayState.SONG.notes[0].sectionNotes.length+" notes");
		//debugPrint(StausLoad);
		return StausLoad;
	}
	return [false,false,false];
}
//// num => [fun,[args]]
//var midiMap = [35=>[]];
function load_all_posible_notes_mid(file:String) {

	//game.unspawnNotes = [];
	setVF("MidiParser","parseMidi");
	setVF("MidiParser","ticksToMilliseconds");
	if (!NativeFileSystem.exists(file)) return;
	var midi = parseMidi(File.getBytes(file));
	var bpm = 120;
	var TEv ;
	for (i in midi.tracks){
		bpm = i.tempoEvents.length > 0 ? Math.round(60000000 / i.tempoEvents[0].tempo) : bpm;
		TEv = i.tempoEvents.length > 0 ? i.tempoEvents : TEv;
	}

	Conductor.bpm = bpm;
	PlayState.SONG.bpm = bpm;
	for (t in midi.tracks){
		for (n in t.notes){
			var leng = ticksToMilliseconds(n.endTime,midi.timeDivision, TEv)/1000;
			var tS = ticksToMilliseconds(n.startTime,midi.timeDivision, TEv)/1000;
			switch (n.noteNumber){
				case 28:
					addFastNote(tS,2,leng,0,"vocal");
				case 30:
					addFastNote(tS,1,leng,0,"vocal");
				case 32:
					addFastNote(tS,0,leng,0,"vocal");
				case 35:
					addFastNote(tS,1,leng,0,"lead");
				case 36:
					addFastNote(tS,1,0,0,"lead");
				case 38:
					addFastNote(tS,0,0,0,"lead");
				case 39:
					addFastNote(tS,0,leng,0,"lead");
				case 42:
					addFastNote(tS,1,0,0,"drum");
				case 44:
					addFastNote(tS,0,0,0,"drum");
				case 46:
					addFastNote(tS,0,0,1,"drum");
			}
           //trace("c-"+n.channel+" n-"+n.noteNumber+" t-"+n.startTime+" e-"+n.endTime+" o-"+n.velocityOn+" f-"+n.velocityOff);
			
        }
		//for (e in t.tempoEvents){//not used )))
		//	trace("ti-"+e.time+" te-"+e.tempo);
		//}
	}
}


function load_all_posible_notes_neo(file:String) {

	var d = File.getContent(file);
	d = d.split("(/!\\ Chart saved below /!\\)")[1].split("\n\r\n");
	var lid = ["lead","drum","vocal"];
	for (i in 0...(Math.min(3,d.length))){
		typeTample = lid[i];
		//debugPrint(d.length);
		for (m in d[i].split("\n")){
			noteData = m.split(",");
			scr_rhythmgame_addnote(noteData[0], noteData[1], noteData[2], noteData[3]);
		}
	}
	if (d.length>=4){
		for (n in d[3].split("\n")){
			noteData = n.split("|");
			//debugPrint(noteData);
			if (noteData.length > 1)
				scr_rhythmgame_add_lyric(Std.int((noteData[0]*1000)-40)/1000, noteData[1], (noteData[2]!=null&&noteData[2].length)>2?noteData[2]:"null");
		}
	}
	
}

function load_all_posible_notes_txt(file:String, postfix:String) {
	game.unspawnNotes = [];
	typeTample = "lead";
	StausLoad[0] = loadTxtNotes(file.split(".")[0] + postfix + ".txt");
	// DeltaRuneCode.call("scr_rhythmgame_notechart_lead", [type]);
	typeTample = "drum";
	StausLoad[1] = loadTxtNotes(file.split(".")[0] + postfix + "_drums" + ".txt");
	// DeltaRuneCode.call("scr_rhythmgame_notechart_drums", [type]);
	typeTample = "vocal";
	StausLoad[2] = loadTxtNotes(file.split(".")[0] + postfix + "_vocals" + ".txt");
	// typeTample = "vocal";
	loadTxtLyrics(file.split(".")[0] + "_lyrics" + postfix + ".txt");
	// DeltaRuneCode.call("scr_rhythmgame_notechart_vocals", [type]);
}

function loadTxtNotes(file:String) {
	if (NativeFileSystem.exists(file)) {
		var data:Array<String> = File.getContent(file).split("\n");
		var noteData:Array<Dynamic>;
		for (note in data) {
			noteData = note.split(",");
			if (noteData.length > 1)
				scr_rhythmgame_addnote(noteData[0], noteData[1], noteData[2], noteData[3], noteData[4]);
			// trace(noteData);
		}
		//debugPrint("loaded " + file);
		return true;
	} else {
		debugPrint("not loaded " + file);
		return false;
	}
}

function loadTxtLyrics(file:String) {
	if (NativeFileSystem.exists(file)) {
		var data:Array<String> = File.getContent(file).split("\n");
		var noteData:Array<Dynamic>;
		for (note in data) {
			// if (note.length<8) continue;
			noteData = note.split(",");
			if (noteData.length >= 1) {
				// debugPrint(noteData[2]);
				scr_rhythmgame_add_lyric(Std.int((noteData[0]*1000)-40)/1000, noteData[1], (noteData[2]==null||noteData[2].length<2)?"null":noteData[2]);
			}
		}
		//debugPrint("loaded " + file);
	} else {
		debugPrint("not loaded " + file);
	}
}

function loadHXNotes(file:String, index:Int, isFull:Bool = false) {
	var scriptToLoad = Paths.modFolders(file);
	if (NativeFileSystem.exists(scriptToLoad)) {
		if (!Iris.instances.exists(scriptToLoad)) {
			try {
				DeltaRuneCode = new HScript(null, scriptToLoad);
				// debugPrint("all dune loads");
				DeltaRuneCode.set("scr_rhythmgame_addnote_range", scr_rhythmgame_addnote_range);
				DeltaRuneCode.set("scr_rhythmgame_addnote", scr_rhythmgame_addnote);
				DeltaRuneCode.set("stringsetloc", stringsetloc);
				DeltaRuneCode.set("scr_rhythmgame_clear_lyric", scr_rhythmgame_clear_lyric);
				DeltaRuneCode.set("scr_rhythmgame_add_lyric", scr_rhythmgame_add_lyric);
				game.hscriptArray.push(DeltaRuneCode);
				// PlayState.startLuasNamed("custom_events/ill make.lua");
				// debugPrint("all dune loads");
			} catch (e:Dynamic) {
				debugPrint(e);
				var newScript:HScript = cast(Iris.instances.get(file), HScript);
				if (newScript != null)
					newScript.destroy();
				return;
			}
		}
	} else {
		debugPrint("hx file not found", 0xFF0000);
		return;
	}
	// if (!loadLua("custom_events/ill make.lua"))
	//	return;
	if (index != null) {
		load_all_posible_notes_hx(index, isFull);
	}
}

function load_all_posible_notes_hx(type = 0, ?isFull:Bool = false) {
	game.unspawnNotes = [];
	typeTample = "lead";
	DeltaRuneCode.call("scr_rhythmgame_notechart_lead", [type]);
	typeTample = "drum";
	DeltaRuneCode.call("scr_rhythmgame_notechart_drums", [type]);
	typeTample = "vocal";
	DeltaRuneCode.call("scr_rhythmgame_notechart_vocals", [type]);
	if (isFull) {
		typeTample = "lead";
		DeltaRuneCode.call("scr_rhythmgame_notechart_lead_solo", [0]);
		DeltaRuneCode.call("scr_rhythmgame_notechart_lead_solo", [1]);
		DeltaRuneCode.call("scr_rhythmgame_notechart_lead_solo", [2]);
		// DeltaRuneCode.call("scr_rhythmgame_notechart_lead_solo", [3]);
		DeltaRuneCode.call("scr_rhythmgame_notechart_lead_finale", [0]);
	}
}

// lol not want do this // not need it
function scr_rhythmgame_addnote_range(timming, type, sus, ?spec = 0) {
	scr_rhythmgame_addnote(timming, type, sus, spec);
}

function addFastNote(time,data,sus,spec,who) {
	typeTample = who;
	scr_rhythmgame_addnote(time,data,sus,spec);
}

var oldNote:Note;

function scr_rhythmgame_addnote(timming, types, sus, ?spec ) {
	    //trace("Добавляю ноту: время=" + timming + ", тип=" + typeTample + ", длинна=" + sus);
	// typeTample = getVar("typeTample");
	sus = sus * 1000;
	timming = timming * 1000;
	if (sus > 0) {
		sus = sus - timming;
	}
	//if (oldNote!=null&&Math.abs(oldNote.strumTime - timming)<=100.0&&oldNote.noteData==types)return;
	// var mustPress = typeTample != "vocal";
	// var typeNote:Int =3;
	// if (typeTample=="vocal"){
	//    typeNote = types+1;
	//    if (types==0) typeNote = 0;
	// }
	// else if(typeTample=="drum"){
	//    typeNote = types+1;
	//    if (types == 2)typeNote = 1;
	// }else if(typeTample=="lead"){
	//    typeNote = types*3;
	// }

	var daNote:Note = new Note(timming, types, oldNote);
	// daNote.mustPress = mustPress;
	daNote.noteType = typeTample;
	if (spec != null) {
		daNote.animSuffix = spec == 1 ? '-alt' : "";
		daNote.extraData.set("lolTag", spec);
		// debugPrint(timming+typeTample+spec );
	}
	// daNote.noteType = typeNote;
	daNote.scrollFactor.set(1,1);
	daNote.sustainLength = sus;

	game.unspawnNotes.push(daNote);

	if (sus > 0) {
		var roundSus:Int = Math.round(sus / curStepCrochet);
		// debugPrint(curStepCrochet);
		for (susNote in 0...roundSus) {
			var boOld:Note = unspawnNotes[Std.int(unspawnNotes.length - 1)];
			var sustainNote:Note = new Note(timming + (curStepCrochet * susNote), types, boOld, true);
			sustainNote.animSuffix = daNote.animSuffix;
			//sustainNote.mustPress = daNote.mustPress;
			sustainNote.noteType = typeTample;
			// sustainNote.gfNote = daNote.gfNote;
			sustainNote.noteData = daNote.noteData;
			sustainNote.scrollFactor.set();
			sustainNote.parent = daNote;
			
			
			//if (oldNote.isSustainNote){
			//	oldNote.scale.y *= Note.SUSTAIN_SIZE / oldNote.frameHeight;
			//	oldNote.scale.y /= playbackRate;
			//}
			

			//sustainNote.correctionOffset = ClientPrefs.data.downScroll?0:daNote.height / 2;
			boOld = sustainNote;
			game.unspawnNotes.push(sustainNote);
			daNote.tail.push(sustainNote);
		}
	}
	oldNote = daNote;
}

// i add this later(never)
function stringsetloc(defString, tag) {
	return defString;
}

function scr_rhythmgame_clear_lyric(timming) {
	scr_rhythmgame_add_lyric(timming, "", "");
}

// var lyricBuffer = [0,""];

function scr_rhythmgame_add_lyric(timming, str1 = "", ?str2 = "") {
	// trigerEvent(timming*1000,"subtitle",str1,null);
	// if (lyricBuffer[0]>0){
	var subEvent:EventNote = {
		strumTime: timming * 1000, // lyricBuffer[0] , // + ClientPrefs.data.noteOffset,
		event: "ill make lyric",
		value1: str1, // timming * 1000 - lyricBuffer[0],
		value2: str2 // lyricBuffer[1]
	};
	eventNotes.push(subEvent);
	// }
	// lyricBuffer = [
	//	timming * 1000,
	//	str1+"\n"+str2
	// ];
}

function writeNoteToSong(maxTime:Int) {
	trace("start write");
    if (PlayState.SONG.format == "psych_v1_convert") return;
	//PlayState.SONG.notes[0].sectionNotes = [];
	//PlayState.SONG.notes[0].bpm = PlayState.SONG.bpm;
	//var emty = 
    PlayState.SONG.notes = [];
	//trace(emty);
	//var notes:Int = 0;
	var section:Int = 1 / PlayState.SONG.bpm * 60 * 1000 * 4;
    for (i in 0...Math.round((maxTime / section) + 0.5))
        PlayState.SONG.notes[i] = {
            sectionNotes: [],
            bpm: PlayState.SONG.bpm,
            mustHitSection: true,
            gfSection: false,
            altAnim: false,
            changeBPM: false,
            sectionBeats: 4
        };
	for (i in 0...game.unspawnNotes.length) {
		var note = game.unspawnNotes[i];
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
function findClapRals() {
	var bpm = -1;
	var fn = [];
	for (note in unspawnNotes) {
		if (note.noteType == "vocal") {
			if (note.noteData == 1 && !note.isSustainNote) {
				fn.push(note);
			} else {
				// debugPrint(note.noteData);
				fn = [];
			}
		}
		if (fn.length > 4) {
			bpm = fn[1].strumTime - fn[0].strumTime;
			// debugPrint(bpm);
		}
	}
	return bpm / 4;
}

function loadLua(file) {
	var luaToLoad = Paths.modFolders(file);
	for (script in luaArray)
		if (script.scriptName == luaToLoad)
			return false;
	new FunkinLua(luaToLoad);
	return true;
}

function onDestroy() {}