if (PlayState.SONG.stage!="D3Main") return;
//package scripts; //эбанный vs

import Type;
import Reflect;
import Array;
import flixel.FlxG;
import flixel.group.FlxTypedSpriteGroup;
import flixel.text.FlxText.FlxTextFormat;
import flixel.text.FlxText.FlxTextFormatMarkerPair;
import backend.Mods;
import backend.CacheSystem;
import backend.ui.PsychUIBox;
import backend.ui.PsychUICheckBox;
import backend.ui.PsychUINumericStepper;
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

//function deepEquals(a:Dynamic, b:Dynamic):Bool {//deepseak
//    // Если типы разные
//    if (Type.typeof(a) != Type.typeof(b)) return false;
//    
//    // Если это массивы
//    if (Std.is(a, Array) && Std.is(b, Array)) {
//        var arrA:Array<Dynamic> = a;
//        var arrB:Array<Dynamic> = b;
//        
//        if (arrA.length != arrB.length) return false;
//        
//        for (i in 0...arrA.length) {
//            if (!deepEquals(arrA[i], arrB[i])) return false;
//        }
//        return true;
//    }
//    
//    // Примитивные типы
//    return a == b;
//}

function writeEvents() {
    var eventsL = [];
    for (event in game.eventNotes){
        var Finded = false;
        var i = 0;
        //trace(event);
        //while (i<eventsL.length&&!Finded){
        //    var e = eventsL[i];
        //    if (e[0]==event.strumTime){
        //        e[1].push([event.event,event.value1,event.value2]);
        //        Finded=true;
        //    }
        //    i += 1;
        //}
        if (!Finded){
            eventsL.push([event.strumTime,[[event.event,event.value1,event.value2]]]);
        }
    }
    return eventsL;
}

function writeNoteToSong(maxTime) {
	trace("start write");
    var NoteTime = 0;
    if (game.unspawnNotes.length>0)
        NoteTime = game.unspawnNotes[game.unspawnNotes.length-1].strumTime;
    maxTime = Math.max(NoteTime,maxTime);
    if (PlayState.SONG.notes.length>2) {
        trace("skip write");
        return PlayState.SONG.notes.copy();
    }
    var PB = getVar("D3Main").get("getLV")("sectionBeats");
    ///trace(Reflect.fields(this));
    ///trace(Reflect.fields(this.interp));
    ///trace(Reflect.fields(this.interp.locals.get("PB")));
    ///trace(this.interp.binops);
    //trace(getVar("D3Main").get("getThis")().interp.locals);
	//PlayState.SONG.notes[0].sectionNotes = [];
	//PlayState.SONG.notes[0].bpm = PlayState.SONG.bpm;
	//var emty = 
    var SuperSimpleNotes = [];
	//trace(emty);
	//var notes:Int = 0;
	var section:Int = 1 / PlayState.SONG.bpm * 60 * 1000 * PB;
    //trace(Math.round((maxTime / section)));
    for (i in 0...Std.int((maxTime / section))+2)
        SuperSimpleNotes[i] = {
            sectionNotes: [],
            bpm: PlayState.SONG.bpm,
            mustHitSection: true,
            gfSection: false,
            altAnim: false,
            changeBPM: false,
            sectionBeats: PB
        };
	for (i in 0...game.unspawnNotes.length) {
		var note = game.unspawnNotes[i];
        //trace(Std.int((note.strumTime / section)));
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
		if (SuperSimpleNotes[Std.int((note.strumTime / section))]==null) {
			SuperSimpleNotes[Std.int((note.strumTime / section))] = {
                sectionNotes: [],
                bpm: PlayState.SONG.bpm,
                mustHitSection: true,
                gfSection: false,
                altAnim: false,
                changeBPM: false,
                sectionBeats: PB
            };
		}
		SuperSimpleNotes[Std.int((note.strumTime / section))].sectionNotes.push(simpleNote);
		//notes++;
	}
    //trace(PlayState.SONG.notes);
    //trace(PlayState.SONG.notes.length);
    //trace(SuperSimpleNotes);
	trace("end write");
    return SuperSimpleNotes;
}

