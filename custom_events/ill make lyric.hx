import flixel.text.FlxText.FlxTextFormat;
import flixel.text.FlxText.FlxTextFormatMarkerPair;
import flixel.util.FlxTimer;

function onCreate() {
	songTxt = new FlxText(0, 600, FlxG.width, "", 48, true);
	// songTxt.font = Paths.getPath("fronts/fnt_main.ttf");
	songTxt.cameras = [game.camOther];
	songTxt.antialiasing = true;
	songTxt.alignment = "center";
	insert(0, songTxt);
}

var word = -1;
var Rstrin = [];
var RstrinNEXT = [];
var blue = new FlxTextFormatMarkerPair(new FlxTextFormat(0xFF0048FF), "$//");
var blueC = new FlxTextFormatMarkerPair(new FlxTextFormat(0xFF1800CF), "&&");

// var r = ~/-/g;
function onEvent(N, v1, v2, T) {
	// v1 = v1*0.9;
	// StringTools.replace(v2,"-"," ");
	v2 = v2.split("-").join("- ");
	RstrinNEXT = [];
	// word = -1;
	var dR = v2.split("\n");
	if (dR[1] == "null")
		dR[1] = dR[0];
	// debugPrint(v2);
	// songTxt.text = dR[0];

	// var tirg:Array = [];

	var d1 = dR[0].split(" ").join("").split("-").join("");
	var d2 = dR[1].split(" ");
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
			} // strin.push([" "," "]);
			// debugPrint(r+" "+d[0].charAt(i));
			strin.push([d[0].charAt(g), r]);
		}
		if (d[1].charAt(d[1].length - 1) != "-")
			strin.push([" ", " "]);
		RstrinNEXT.push(strin);
	}
	// debugPrint(Rstrin);
	// debugPrint(v1/Rstrin.length);
	// FlxTimer.loop(v1/Rstrin.length/1000, (tim) -> {
	//	var s = "$";
	//	for (i in 0...Rstrin.length){
	//		if (tim == i){ s = s + "$";}
	//		if (tim>=i){
	//			s = s + Rstrin[i][1];
	//		}else{
	//			s = s + Rstrin[i][0];
	//		}
	//	}
	//	//debugPrint(s);
	//		songTxt.applyMarkup(s,[blue]);
	//	}, Rstrin.length);
}

var mType = 0;
var flxT;
var flxM;

function opponentNoteHit(daNote) {//требуется пересборка 
	
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
				//return;
			    flxM.cancel();
            flxM = new FlxTimer().start(
                daNote.sustainLength / 1000 + 1,
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
