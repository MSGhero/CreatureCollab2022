package;

import io.newgrounds.NG;
import hxd.Res;
import h2d.Bitmap;
import utils.ResTools;
import ui.UIAbstracts.ScrollLayer;
import input.MouseInput;
import audio.AudioVolume;
import hxd.snd.Manager;
import timing.Timing;
import timing.Updater;
import graphics.Layer;
import graphics.Animation;
import graphics.Spritesheet;
import input.PadInput;
import hxd.Window;
import haxe.ds.Vector;
import input.Actions;
import hxd.Key;
import h2d.Object;
import input.Input;
import input.ActionSet;
import ecs.Universe;
import hxd.App;
import graphics.AnimSystem;
import input.InputSystem;
import input.KeyboardInput;
import graphics.RenderSystem;
import graphics.fx.FXSystem;
import utils.ListEnumAbstract;
import timing.TimingSystem;
import states.StateSystem;
import audio.AudioSystem;
import creature.CreatureSelectSystem;
import creature.CreatureDisplaySystem;
import graphics.OnscreenSystem;
import creature.MouseSystem;
import ecs.Phase;

class Main extends App {
	
	var ecs:Universe;
	
	var updateLoop:Updater;
	var renderLoop:Updater;
	
	var updateFPS:Int = 60;
	var renderFPS:Int = 60;
	
	var updatePhase:Phase;
	
	var lastStamp:Float;
	
	var preloadBM:Bitmap;
	var ngMedals:Bool; // how should this fit into ecs? NG.core as a resource makes sense, but login occurs before ecs init
	
	static function main() {
		#if !js
		Res.initPak();
		#end
		new Main();
	}
	
	override function init() {
		
		isDisposed = true; // to skip mainLoop/update calls before things have loaded
		ngMedals = false;
		
		// ng login
		// maybe put login info in pak file to obfuscate a bit
		NG.createAndCheckSession("55175:zWvcjvYy");
		NG.core.setupEncryption("d851whGY6Ub633pQhlmaRw==");
		
		if (!NG.core.loggedIn) {
			NG.core.requestLogin(
				out -> {
					if (out.match(SUCCESS)) postLogin();
					else NG.core.onLogin.addOnce(postLogin);
				}
			);
		}
		
		// preloader's title says loading, title's says press whatever to continue
		// js doesn't go to title, so it loads into game directly after
		
		#if !js
		// new Bitmap(Res.preloader.background.toTile(), s2d);
		realInit();
		#else
		// pak related stuff
		preloadBM = null;
		ResTools.initPakAuto("preload", () -> {
			new Bitmap(Res.preloader.background.toTile(), s2d);
			
			preloadBM = new Bitmap(Res.preloader.title.toTile(), s2d);
			preloadBM.x = (1920 - preloadBM.tile.width) / 2;
			preloadBM.y = (1080 - preloadBM.tile.height) / 2;
		}, p -> { });
		
		// this actually replaces the preload pak in Res. ideally i would be able to choose to merge or replace
		ResTools.initPakAuto("assets", () -> {
			#if !js
			s2d.removeChild(preloadBM);
			preloadBM = null;
			#end
			realInit();
		}, p -> { });
		
		#end
	}
	
