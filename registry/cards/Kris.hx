//package registry.cards;
import mikolka.compatibility.freeplay.FreeplaySongData;
import mikolka.compatibility.freeplay.FreeplayHelpers;
import backend.StageData;
import backend.Highscore;
import backend.Song;
import backend.Mods;
import states.LoadingState;

function introDone() {
    var data = new FreeplaySongData(10, "test", "bf", FlxColor.fromRGB(0, 0, 0));
    trace(data);
    backingCard.instance.songs.push(data);
    
}
function confirm() {
    backingCard.instance.styleData = {"getStartDelay":()->{return 2000;}};
    new FlxTimer().start(1, function(tmr:FlxTimer)
		{
            try{
                var data = {
                    "folder":"Delta3SongMinigame",
                    "loadAndGetDiffId":()->{return -1;},
                    "getNativeSongId":()->{return "loadCharts";}
                };
                var st = {
                    "persistentUpdate":true,
                };
                //trace(Type.getClassFields(Type.getClass(new FreeplayHelpers())));
                backingCard.instance.persistentUpdate = false;
		        Mods.currentModDirectory = "Delta3SongMinigame";
                var songLowercase:String = Paths.formatToSongPath("loadCharts");
		        var poop:String = Highscore.formatSong(songLowercase, 1);
                trace(poop);
                PlayState.SONG = Song.loadFromJson(poop, songLowercase);
                if(PlayState.SONG == null) throw "Song parsing failed!";
                PlayState.isStoryMode = false;
                PlayState.storyDifficulty = 0;

                var directory = StageData.forceNextDirectory;
                LoadingState.loadNextDirectory();
                StageData.forceNextDirectory = directory;
                LoadingState.loadAndSwitchState(new PlayState(), true);
			//new FreeplayHelpers().moveToPlaystate(st, data, "",null);
                PlayState.SONG.song = "tutorialus    (infinity)";//song name
                PlayState.SONG.format = "deltarun 3 MiniGame" +"^"+ "play";// mod name + dificult
            }catch(e:Dynamic){trace(e);}
		});
    
}