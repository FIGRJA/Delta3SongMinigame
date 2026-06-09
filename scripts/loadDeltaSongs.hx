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
function onCreate() {
	setVar("load_delta_notes", this);

	game.startHScriptsNamed('custom_events/' + "ill make lyric" + '.hx');
}

function loadSong(file:String, ?index:Dynamic, ?isFull:Bool = false) {
	// PlayState.instance.clearNotesBefore(0);
	// PlayState.instance.setSongTime(0);
	curStepCrochet = 60 / PlayState.SONG.bpm * 1000 / 4.0;
	// var file:String = getVar("load_delta_notes");
	// var index = getVar("load_delta_notes_index");
	if (file != null) {
		if (file.lastIndexOf(".hx") == file.length - 3)
			loadHXNotes(file, index, isFull);
		else if (file.lastIndexOf(".txt") == file.length - 4)
			load_all_posible_notes_txt(file, index, isFull);

		game.unspawnNotes.sort(function(a, b) {
			return a.strumTime - b.strumTime;
		});

		// var foundBPM = findClapRals();
		// if (foundBPM>0){
		//	PlayState.SONG.bpm = foundBPM;
		//	Conductor.bpm = foundBPM;
		// }
		
		writeNoteToSong();
		// game.unspawnNotes = [];
		// PlayState.generateSong();
		debugPrint("loaded " + game.unspawnNotes.length + " notes");
		// debugPrint("created "+PlayState.SONG.notes[0].sectionNotes.length+" notes");
		//debugPrint(StausLoad);
		return StausLoad;
	}
	return [false,false,false];
}

function load_all_posible_notes_txt(file:String, postfix:String, ?isFull:Bool = false) {
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
		debugPrint("loaded " + file);
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
				scr_rhythmgame_add_lyric(Std.int(noteData[0]), noteData[1], noteData[3] == null ? "null" : noteData[2]);
			}
		}
		debugPrint("loaded " + file);
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

var oldNote:Note;

function scr_rhythmgame_addnote(timming, types, sus, ?spec = 0, ?lolTag) {
	// typeTample = getVar("typeTample");
	sus = sus * 1000;
	timming = timming * 1000;
	if (sus > 0) {
		sus = sus - timming;
	}
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
	if (spec > 0) {
		daNote.animSuffix = spec == 1 ? '-alt' : "";
		// debugPrint(timming+typeTample+spec );
	}
	// daNote.noteType = typeNote;
	daNote.scrollFactor.set();
	daNote.sustainLength = sus;
	daNote.extraData.set("lolTag", lolTag);

	game.unspawnNotes.push(daNote);

	if (sus > 0) {
		var roundSus:Int = Math.round(sus / curStepCrochet);
		// debugPrint(curStepCrochet);
		for (susNote in 0...roundSus) {
			var boOld:Note = unspawnNotes[Std.int(unspawnNotes.length - 1)];
			var sustainNote:Note = new Note(timming + (curStepCrochet * susNote), types, boOld, true);
			sustainNote.animSuffix = daNote.animSuffix;
			sustainNote.mustPress = daNote.mustPress;
			sustainNote.noteType = typeTample;
			// sustainNote.gfNote = daNote.gfNote;
			sustainNote.noteData = daNote.noteData;
			sustainNote.scrollFactor.set();
			sustainNote.parent = daNote;
			
			
			//if (oldNote.isSustainNote){
			//	oldNote.scale.y *= Note.SUSTAIN_SIZE / oldNote.frameHeight;
			//	oldNote.scale.y /= playbackRate;
			//}
			

			sustainNote.correctionOffset = ClientPrefs.data.downScroll?0:daNote.height / 2;
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
	scr_rhythmgame_add_lyric(timming, " ", " ");
}

// var lyricBuffer = [0,""];

function scr_rhythmgame_add_lyric(timming, str1 = "", ?str2 = "") {
	// trigerEvent(timming*1000,"subtitle",str1,null);
	// if (lyricBuffer[0]>0){
	var subEvent:EventNote = {
		strumTime: timming * 1000, // lyricBuffer[0] , // + ClientPrefs.data.noteOffset,
		event: "ill make lyric",
		value1: "", // timming * 1000 - lyricBuffer[0],
		value2: str1 + "\n" + str2 // lyricBuffer[1]
	};
	eventNotes.push(subEvent);
	// }
	// lyricBuffer = [
	//	timming * 1000,
	//	str1+"\n"+str2
	// ];
}

function writeNoteToSong() {
	PlayState.SONG.notes[0].sectionNotes = [];
	var notes:Int = 0;
	var section:Int = 1 / PlayState.SONG.bpm * 60 * 1000 * 4;
	for (i in 0...game.unspawnNotes.length) {
		var note = game.unspawnNotes[i];
		if (note.isSustainNote)
			continue;
		var simpleNote:Arry<Dynamic> = [0.0, 0, 0.0, ""];
		simpleNote[0] = note.strumTime;
		simpleNote[1] = note.noteData + (note.mustPress ? 0 : 4);
		simpleNote[2] = note.sustainLength;
		simpleNote[3] = note.animSuffix == "-alt" ? "Alt Animation" : "";
		if (PlayState.SONG.notes.length > Math.round((note.strumTime / section) - 0.5)) {
			if (PlayState.SONG.notes[Math.round((note.strumTime / section) + 0.5)]!=null)
				PlayState.SONG.notes[Math.round((note.strumTime / section) + 0.5)].sectionNotes = [];
		}

		if (PlayState.SONG.notes[Math.round((note.strumTime / section) + 0.5)]!=null)
			PlayState.SONG.notes[Math.round((note.strumTime / section) - 0.5)].sectionNotes.push(simpleNote);
		notes++;
	}
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
