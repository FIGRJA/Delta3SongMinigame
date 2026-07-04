//package scripts; //эбанный vs

import Type;
import Reflect;
import flixel.FlxG;
import flixel.text.FlxText.FlxTextFormat;
import flixel.text.FlxText.FlxTextFormatMarkerPair;
import backend.Mods;
import backend.CacheSystem;
import backend.ui.PsychUIBox;
import mikolka.funkin.custom.NativeFileSystem as NativeFileSystem;
import states.editors.ChartingState;

function setVF(Var,Fun) {
	if (getVar(Var).exists(Fun))
		this.set(Fun,getVar(Var).get(Fun));
	
}

//var songI ;
//var songV ;
var unspawnNotes ;
var eventNotes ;
var statusLoad = [true,true,true];

function writeEvents() {
    var eventsL = [];
    for (event in game.eventNotes){
        var Finded = false;
        var i = 0;
        //trace(event);
        while (i<eventsL.length&&!Finded){
            var e = eventsL[i];
            if (e[0]==event.strumTime){
                e[1].push([event.event,event.value1,event.value2]);
                Finded=true;
            }
            i += 1;
        }
        if (!Finded){
            eventsL.push([event.strumTime,[[event.event,event.value1,event.value2]]]);
        }
    }
    return eventsL;
}

function writeNoteToSong(maxTime:Int) {
	trace("start write");
    //if (PlayState.SONG.format == "psych_v1_convert") return;
	//PlayState.SONG.notes[0].sectionNotes = [];
	//PlayState.SONG.notes[0].bpm = PlayState.SONG.bpm;
	//var emty = 
    var SuperSimpleNotes = [];
	//trace(emty);
	//var notes:Int = 0;
	var section:Int = 1 / PlayState.SONG.bpm * 60 * 1000 * 4;
    for (i in 0...Math.round((maxTime / section) + 0.5))
        SuperSimpleNotes[i] = {
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
		if (SuperSimpleNotes[Math.round((note.strumTime / section))]==null) {
			SuperSimpleNotes[Math.round((note.strumTime / section))] = {
                sectionNotes: [],
                bpm: PlayState.SONG.bpm,
                mustHitSection: true,
                gfSection: false,
                altAnim: false,
                changeBPM: false,
                sectionBeats: 4
            };
		}
		SuperSimpleNotes[Math.round((note.strumTime / section))].sectionNotes.push(simpleNote);
		//notes++;
	}
    //trace(PlayState.SONG.notes);
    //trace(PlayState.SONG.notes.length);
	//trace("end write");
    return SuperSimpleNotes;
}

