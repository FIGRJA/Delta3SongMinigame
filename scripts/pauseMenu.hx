if (PlayState.SONG.stage!="D3Main") return;
import backend.Controls;
import backend.MusicBeatState;
import psychlua.CustomSubstate;
import flixel.addons.display.FlxBackdrop;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxTimer;
import flixel.sound.FlxSound;
import mikolka.vslice.StickerSubState;
import mikolka.vslice.freeplay.FreeplayState;
import flixel.addons.transition.FlxTransitionableState;

function setVF(Var,Fun) {
	if (getVar(Var).exists(Fun))
		this.set(Fun,getVar(Var).get(Fun));
	
}

var pauseBG:FlxCamera = new FlxCamera(-700, -100, 700, 1500, 1);
var stunAction = false;
var isPause:Bool = false;
var Control = Controls.instance;
var backed:FlxBackdrop;
var backTimer:FlxText;
var timer:Float;
var freeAction:Array = [];
var inst:FlxSound;

function onCreatePost() {

setVF("endScreen","playSnd");
	pauseBG.angle = -10;
	FlxG.cameras.insert(pauseBG,3, false);
	// pauseBG.visible =false;
	// pauseBG.x = -400;
}

function onUpdate(e) {
	game.canPause = false;
	if (Control.PAUSE && PlayState.SONG.song != "songChart")
		CustomSubstate.openCustomSubstate('DeltaPause', true);
	if (Control.CHAR_SELECT && PlayState.SONG.song == "songChart"){
		playSnd("splat");
		MusicBeatState.resetState();}
	if (Control.FAVORITE && PlayState.SONG.song != "songChart"){
		playSnd("crowd_cheer_single");
		CustomSubstate.openCustomSubstate('END', true);}
}

function onCustomSubstateCreate(name) {
	isPause = name == "DeltaPause";
	if (!isPause)
		return;
	timer = 0.2;
	stunAction = false;

	backTimer = new FlxText(0, 0, 350, "3", 250, true);
	backTimer.font = Paths.getPath("fronts/fnt_main.ttf");
	backTimer.cameras = [game.camOther];
	// susiCombo.scale.y = 4;
	backTimer.screenCenter(0x11); // XY
	backTimer.antialiasing = false;
	backTimer.alignment = "center";
	backTimer.visible = false;
	customSubstate.add(backTimer);

	// pauseBG.visible =true;
	backed = new FlxBackdrop();

	backed.antialiasing = false;
	// backed.loadGraphic(Paths.image("anim/tv"));
	backed.frames = Paths.getSparrowAtlas("anim/tv");
	backed.velocity.set(-100 * 35 / 36, 100 * 37 / 36);
	backed.scale.set(3, 3);
	backed.animation.addByPrefix("pog", 'spr_dw_tv_starbgtile_', 16);
	backed.animation.play('pog', true);
	backed.camera = pauseBG;
	customSubstate.add(backed);

	for (act in ["restart", PlayState.SONG.format != "psych_v1_convert"?"toMenu":"!⚠custom⚠!", "exit"]) {
		var action = new FlxText(0, 0, 500, act, 130, true);
		action.font = Paths.getPath("fronts/fnt_main.ttf");
		action.cameras = [pauseBG];
		action.angle = 10;
		// action.screenCenter(0x11);//XY
		action.x = 200;
		action.y = action.y + freeAction.length * 100 + 600;
		action.antialiasing = false;
		action.alignment = "left";
		customSubstate.add(action);
		freeAction.push(action);
	}
	try {
		// debugPrint(FlxG.sound.list);
		if (inst == null) {
			inst = new FlxSound();
			inst.loadEmbedded(Paths.returnSound("greenroom_detune", "mus"), true);
			inst.volume = 0;
			inst.play();
			FlxG.sound.list.add(inst);
		}
		inst.fadeIn(2);
	} catch (e:Dynamic) {}
}

var curAction:Int = 0;

function onCustomSubstateCreatePost(name) {
	if (!isPause)
		return;
	FlxTween.tween(pauseBG, {x: -120, alpha: 1}, 0.2, {ease: FlxEase.circOut});
	for (i in 0...freeAction.length) {
		FlxTween.tween(freeAction[i], {y: 450 + i * 100 - curAction * 100, alpha: 1 - (Math.abs(curAction - i) / 4)}, 0.2, {ease: FlxEase.circOut});
	}
}

function onCustomSubstateUpdate(name, e) {
	if (!isPause)
		return;
	if (timer > 0) {
		timer -= e;
		return;
	}
	// debugPrint("lol");
	if (Control.BACK) {

		playSnd("splat");
		timer = 4;
		//FlxTween.tween(pauseBG, {x: -700, alpha: 0}, 60 / Conductor.bpm, {ease: FlxEase.circOut});
		FlxTween.tween(pauseBG, {x: -700, alpha: 0}, 0.5, {ease: FlxEase.circOut});
		backTimer.visible = true;
		FlxTimer.loop(0.5, (tim) -> {
			backTimer.text = 3 - tim;
			if (tim == 3)
				CustomSubstate.closeCustomSubstate();
		}, 4);

		inst.fadeOut(1.5, 0, () -> {
			inst.pause();
		});
	}
	if (Control.ACCEPT) {

		playSnd("coin");
		switch (freeAction[curAction].text) {
			case "restart":
                FlxTransitionableState.skipNextTransIn = false;
			    FlxTransitionableState.skipNextTransOut = false;
				MusicBeatState.startTransition();
			// PlayState.nextReloadAll = true;
			case "toMenu":
				PlayState.SONG.song = "songChart";
				// FlxG.sound.music.destroy();
				MusicBeatState.startTransition();
			// PlayState.nextReloadAll = true;
			case "exit":
				CustomSubstate.closeCustomSubstate();
				PlayState.deathCounter = 0;
				PlayState.seenCutscene = false;

				PlayState.instance.canResync = false;
				PlayState.changedDifficulty = false;
				PlayState.chartingMode = false;
				FlxG.camera.followLerp = 0;
				if (FlxG.sound.music != null) {
					FlxG.sound.music.pause();
					PlayState.instance.vocals.pause();
				}
				openSubState(new StickerSubState(null, (sticker) -> FreeplayState.build(null, sticker)));
		}
		inst.fadeOut(1);
	}
	if (Control.UI_UP) {
		curAction -= 1;
		timer = 0.15;
		playSnd("bump");
	}
	if (Control.UI_DOWN) {
		curAction += 1;
		timer = 0.15;
		playSnd("bump");
	}
	curAction = Math.abs(freeAction.length + curAction) % freeAction.length;
	// debugPrint("                                                           "+curAction);
	if (timer > 0)
		for (i in 0...freeAction.length) {
			FlxTween.tween(freeAction[i], {y: 450 + i * 100 - curAction * 100, alpha: 1 - (Math.abs(curAction - i) / 4)}, 0.2, {ease: FlxEase.circOut});

			// freeAction[i].y = ;
		}
}

function onCustomSubstateDestroy(name) {
	if (!isPause)
		return;
	isPause = false;
	backTimer.destroy();
	backed.destroy();
	// pauseBG.visible =false;
	for (act in freeAction)
		act.destroy();
	freeAction = [];
	pauseBG.x = -700;
}

function onDestroy() {}