//package scripts;

var isAllowed:Bool = game.songName == "test(3)";


function setVF(Var,Fun) {
	if (getVar(Var).exists(Fun))
		this.set(Fun,getVar(Var).get(Fun));
	
}

function onCreatePost() {
    if (!isAllowed)
		return;
    game.startCallback = onStart;
//setVF("songMenu","loadSongsLists");
}
var notes ;
function onStart() {
setVF("load_delta_notes","addFastNote");
setVF("D3Main","onCreate");
    var maxTime = game.inst.length;
    debugPrint(game.unspawnNotes.length);
    notes = game.unspawnNotes.copy();
    for (n in notes){
        if (n.strumTime<3000){
            addFastNote((n.strumTime+maxTime)/1000,n.noteData,(n.sustainLength+n.strumTime)/1000,n.noteType,n.animSuffix == '-alt');
            //notes.push(n);
        }
    }
    notes = game.unspawnNotes.copy();
    game.endCallback = onEndSong;
    game.startCountdown();
    Conductor.songPosition = -1000;
}
function onUpdate(e) {
    if (!isAllowed)
		return;
    if (FlxG.sound.music.time +10000> game.inst.length)
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
        //game.unspawnNotes = notes.copy();
        onCreate();
}