function onCreatePost() {
//setVF("load_delta_notes","writeNoteToSong");
    //songI = getVar("SONG").songMain;
    //songV = getVar("SONG").songPlay;
    unspawnNotes = writeNoteToSong(FlxG.sound.music.length);
    eventNotes = writeEvents();
    //PlayState.SONG.notes = [];
    ChartingState.GRID_PLAYERS = 2;
    ChartingState.GRID_COLUMNS_PER_PLAYER = 4;
    //this.set("Reflect",Type.resolveClass("Reflect"));
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
var lyricBox;
var lyricText;
var lastTime = 0;
var section = 0;
var e = 0;
Helper = ()->{
    try{
        //e += _;
        //trace("hi");
        setVar("chartHelper",Helper);

        ChartingState.GRID_PLAYERS = Std.int(statusLoad[0])+Std.int(statusLoad[1])+Std.int(statusLoad[2]);
        ChartingState.GRID_COLUMNS_PER_PLAYER = Math.max((statusLoad[0]?2:0),Math.max((statusLoad[1]?3:0),(statusLoad[2]?3:0)));
        if (Type.getClassName(Type.getClass(FlxG.state))=="states.editors.ChartingState"){
            var state =  FlxG.state;
            if (FlxG.sound.music.length<1000){
                //trace(getSong("mus/"+songI+".ogg"));
                FlxG.sound.music.loadEmbedded(CacheSystem.loadSound(getSong("mus/"+PlayState.SONG.gameOverLoop+".ogg"),true,"nice Try"));
                state.maxTime = FlxG.sound.music.length;
			    state.prevEndInput.max = FlxMath.roundDecimal(state.maxTime/1000,2);
                state._cacheSections();
                //if (!songEx){
                PlayState.SONG.notes = unspawnNotes.copy();
                PlayState.SONG.events = eventNotes.copy();
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
                //state.waveformSprite.x = FlxG.height/2-(ChartingState.GRID_PLAYERS*ChartingState.GRID_SIZE/2);
                trace(state.waveformSprite.x);
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
            if (state.curSec!=section){
                section = state.curSec;
                //FlxG.state.waveformSprite.x = FlxG.state.gridBg.x - ChartingState.GRID_SIZE*ChartingState.GRID_COLUMNS_PER_PLAYER;
                for (i in 0...ChartingState.GRID_PLAYERS){
                    //FlxG.state.icons[i].changeIcon(icons[i]);
                    state.icons[i].antialiasing=false;
                }
            }
            if (lyricBox==null){
                lyricBox = new PsychUIBox(state.infoBoxPosition.x, state.infoBoxPosition.y, 500, 100, ['lyric','custom settings(x)']);
                lyricBox.scrollFactor.set();
                lyricBox.cameras = [state.camUI];
                lyricText = new FlxText(15, 15, 470, 'test1\ntext 1.2.3', 16);
                lyricText.scrollFactor.set();
                lyricBox.getTab('lyric').menu.add(lyricText);
                state.add(lyricBox);
            }
            var lyricUpdated = false;
            for (note in state.curRenderedNotes)
			{
                if(note == null) continue;
                if (note.isEvent){
                    if(Conductor.songPosition > (note.strumTime-1) && lastTime <= (note.strumTime-1))
                        onEventS(note.events[0][1],note.events[0][2]);
                    //lyricText.text = note.events[0][1]+"\n"+note.events[0][2];
                }else if (!note.mustPress&&note.sustainLength>0){
                    if(Conductor.songPosition > note.strumTime && Conductor.songPosition <= note.strumTime+note.sustainLength+10 && !lyricUpdated){
                        try{
                        singWord(note,Conductor.songPosition>lastTime);
                        lyricUpdated = true;
                        }catch (e:Dynamic){trace(e);}
                    }
                }
                //if (!note.mustPress)trace(note.noteData);
            }
            lastTime = Conductor.songPosition;
        }
        try{
            //for (i in FlxG.game.filters)
            //    if (i.shader != null && i.shader.data.time != null)
            //        i.shader.data.time.value = FlxG.elapsed/1;

        //FlxG.game.filters[0].shader.setFloat("time",FlxG.elapsed);
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
        if ((game.songName=="songchart"||game.chartingMode)&&getVar("chartHelper")!=null){
            trace("removed");
            FlxG.signals.preUpdate.remove(getVar("chartHelper"));
            setVar("chartHelper",null);
            
        }
        if (getVar("chartHelper")==null&&game.songName!="songchart"){
            trace("added");
            FlxG.signals.preUpdate.add(Helper);
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


var word = 0;
var Rstrin = [];
//var RstrinNEXT = [];
var blue = new FlxTextFormatMarkerPair(new FlxTextFormat(0xFF0048FF), "$//");
var blueC = new FlxTextFormatMarkerPair(new FlxTextFormat(0xFF1800CF), "&&");

// var r = ~/-/g;
function onEventS(v1, v2) {
    trace(v1);
	v2 = v2.split("-").join("- ");
	v1 = v1.split("-").join("- ");
    //if (RstrinNEXT.length>0){
    //    Rstrin = RstrinNEXT;
    //    word = 0;
    //}
	//RstrinNEXT = [];
	Rstrin = [];
    word = -1;
	if (v2 == "null")
		v2 = v1;
	var d1 = v1.split(" ").join("").split("-").join("");
	var d2 = v2.split(" ");
	var g = -1;
	for (m in 0...d2.length) {
		var d = [d1, d2[m]];
		// var tmpA=0;
		var tmpS = "";
		var tmpN = 0;
		var tmpM = 0;
		var strin = [];
		var i = -1;
		while (i < d[1].length - 1) {
			i += 1;
			if (d[1].charAt(i) == "-")
				continue;
			g += 1;
			if (d[1].charAt(i) == "[") {
				// tirg = d[1].substring(i+tmpA,d[1].indexOf("]",i+tmpA)).split(":");
				tmpN = d[1].substring(i + 1, d[1].indexOf("]", i)).split(":")[0];
				tmpS = d[1].substring(i + 1, d[1].indexOf("]", i)).split(":")[1];
				// debugPrint(tmpN+" "+tmpS);
				i = d[1].indexOf("]", i) + 1 - tmpN;
			}
			var r = "";
			if (tmpS.length > 0) {
				r = tmpS.substring(Std.int(tmpM), Std.int(tmpM + tmpS.length / tmpN + 0.01));
				tmpM = tmpM + tmpS.length / tmpN + 0.01;
				if (Std.int(tmpM) >= tmpS.length) {
					tmpS = "";
					tmpM = 0;
				}
			} else if (tmpS == null) {
				r = d[0].charAt(g);
			} else {
				r = d[1].charAt(i);
			} 
			strin.push([d[0].charAt(g), r]);
		}
		if (d[1].charAt(d[1].length - 1) != "-")
			strin.push([" ", " "]);
		//RstrinNEXT.push(strin);
		Rstrin.push(strin);
	}
    lyricText.applyMarkup((word+1)+" / "+Rstrin.length+"\n"+v1.split("-").join(""),[]);
}

var mType = 0;
var flxT;
var flxM;
var oldNote;
function singWord(daNote,toFu) {

    word += (toFu?1:-1)*(daNote!=oldNote?1:0);
    //trace(daNote!=oldNote);
    oldNote = daNote;
    if (Rstrin.length<word) {
        //if (RstrinNEXT.length>0){
        //    Rstrin = RstrinNEXT;
        //    RstrinNEXT = [];
        //    word = 0;
        //}else {
            return;
        //}
    };
    tim =Std.int((Conductor.songPosition - daNote.strumTime)/( daNote.sustainLength / Rstrin[word].length ));
    var s = (word+1)+" / "+Rstrin.length+"\n$//";
    for (m in 0...Rstrin.length) {
        var ss = false;
        for (i in 0...Rstrin[m].length) {
            if (tim == i && m == word) {
                s = s + "$//";
                ss = true;
            }
            if ((tim >= i && m == word) || (m < word)) {
                s = s + Rstrin[m][i][1];
            } else {
                s = s + Rstrin[m][i][0];
            }
        }
        if (m == word && !ss) {
            s = s + "$//";
        }
        // s = s + "";
    }
    // debugPrint(s);
    //lyricText.text = s;
    lyricText.applyMarkup(s, [blue, blueC]);
}

function opponentNoteHitss(daNote) {//требуется пересборка 
	
	try {
		if (!daNote.isSustainNote && (RstrinNEXT.length > 0 || Rstrin.length > 0)) {
			word += 1;
			// debugPrint(word);

			if (word >= Rstrin.length && RstrinNEXT.length>0) {
				Rstrin = RstrinNEXT.copy();
				RstrinNEXT = [];
				word = 0;
			}
            if (word >= Rstrin.length) return
            if (flxM != null)
			    flxM.cancel();
				//return;
			if (word+1 >= Rstrin.length)
				flxM = new FlxTimer().start(
					(daNote.sustainLength / 1000) + 2,
					()->{
						if (word+1 >= Rstrin.length){
							songTxt.text="";
							//debugPrint("coc");
							//if (flxT != null)
							//    flxT.cancel();
						}
					}
				);
			// debugPrint(daNote.sustainLength/Rstrin[word].length/1000);
			if (flxT != null)
				//return;
			    flxT.cancel();
            var mword = word;
			flxT = FlxTimer.loop(daNote.sustainLength / Rstrin[mword].length / 1000, (tim) -> {
				// if (tim>=Rstrin[word].length&&word>=Rstrin.length){songTxt.text = "";return;}
				var s = "$//";
				for (m in 0...Rstrin.length) {
					var ss = false;
					for (i in 0...Rstrin[m].length) {
						if (tim == i && m == mword) {
							s = s + "$//";
							ss = true;
						}
						if ((tim >= i && m == mword) || (m < mword)) {
							s = s + Rstrin[m][i][1];
						} else {
							s = s + Rstrin[m][i][0];
						}
					}
					if (m == mword && !ss) {
						s = s + "$//";
					}
					// s = s + "";
				}
				// debugPrint(s);
				songTxt.applyMarkup(s, [blue, blueC]);
			}, Rstrin[word].length);
		}
	} catch (e:Dynamic) {
		debugPrint(e, FlxColor.RED);
	}
}
