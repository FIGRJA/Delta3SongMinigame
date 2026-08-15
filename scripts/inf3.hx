if (PlayState.SONG.stage!="D3Main") return;
//package scripts;
import backend.Controls;
var Control = Controls.instance;


var isAllowed:Bool = game.songName == "tutorialus-- --(infinity)";
var isTutor:Bool = (game.songName.lastIndexOf("tutorialus")==0);


function setVF(Var,Fun,?AsFun) {
    AsFun ??= Fun;
	if (getVar(Var).exists(Fun))
		this.set(AsFun,getVar(Var).get(Fun));
	
}

var notes =[];
function onCreatePost() {
    isTutor = (game.songName.lastIndexOf("tutorialus")==0);
    if (!isTutor) return;
    game.camGame.scroll.y = game.camFollow.y-2500;
    setVF("load_delta_notes","addFastNote");
    setVF("D3Main","onCreate","reloadSongs");
    setVF("D3Main","onSectionHit","reloadBPM");
    setVF("D3Main","getLV","getLVD3");
    setVF("D3Main","setLV","setLVD3");
    setVF("load_delta_notes","getLV","getLVldn");
    setVF("load_delta_notes","setLV","setLVldn");
    setVF("D3Main","getSong");
    var maxTime = 32842;
    //debugPrint("hi test 3 "+maxTime);
    notes = game.unspawnNotes.copy();
    game.unspawnNotes = [];
    for (n in notes){
        if (n.strumTime<2000&&!n.isSustainNote)
            addFastNote((n.strumTime+maxTime)/1000,n.noteData,(n.sustainLength+n.strumTime+maxTime)/1000,n.animSuffix == '-alt',n.noteType);

    }
    notes = notes.concat(game.unspawnNotes);
    game.unspawnNotes = [];
    setLVldn("notesAnval",[""=>""]) ;
    for (n in notes){
        //if (n.strumTime<3000)
        if (!n.isSustainNote)
            addFastNote((n.strumTime)/1000,n.noteData,(n.sustainLength+n.strumTime)/1000,n.animSuffix == '-alt',n.noteType);
            //notes.push(n);
        //}
    }
    game.unspawnNotes.sort(function(a, b) {
			return a.strumTime - b.strumTime;
		});
        //debugPrint(notes.length);
    //onStartCountdown();
//setVF("songMenu","loadSongsLists");
    isAllowed = game.songName == "tutorialus-- --(infinity)";
    if (!isAllowed) return;
    game.botplayTxt.visible = true;
	game.cpuControlled = true;
}
function onStartCountdowns() {
    if (!isTutor) return;
//setVF("D3Main","onCreate");
    //var maxTime = game.inst.length;
    //debugPrint(game.unspawnNotes.length);
    notes = game.unspawnNotes.copy();
    //notes = game.unspawnNotes.copy();
    //game.endCallback = onEndSong;
    FlxG.sound.music.onComplete = onEndSong;
    game.startCountdown();
    Conductor.songPosition = -3000;
}
var kek = false;
var BAlpha = 1;
function onUpdate(e) {
    isTutor = (game.songName.lastIndexOf("tutorialus")==0);
    if (!isTutor) return;
    if (FlxG.sound.music.time +(e*1000)> game.inst.length)
        onEndSong();
    //susiRofls )= false;
    setLVD3("susiRofls",false);
    isAllowed = game.songName == "tutorialus-- --(infinity)";
    if (!isAllowed) return;
    //debugPrint( game.inst.length);
    if ((Control.PAUSE||Control.ACCEPT)&&!kek){
        PlayState.SONG.song = "songChart";//mini rofls ))
        kek = true;
        game.unspawnNotes = [];
        //FlxTween.num(Conductor.songPosition, Conductor.songPosition-3000, 2,  null,num -> Conductor.songPosition = num );
        FlxTween.num(1, 0, 2,  null,num ->  BAlpha = num );
        FlxTween.num(1, 0, 2,  null,num ->  game.inst.volume = num );
        FlxTween.num(1, 0, 2,  null,num ->  game.vocals.volume = num );
        new FlxTimer().start(2,()->{
            game.botplayTxt.visible = false;
            svP();
        });
    }
}
function onUpdatePost(e) {
    if (!isAllowed)
		return;
    game.botplayTxt.alpha = BAlpha;
}

function svP() 
{
    Conductor.songPosition = -2000;
    new FlxTimer().start(2,()->{
        //game.note = [];
        try {
            //setLVD3("SCORE.text","lox");
            getLVD3("SCOREText").text = "lox";
            getLVD3("maxCombo").text = "000000";
            setLVD3("songScore",0);
            getLVD3("susiCombo").text = "0";
            getLVD3("krisCombo").text = "0";
            getLVD3("ralsCombo").text = "0";
            game.inst.loadEmbedded(getSong(getLVD3("moddir"),PlayState.SONG.gameOverLoop));
            game.vocals.loadEmbedded(getSong(getLVD3("moddir"),PlayState.SONG.gameOverEnd));
            FlxG.sound.music = game.inst;
            //FlxG.sound.music.onComplete = 
        } catch (e:Dynamic) {trace(e);}
        startSong();
        //game.inst.time = 0;
        //game.inst.play();
        //game.vocals.time = 0;
        //game.vocals.play();
    });
        reloadBPM();
    game.cpuControlled = false;
    FlxG.sound.music.stop();
    game.vocals.stop();
    game.canResync = false;

    PlayState.SONG.song = "practice";//song name
    PlayState.SONG.format = "deltarun 3 MiniGame" +"^"+ "play";// mod name + dificult
    game.songName = "practice";
    game.unspawnNotes = [];
    reloadSongs();
    game.startCountdown();
    //isAllowed = false;
}

function onEndSong() {
    if (!isTutor) return;
    Conductor.songPosition = 0;
    //setSongTime(0);
    //FlxG.sound.music.stop();
    FlxG.sound.music.time = 0;
    FlxG.sound.music.play();
    game.vocals.time = 0;
    game.vocals.play();
    //debugPrint(notes.length);

    game.unspawnNotes = [];

    setLVldn("notesAnval",[""=>""]) ;
    for (n in notes){
        //if (n.strumTime<3000){
        if (!n.isSustainNote)
            addFastNote((n.strumTime)/1000,n.noteData,(n.sustainLength+n.strumTime)/1000,n.animSuffix == '-alt',n.noteType);
            //notes.push(n);
        //}
    }
    game.unspawnNotes.sort(function(a, b) {
        return a.strumTime - b.strumTime;
    });
    //game.unspawnNotes = notes.copy();
    //onCreate();
}


function onDestroy() {}