	function realInit() {
		
		isDisposed = false;
		
		engine.backgroundColor = 0xff000000;
		
		// possible that this should go before the preloader
		ecs = Universe.create({
			entities : 200,
			phases : [
				{
					name : "update",
					systems : [
						StateSystem,
						InputSystem,
						AudioSystem,
						CreatureSelectSystem,
						MouseSystem,
						CreatureDisplaySystem,
						OnscreenSystem,
						FXSystem,
						RenderSystem, // render before animate to actually show frame 0 of the anim before it advances
						TimingSystem,
						AnimSystem
					]
				}
			]
		});
		
		updatePhase = ecs.getPhase("update");
		
		ECS.eventity = ecs.createEntity();
		ECS.ecs = ecs;
		
		var sheet = new Spritesheet();
		// load data
		
		var mapping = new InputMapping();
		
		mapping[Actions.L] = [Key.LEFT, Key.A, Key.J];
		mapping[Actions.R] = [Key.RIGHT, Key.D, Key.L];
		mapping[Actions.U] = [Key.UP, Key.W, Key.I];
		mapping[Actions.D] = [Key.DOWN, Key.S, Key.K];
		
		mapping[Actions.SELECT] = [Key.Z];
		mapping[Actions.DESELECT] = [Key.X];
		mapping[Actions.LINK] = [Key.SPACE];
		
		mapping[Actions.VOL_DOWN] = [Key.QWERTY_MINUS, Key.NUMBER_9];
		mapping[Actions.VOL_UP] = [Key.QWERTY_EQUALS, Key.NUMBER_0];
		mapping[Actions.MUTE] = [Key.M];
		
		// mapping[Actions.FULLSCREEN] = [Key.F];
		
		var padMapping = new InputMapping();
		
		padMapping[Actions.L] = [PadButtons.LEFT_DPAD, PadButtons.LEFT_L_VIRTUAL];
		padMapping[Actions.R] = [PadButtons.RIGHT_DPAD, PadButtons.RIGHT_L_VIRTUAL];
		padMapping[Actions.U] = [PadButtons.UP_DPAD, PadButtons.UP_L_VIRTUAL];
		padMapping[Actions.D] = [PadButtons.DOWN_DPAD, PadButtons.DOWN_L_VIRTUAL];
		
		padMapping[Actions.SELECT] = [PadButtons.A];
		padMapping[Actions.DESELECT] = [PadButtons.B];
		padMapping[Actions.LINK] = [PadButtons.Y];
		
		padMapping[Actions.VOL_DOWN] = [PadButtons.LT, PadButtons.LB];
		padMapping[Actions.VOL_UP] = [PadButtons.RT, PadButtons.RB];
		padMapping[Actions.MUTE] = [PadButtons.X];
		
		var mouseMapping = new InputMapping();
		
		// mouseMapping[Actions.U] = [Key.MOUSE_WHEEL_UP]; // these are weird in heaps. need a leash timer for "scrolling" vs "delta'd 1 by 1"
		// mouseMapping[Actions.D] = [Key.MOUSE_WHEEL_DOWN];
		
		mouseMapping[Actions.CLICK] = [Key.MOUSE_LEFT];
		mouseMapping[Actions.DESELECT] = [Key.MOUSE_RIGHT];
		
		var input:Input = {
			actions : new ActionSet(),
			previous : new ActionSet(),
			devices : [
				new KeyboardInput(
					mapping,
					new Vector(ListEnumAbstract.count(Actions))
				),
				new PadInput(
					padMapping,
					new Vector(ListEnumAbstract.count(Actions))
				),
				new MouseInput(
					mouseMapping,
					new Vector(ListEnumAbstract.count(Actions))
				)
			]
		};
		
		ecs.setComponents(ecs.createEntity(), input);
		
		// some of this could move into Game
		var scroll:ScrollLayer = new Object();
		ecs.setComponents(ecs.createEntity(), (scroll:Object), Layer.GAME);
		
		var volume:AudioVolume = {
			master : 0.5,
			music : 0.8,
			sfx : 0.6,
			voice : 1
		};
		
		if (ngMedals) ecs.setResources(NG.core);
		
		ecs.setResources(s2d, sheet, scroll, input, Manager.get(), volume);
		
		lastStamp = haxe.Timer.stamp();
		
		updateLoop = Timing.every(null, 1 / updateFPS, onUpdate); // prepUpdate?
		
		renderLoop = Timing.every(null, 1 / renderFPS, prepRender);
		s2d.setElapsedTime(1 / renderFPS);
		
		s2d.scaleMode = Stretch(1920, 1080); // internal resolution is 1920x1080 for crisper art. downscales to 960x540 by default	
		onResize();
		
		var positions = [0, 4383587, 7752209]; // there are 4 tracks mixed into one ogg, so this starts the track at the beginning of a random track
		
		#if !js
		ECS.event(STATE_ENTER(TITLE));
		ECS.event(AUDIO_START({ type : MUSIC("bgmusic"), loop : true, position : positions[Std.random(positions.length)] / 44100 }));
		#else
		// delay startup on js to allow frame 0 to render before slamming it with assets
		var ent = ecs.createEntity();
		Timing.delay(ent, 0.5, () -> {
			// the timing api for dummy ents could be improved
			ECS.event(STATE_ENTER(GAME));
			s2d.removeChild(preloadBM);
			ECS.event(AUDIO_START({ type : MUSIC("bgmusic"), loop : true, position : positions[Std.random(positions.length)] / 44100 }));
			ecs.deleteEntity(ent);
			preloadBM = null;
		});
		#end
	}

	override function mainLoop() {
		
		var newTime = haxe.Timer.stamp();
		var dt = newTime - lastStamp;
		lastStamp = newTime;
		
		if (isDisposed) return;
		
		update(dt);
	}
	
	override function onResize() {
		super.onResize();
		
		// ideally this would be in a system, but I am tired
		final screen = Window.getInstance();
		final scale = Math.min(screen.width / 1920, screen.height / 1080);
		
		ECS.event(RESIZE(scale));
	}
	
	override function update(dt:Float) {
		
		hxd.Timer.update();
		
		updateLoop.update(dt); // game logic
		renderLoop.update(dt); // render
	}
	
	function onFrame() { }
	
	function onUpdate() {
		// pre post prep?
		sevents.checkEvents();
		updatePhase.update(1 / updateFPS);
	}
	
	function prepRender() {
		
		if (!engine.begin()) return;
		
		onRender();
		engine.end();
	}
	
	function onRender() {
		
		s2d.render(engine);
		
		// trace("draw calls: " + engine.drawCalls); // need a nice fps/mem debug panel
	}
	
	function postLogin() {
		trace("logged in");
		NG.core.requestMedals(out2 -> {
			if (out2.match(SUCCESS)) {
				trace("got medals");
				ngMedals = true;
				if (!NG.core.medals.getById(70676).unlocked) NG.core.medals.getById(70676).sendUnlock();
				if (ecs != null) {
					ecs.setResources(NG.core);
					ngMedals = false;
				}
			}
		});
	}
}