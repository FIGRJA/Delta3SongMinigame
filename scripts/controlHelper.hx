//package scripts,
if (PlayState.SONG.stage!="D3Main") return;
import Reflect;
import backend.Controls;

var CustomControls = {
    // from https://github.com/HaxeFlixel/flixel/blob/master/flixel/input/keyboard/FlxKey.hx
	"ANY" : -2,
	"--" : -1,
	"[A]" : 65,
	"[B]" : 66,
	"[C]" : 67,
	"[D]" : 68,
	"[E]" : 69,
	"[F]" : 70,
	"[G]" : 71,
	"[H]" : 72,
	"[I]" : 73,
	"[J]" : 74,
	"[K]" : 75,
	"[L]" : 76,
	"[M]" : 77,
	"[N]" : 78,
	"[O]" : 79,
	"[P]" : 80,
	"[Q]" : 81,
	"[R]" : 82,
	"[S]" : 83,
	"[T]" : 84,
	"[U]" : 85,
	"[V]" : 86,
	"[W]" : 87,
	"[X]" : 88,
	"[Y]" : 89,
	"[Z]" : 90,
	"[0]" : 48,
	"[1]" : 49,
	"[2]" : 50,
	"[3]" : 51,
	"[4]" : 52,
	"[5]" : 53,
	"[6]" : 54,
	"[7]" : 55,
	"[8]" : 56,
	"[9]" : 57,
	"PAGEUP" : 33,
	"PAGEDOWN" : 34,
	"HOME" : 36,
	"END" : 35,
	"INSERT" : 45,
	"ESCAPE" : 27,
	"[-]" : 189,
	"[+]" : 187,
	"DELETE" : 46,
	"BACKSPACE" : 8,
	"LBRACKET" : 219,
	"RBRACKET" : 221,
	"BACKSLASH" : 220,
	"CAPSLOCK" : 20,
	"SCROLL_LOCK" : 145,
	"NUMLOCK" : 144,
	"SEMICOLON" : 186,
	"QUOTE" : 222,
	"ENTER" : 13,
	"SHIFT" : 16,
	"[,]" : 188,
	"PERIOD" : 190,
	"[/]" : 191,
	"GRAVEACCENT" : 192,
	"CONTROL" : 17,
	"ALT" : 18,
	"SPACE" : 32,
	"UP" : 38,
	"DOWN" : 40,
	"LEFT" : 37,
	"RIGHT" : 39,
	"TAB" : 9,
	"WIN" : 15,
	"MENU" : 302,
	"PRINTSCREEN" : 301,
	"BREAK" : 19,
	"[F1]" : 112,
	"[F2]" : 113,
	"[F3]" : 114,
	"[F4]" : 115,
	"[F5]" : 116,
	"[F6]" : 117,
	"[F7]" : 118,
	"[F8]" : 119,
	"[F9]" : 120,
	"[F10]" : 121,
	"[F11]" : 122,
	"[F12]" : 123,
	"[#0]" : 96,
	"[#1]" : 97,
	"[#2]" : 98,
	"[#3]" : 99,
	"[#4]" : 100,
	"[#5]" : 101,
	"[#6]" : 102,
	"[#7]" : 103,
	"[#8]" : 104,
	"[#9]" : 105,
	"[#-]" : 109,
	"[#+]" : 107,
	"[#PERIOD]" : 110,
	"[#*]" : 106,
	"[#/]" : 111
};

function CustomStr2int(str) {
    return Reflect.field(CustomControls,str); 
}

