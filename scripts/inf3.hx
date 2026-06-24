//package scripts;

var isAllowed:Bool = game.songName == "tutorialus";


function setVF(Var,Fun) {
	if (getVar(Var).exists(Fun))
		this.set(Fun,getVar(Var).get(Fun));
	
}

var notes =[];
function onCreatePost() {
    if (!isAllowed)
		return;
    setVF("load_delta_notes","addFastNote");
    var maxTime = 32842;
    debugPrint("hi test 3 "+maxTime);
    notes = game.unspawnNotes.copy();
    game.unspawnNotes = [];
    for (n in notes){
        if (n.strumTime<2000)
            addFastNote((n.strumTime+maxTime)/1000,n.noteData,(n.sustainLength+n.strumTime+maxTime)/1000,n.animSuffix == '-alt',n.noteType);

    }
    notes = notes.concat(game.unspawnNotes);
    game.unspawnNotes = [];
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
}
function onStartCountdowns() {
    if (!isAllowed)
		return;
setVF("D3Main","onCreate");
    //var maxTime = game.inst.length;
    debugPrint(game.unspawnNotes.length);
    notes = game.unspawnNotes.copy();
    //notes = game.unspawnNotes.copy();
    //game.endCallback = onEndSong;
    FlxG.sound.music.onComplete = onEndSong;
    game.startCountdown();
    Conductor.songPosition = -3000;
}
function onUpdate(e) {
    if (!isAllowed)
		return;
    //debugPrint( game.inst.length);
    if (FlxG.sound.music.time +(e*1000)> game.inst.length)
        onEndSong();
}
function onEndSong() {
    if (!isAllowed)
		return;
        Conductor.songPosition = 0;
        //setSongTime(0);
        //FlxG.sound.music.stop();
        FlxG.sound.music.time = 0;
        FlxG.sound.music.play();
        game.vocals.time = 0;
        game.vocals.play();
        debugPrint(notes.length);

        game.unspawnNotes = [];
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