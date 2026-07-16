if (PlayState.SONG.stage!="D3Main") return;
import lime.app.Application;
import lime.ui.Window;
import lime.graphics.RenderContext;
import openfl.display.Stage;
import openfl.Lib;
import mikolka.funkin.custom.NativeFileSystem as NativeFileSystem;
import lime.graphics.opengl.GL;
//import lime.graphics.opengl.GLShader;

var window = Application.current.window;
var stage = Lib.current.stage;
var R = window.onRender;


function getShader(shaderName){
	var vert = testShader(shaderName+".vert");
	var frag = testShader(shaderName+".frag");
    trace(shaderName);
	trace(vert!=null);
	trace(frag!=null);
	//if (!game.runtimeShaders.exists(shaderName))
	//	game.runtimeShaders.set(shaderName,[frag,vert]);
	//return new FlxRuntimeShader(frag,vert);
    if (vert!=null)
        return GLShader.fromSources(GL,vert,GL.VERTEX_SHADER);
    if (frag!=null)
        return GLShader.fromSources(GL,frag,GL.FRAGMENT_SHADER);
}
function testShader(shaderName){
	var shader = Paths.getPath("shaders/"+shaderName);
	if (NativeFileSystem.exists(shader))
		    return NativeFileSystem.getContent(shader);
	return null;
}


function removeAlala(p) {
		var i = R.__listeners.length;
    while (--i >= 0)
		{
			if (R.__priorities[i]>=p)
			{
				R.__listeners.splice(i, 1);
				R.__priorities.splice(i, 1);
				R.__repeat.splice(i, 1);
			}
		}
}
//removeAlala(1);

//var s = getShader("grayT");

var fun = function(context:RenderContext) {
    // Принудительно очищаем фон с прозрачностью
    //#if (lime >= "8.0.0")
    //if (context.type == OPENGL) {
        var gl = context.gl;
        gl.clearColor(255.0, 0.0, 0.0, 10.0);  // прозрачный цвет очистки
        gl.clear(gl.COLOR_BUFFER_BIT);
        //gl.enable(gl.BLEND);
        //gl.enable(gl.ALPHA_TEST);       
        //gl.enable(gl.DEPTH_TEST);       
        //gl.enable(gl.COLOR_MATERIAL);
        //gl.enable(gl.LIGHTING);         
        //gl.enable(gl.LIGHT0);  
        //gl.blendFunc(0x0302, 0x0303);
    //}
    //#end
    //trace("1");
    // Затем стандартный рендер Flixel
    // (нужно вызвать обычную отрисовку)
    //FlxG.game.stage.__render(context);
        //gl.compileShader(s);
}


//R.removeAll();
//if (R.__priorities.length>2) return;
// Делаем фон прозрачным через onRender
if (R.has(fun)){
    R.remove(fun);
}
//R.add(fun,false,1);
//debugPrint(R.__priorities);
function onDestroy() {
    //R.remove(fun);
}


var filter:Array<String> = [
	'You Suck!',
	'Shit',
	'Bad',
	'Bruh',
	'Meh',
	'Nice',
	'Good',
	'Great',
	'Sick!',
	'Perfect!!'
];

function getStaticVar(tag:String) {
	for (i in filter)
		if (i[0] == tag) {
			trace("getStaticVar: not allowed " + tag, FlxColor.RED);
			return null;
		}
	for (i in PlayState.ratingStuff)
		if (i[0] == tag)
			return i[1];
	return null;
}

//trace(PlayState.ratingStuff);
function setStaticVar(tag:String, varis:Dynamic) {
	for (i in filter)
		if (i[0] == tag) {
			trace("setStaticVar: not allowed " + tag, FlxColor.RED);
			return;
		}
	for (i in PlayState.ratingStuff)
		if (i[0] == tag) {
			i[1] = varis;
			return;
		}
	PlayState.ratingStuff.insert(-1, [tag, varis]);
}

setVar("extraVar",this);
