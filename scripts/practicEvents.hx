if (PlayState.SONG.stage!="D3Main") return;
//package scripts;


var isAllowed:Bool = game.songName == "practice";

function onCreate() {
    if (!isAllowed) return;

		game.skipCountdown = true;
}
function onCreatePost() {
    //if (!isAllowed) return;
	//game.inst.pause();
	//game.vocals	.pause();
    
	//game.camGame.scroll.y = game.camFollow.y-2500;
		//game.startingSong = false;
}
function onUpdate(e) {
    
}

function onDestroy() {}