function onCreatePost() {
    if (game.songName=="songchart") return;
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
var Rstrin = [0];
var songEx = false;
var Helper ;
var icons = ["kris","susi","ralsei"];
var lyricBox;
var lyricText;
var lastTime = 0;
var section = 0;
var e = 0;
var previewCharaters = new FlxTypedSpriteGroup();
var animationsS = [ "singDOWN","singUP","singUP-alt","singDOWN-alt", "singUP-alt"];
var animationsK = [ "singLEFT", "singRIGHT","singRIGHT-alt","singLEFT","singRIGHT-alt","singRIGHT-alt"];
var animationsR = [ "singUP-hold","idle-alt", "singRIGHT-alt", "idle-alt"];

var hitsoundSusie = new PsychUINumericStepper(10, 20, 0.2, 0, 0, 1, 1);
var hitsoundRalsei = new PsychUINumericStepper(10 + 100, 20, 0.2, 0, 0, 1, 1);
var hitsoundSign = new PsychUINumericStepper(10 + 200, 20, 0.1, 0.4, 0, 1, 1);

function notDance() {
    for (ch in previewCharaters.members){
        if (ch.animation.finished){
            ch.animation.play("idle",true);
        }
    }
    //need ralsei only
}
function dance(note,newN:Bool) {
    if (note.songData[1]>=(statusLoad[0]?3:0)+(statusLoad[1]?3:0)){//ralsei
        previewCharaters.members[2].animation.play(animationsR[(note.songData[2]>0?0:1)], !(note.songData[2]>0));
        FlxG.sound.play(Paths.sound('hitsound'), hitsoundRalsei.value*(newN?1:hitsoundSign.value));
    }
    else if (note.songData[1]>=(statusLoad[0]?3:0)){//drums
        previewCharaters.members[1].animation.play(animationsS[note.songData[1]-(statusLoad[0]?3:0)+(Std.int(note.songData[3]=="Alt Animation")*3)], true);
        FlxG.sound.play(Paths.sound('hitsound'), hitsoundSusie.value);
    }
    else {//lead
        previewCharaters.members[0].animation.play(animationsK[note.songData[1]+(Std.int(note.songData[3]=="Alt Animation")*3)], true);
        FlxG.sound.play(Paths.sound('hitsound'), FlxG.state.hitsoundPlayerStepper.value*(newN?0:hitsoundSign.value));
    }
}

var RedE = new FlxTextFormatMarkerPair(new FlxTextFormat(0xAF0000), "'");
var Green = new FlxTextFormatMarkerPair(new FlxTextFormat(0x00FF15), "'");
Helper = ()->{
    try{
        //e += _;
        //trace("hi");
        setVar("chartHelper",Helper);

        ChartingState.GRID_PLAYERS = Std.int(statusLoad[0])+Std.int(statusLoad[1])+Std.int(statusLoad[2]);
        ChartingState.GRID_COLUMNS_PER_PLAYER = Math.max((statusLoad[0]?2:0),Math.max((statusLoad[1]?3:0),(statusLoad[2]?3:0)));
        ChartingState.keysArray[8] = 57;//flxKey of 'nine'
        if (Type.getClassName(Type.getClass(FlxG.state))=="states.editors.ChartingState"){
            var state =  FlxG.state;
            if (lyricBox==null){
                lyricBox = new PsychUIBox((FlxG.width/2)+200, 338, 440, 100, ['lyric','custom settings']);
                lyricBox.scrollFactor.set();
                lyricBox.cameras = [state.camUI];
                state.add(lyricBox);
                
                var tab_group = lyricBox.getTab('lyric').menu;

                lyricText = new FlxText(10, 5, 470, statusLoad[2]?'test '+eventNotes.length+'\ntext 1.2.3':"no vocal\nno lyric", 30);
                lyricText.scrollFactor.set();
                lyricText.font = Paths.getPath("fronts/fnt_main.ttf");
                lyricText.antialiasing = false;
                tab_group.add(lyricText);

                var charakters = ["kris","susi","ralsei"];
                for (i in 0...3){
                    var char = new Character(40 -(i==1?10:0),-90+(i==1?0:30),charakters[i],i==0);
                    previewCharaters.add(char);
                    var TBox = new PsychUIBox(i*120 -360, -20, 120, 10, [charakters[i]]);
                    TBox.tabHeight = 0;
                    TBox.selectedTab = null;
                    TBox.getTab(charakters[i]).menu.add(char);
                    tab_group.add(TBox);
                }

                tab_group = lyricBox.getTab('custom settings').menu;

                state.hitsoundOpponentStepper.alpha = 0.3;

                tab_group.add(hitsoundSusie);
		        tab_group.add(new FlxText(hitsoundSusie.x, hitsoundSusie.y - 15, 100, 'Hitsound (Susie):'));
                tab_group.add(hitsoundRalsei);
		        tab_group.add(new FlxText(hitsoundRalsei.x, hitsoundRalsei.y - 15, 100, 'Hitsound (Ralsei):'));
                tab_group.add(hitsoundSign);
		        tab_group.add(new FlxText(hitsoundSign.x, hitsoundSign.y - 15, 100, 'HitSign (multuply):'));
               // lyricBox.getTab('lyric').menu.add(previewCharaters);
                var cursor = new FlxSprite();
                cursor.loadGraphic(Paths.image("spr_rhythmgame_editor_mouse_0"));
               FlxG.mouse.load(cursor.pixels);
            }
            if (FlxG.sound.music.length<1000){
                //trace(getSong("mus/"+songI+".ogg"));
                FlxG.sound.music.loadEmbedded(CacheSystem.loadSound(getSong("mus/"+PlayState.SONG.gameOverLoop+".ogg"),true,"nice Try"));
                
                if (FlxG.sound.music.length<1000) {
                    if (lyricBox!=null){
                        lyricText.applyMarkup("'err load music \ncheak 'data' -> 'Game Over Loop Music",[RedE]);
                        lyricText.color = 0xF7EDED;
                    }
                    return;
                }else if (lyricBox!=null&&lyricText.color == 0xF7EDED){
                    lyricText.applyMarkup("'thanks'",[Green]);
                    //lyricText.text = "thanks";
                    lyricText.color = 0xffffff;
                }
                state.maxTime = FlxG.sound.music.length;
			    state.prevEndInput.max = FlxMath.roundDecimal(state.maxTime/1000,2);
                //if (!songEx){
                PlayState.SONG.notes = unspawnNotes.copy();
                PlayState.SONG.events = eventNotes.copy();
                state._cacheSections();
                //trace("test");
                    //songEx = true;
                //}
                //trace("h3");
                state.vocals.loadEmbedded(CacheSystem.loadSound(getSong("mus/"+PlayState.SONG.gameOverEnd+".ogg"),true,"nice Try"));
                state.updateAudioVolume();
                state.setPitch();
                //trace("test");
            
                // ВАЖНО: Перезагружаем ноты в UI//deepseak
                state.loadSection();
                //trace("testm");
                state.updateGridVisibility();
                //trace("testm");
                state.reloadNotes();
                //trace("testm");
                state.waveformSprite.x = state.gridBg.x - ChartingState.GRID_SIZE*ChartingState.GRID_COLUMNS_PER_PLAYER;
                //state.waveformSprite.x = FlxG.height/2-(ChartingState.GRID_PLAYERS*ChartingState.GRID_SIZE/2);
                var i = 0;
                for (m in 0...3){
                    if (!statusLoad[m]) continue;
                //trace("test");
                    state.icons[i].changeIcon(icons[m]);
                    Reflect.setProperty(state.characterData,'iconP'+(i+1),icons[m]);
                    state.icons[i].scale.set(2,2);
                    state.icons[i].x += -5;
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
            }//else {
            //    trace (lyricBox.x+" "+lyricBox.y);
            //}
            var lyricUpdated = false;
            if (lastTime != Conductor.songPosition){
                //if(statusLoad[2]){
                    for (note in state.curRenderedNotes.members.concat(state.behindRenderedNotes.members))
                    {
                        if(note == null) continue;
                        if(Conductor.songPosition > note.strumTime && lastTime <= note.strumTime+note.sustainLength){
                            if (note.isEvent){
                                try{
                                    if (note.events[0][0]=="ill make lyric"){
                                        //onEventS2(note.strumTime,note.events[0][1],note.events[0][2]);
                                        onEventS(note.strumTime,note.events[0][1],note.events[0][2]);
                                        lyricUpdated = false;
                                    }
                                }catch (e:Dynamic){
                                    trace(e);
                                    e = "ERROR:\n"+Std.string(e).split(":")[2];
                                    Rstrin.push([[e,e]]);
                                    //lyricText.applyMarkup(e,[]);
                                }
                            }
                            //lyricText.text = note.events[0][1]+"\n"+note.events[0][2];
                            else {
                                dance(note,Conductor.songPosition > note.strumTime && lastTime <= note.strumTime);
                                if (note.songData[1]>=(statusLoad[0]?3:0)+(statusLoad[1]?3:0)&&note.get_hasSustain()&&statusLoad[2]){
                                if(!lyricUpdated){
                                    try{
                                    singWord(note,Conductor.songPosition>lastTime);
                                    lyricUpdated = true;
                                    }catch (e:Dynamic){trace(e);}
                                }}
                            }
                        }
                        //if (note.mustPress)trace(note.songData);
                    }
                if (previewCharaters.members[2].animation.finished)
                    previewCharaters.members[2].animation.play("idle",false);
                //}
            }
            if (lastTime > Conductor.songPosition)
                notDance();
            lastTime = Conductor.songPosition;
        }else{
            if (lyricBox!=null){
                lyricBox = null;
            }
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
    }catch (e:Dynamic) {
        trace(e);
        FlxG.signals.preUpdate.remove(Helper);
        if (lyricText!=null)
            lyricText.text = "i'm dead\n"+e;
    }
}

var ema = 0;
var dis = false;
function onUpdate(e) {
    ema += e;
    if (ema>(e*3)&&!dis){
        songEx = false;
        if ((game.songName=="songchart"||true)&&getVar("chartHelper")!=null){
            trace("UnExtended Editor");
            FlxG.signals.preUpdate.remove(getVar("chartHelper"));
            setVar("chartHelper",null);
            
        }
        if (getVar("chartHelper")==null&&game.songName!="songchart"){
            trace("Extended Editor");
            FlxG.signals.preUpdate.add(Helper);
        }
        dis = true;
        //trace(game.songName);
        //ema += e;
    }
}
function onDestroy() {
    if (getVar("chartHelper")!=null) return;
    ChartingState.GRID_PLAYERS = 2;
    ChartingState.GRID_COLUMNS_PER_PLAYER = 4;
}


var word = 0;
var oldNote;
//var RstrinNEXT = [0];
var blue = new FlxTextFormatMarkerPair(new FlxTextFormat(0xFF0048FF), "$//");
var blueC = new FlxTextFormatMarkerPair(new FlxTextFormat(0xFF1800CF), "&&");

// var r = ~/-/g;

function onEventS2(T,v1, v2) {//try new method
	Rstrin = [];
    word = -1;
    if (v1 == null ||v1.length<=2){
        lyricText.applyMarkup("0 / -1",[blue]);
        return;
    }
    if (v2 == null ||v2 == "null" ||v2.length<=2)
        v2 = v1;
    var charI = -1;
        var tmpS = "";
		var tmpN = 0;
		var tmpM = 0;
		var strin = [];
		var i = -1;
		while (i < v2.length - 1) {
			i += 1;
			charI += 1;
			//if (v2.charAt(i) == "-")
			//	continue;
			if (v2.charAt(i) == "[") {
				// tirg = v2.substring(i+tmpA,v2.indexOf("]",i+tmpA)).split(":");
				tmpN = v2.substring(i + 1, v2.indexOf("]", i)).split(":")[0];
				tmpS = v2.substring(i + 1, v2.indexOf("]", i)).split(":")[1];
				// debugPrint(tmpN+" "+tmpS);
				i = v2.indexOf("]", i) + 1 - tmpN;
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
				r = v1.charAt(charI);
			} else {
				r = v2.charAt(i);
			} 
			strin.push([v1.charAt(charI), r]);
		}
        var tStin = [];
        for (s in strin){
            tStin.push(s);
            if (s[1]==" "){
                Rstrin.push(tStin.copy());
                tStin = [];
            }
            else if (s[1]=="-"){
                //tStin.remove(s);
                s[1]="";
                Rstrin.push(tStin.copy());
                tStin = [];
            }
        }
        Rstrin.push(tStin.copy());
    trace (strin);
}

function onEventS(T,v1, v2) {
    trace(v1);
	v2 = v2.split("-").join("- ");
	v1 = v1.split("-").join("- ");
    //if (RstrinNEXT.length>0){
    //    Rstrin = RstrinNEXT;
    //    word = 0;
    //}
	//RstrinNEXT = [T];
	Rstrin = [];
    word = -1;
    if (v1 == null ||v1.length<=2){
        lyricText.applyMarkup("0 / -1",[blue]);
        Rstrin = [];
        word = 0;
        return;
    }
	if (v2 == null ||v2 == "null" ||v2.length<=2)
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
    //trace(Rstrin);
    //lyricText.applyMarkup((word+1)+" / "+Rstrin.length+"\n",[]);
    //for (s in Rstrin)
    //    for (c in s)
    //        lyricText.text += c[0];
    //lyricText.applyMarkup((word+1)+" / "+Rstrin.length+"\n"+v1.split("-").join(""),[]);
}

var mType = 0;
function singWord(daNote,toFu) {
    if (daNote!=oldNote){
        //if (Rstrin[0]!=RstrinNEXT[0]){
        //    word = 0;
        //    Rstrin = RstrinNEXT.copy();
        //}
        word += (toFu?1:-1);
    }

    //trace(daNote!=oldNote);
    oldNote = daNote;
    if (Rstrin.length<=word||word<0) {
        //if (RstrinNEXT.length>0){
        //    Rstrin = RstrinNEXT;
        //    RstrinNEXT = [];
        //    word = 0;
        //}else {
            return;
        //}
    };
    tim =Std.int((Conductor.songPosition - daNote.strumTime)/( daNote.sustainLength / Rstrin[word].length ));
    var s = (word+1)+" / "+(Rstrin.length)+"\n$//";
    for (m in 0...Rstrin.length) {
        var ss = false;
        for (i in 0...Rstrin[m].length) {
            if (tim == i && m == word) {
                s = s + "$//";
                ss = true;
            }
            if ((tim > i && m == word) || (m < word)) {
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