function CustomInt2str(int) {
    for (str in Reflect.fields(CustomControls)){
        if (CustomStr2int(str)==int)
            return str;
    }
}
var controls = {
    // from https://github.com/HaxeFlixel/flixel/blob/master/flixel/input/keyboard/FlxKey.hx
	"ANY" : -2,
	"NONE" : -1,
	"A" : 65,
	"B" : 66,
	"C" : 67,
	"D" : 68,
	"E" : 69,
	"F" : 70,
	"G" : 71,
	"H" : 72,
	"I" : 73,
	"J" : 74,
	"K" : 75,
	"L" : 76,
	"M" : 77,
	"N" : 78,
	"O" : 79,
	"P" : 80,
	"Q" : 81,
	"R" : 82,
	"S" : 83,
	"T" : 84,
	"U" : 85,
	"V" : 86,
	"W" : 87,
	"X" : 88,
	"Y" : 89,
	"Z" : 90,
	"ZERO" : 48,
	"ONE" : 49,
	"TWO" : 50,
	"THREE" : 51,
	"FOUR" : 52,
	"FIVE" : 53,
	"SIX" : 54,
	"SEVEN" : 55,
	"EIGHT" : 56,
	"NINE" : 57,
	"PAGEUP" : 33,
	"PAGEDOWN" : 34,
	"HOME" : 36,
	"END" : 35,
	"INSERT" : 45,
	"ESCAPE" : 27,
	"MINUS" : 189,
	"PLUS" : 187,
	"DELETE" : 46,
	"BACKSPACE" : 8,
	"LBRACKET" : 219,
	"RBRACKET" : 221,
	"BACKSLASH" : 220,
	"CAPSLOCK" : 20,
	"SCROLL_LOCK" : 145,
	"NUMLOCK" : 144,
	"SEMICOLON" : 186,
	"QUOTE" : 222,
	"ENTER" : 13,
	"SHIFT" : 16,
	"COMMA" : 188,
	"PERIOD" : 190,
	"SLASH" : 191,
	"GRAVEACCENT" : 192,
	"CONTROL" : 17,
	"ALT" : 18,
	"SPACE" : 32,
	"UP" : 38,
	"DOWN" : 40,
	"LEFT" : 37,
	"RIGHT" : 39,
	"TAB" : 9,
	"WINDOWS" : 15,
	"MENU" : 302,
	"PRINTSCREEN" : 301,
	"BREAK" : 19,
	"F1" : 112,
	"F2" : 113,
	"F3" : 114,
	"F4" : 115,
	"F5" : 116,
	"F6" : 117,
	"F7" : 118,
	"F8" : 119,
	"F9" : 120,
	"F10" : 121,
	"F11" : 122,
	"F12" : 123,
	"NUMPADZERO" : 96,
	"NUMPADONE" : 97,
	"NUMPADTWO" : 98,
	"NUMPADTHREE" : 99,
	"NUMPADFOUR" : 100,
	"NUMPADFIVE" : 101,
	"NUMPADSIX" : 102,
	"NUMPADSEVEN" : 103,
	"NUMPADEIGHT" : 104,
	"NUMPADNINE" : 105,
	"NUMPADMINUS" : 109,
	"NUMPADPLUS" : 107,
	"NUMPADPERIOD" : 110,
	"NUMPADMULTIPLY" : 106,
	"NUMPADSLASH" : 111
};

function str2int(str) {
    return Reflect.field(controls,str); 
}

function int2str(int) {
    for (str in Reflect.fields(controls)){
        if (str2int(str)==int)
            return str;
    }
}


var isAllowed:Bool = PlayState.SONG.song != "songChart";
var isTutorial:Bool = game.songName == "tutorialus----(infinity)";

var keyboardBinds = Controls.instance.keyboardBinds;
var keySprites = [
    new FlxText(208,100,90,CustomInt2str(keyboardBinds["note_left"][0] ),30),
    new FlxText(208,125,90,CustomInt2str(keyboardBinds["note_left"][1] ),30),
    new FlxText(378,100,90,CustomInt2str(keyboardBinds["note_right"][0]),30),
    new FlxText(378,125,90,CustomInt2str(keyboardBinds["note_right"][1]),30),
];

function onCreate() {
    for (s in 0...keySprites.length){
        var sp = keySprites[s];
        sp.cameras = [game.camGame]; 
        sp.camera = game.camGame; 
        sp.font = Paths.getPath("fronts/fnt_main.ttf");
        sp.alignment = s<=1?"right":"left";
        add(sp);
    }
}
var upTime = 0;
var tweenRemover = true;//isTutorial
function onUpdate(e) {
        upTime += e;
    if (upTime>5&&!tweenRemover){
        for (sp in keySprites){
            FlxTween.tween(sp, {alpha: 0}, 1);
        }
        tweenRemover = true;
    }
    if (keySprites[0].alpha>0){
        for (sp in keySprites){
            if (FlxG.keys.anyPressed([CustomStr2int(sp.text)])){
                if (sp.color == 0xFFFFFF){
                    sp.y += 3;
                    sp.color = 0xFFEA2F;
                }
            }else{
                if (sp.color == 0xFFEA2F){
                    sp.y += -3;
                    sp.color = 0xFFFFFF;
                }
            }
        }
    }
    
}