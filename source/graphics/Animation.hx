package graphics;

import haxe.ds.StringMap;
import h2d.Tile;
import timing.Updater;

@:structInit
class Animation {
	
	public var updater:Updater;
	
	public var frames(get, never):Array<Tile>;
	inline function get_frames() { return currAnim.frames; }
	
	public var index(default, null):Int = 0;
	
	public var currFrame(get, never):Tile;
	inline function get_currFrame() { return frames[index]; }
	
	public var paused(get, never):Bool;
	inline function get_paused() { return updater.paused; }
	
	public var name(get, never):String;
	inline function get_name() { return currAnim.name; }
	
	public var hasStarted(get, never):Bool;
	inline function get_hasStarted() { return currAnim != null; }
	
	var anims:StringMap<AnimData> = new StringMap();
	var currAnim:AnimData = null;
	var next:Array<String> = [];
	
	public function add(name:String, anim:AnimData) {
		anims.set(name, anim);
		anim.name = name;
		return this;
	}
	
	public inline function has(name:String) {
		return anims.exists(name);
	}
	
	public function play(name:String, overrideNext:Bool = true) {
		
		currAnim = anims.get(name);
		index = 0;
		
		if (currAnim == null) throw '$name anim not found';
		
		updater.resetCounter();
		updater.paused = false;
		updater.duration = 1 / currAnim.fps;
		updater.repetitions = currAnim.loop ? -1 : frames.length;
		
		if (overrideNext && next.length > 0) {
			next.splice(0, next.length);
		}
	}
	
	public function playFrom(name:String, index:Int) {
		play(name);
		this.index = index % frames.length;
	}
	
	public function replay() {
		index = 0;
		if (!currAnim.loop) updater.repetitions = frames.length;
		updater.resetCounter();
	}
	
	public inline function pause() {
		updater.paused = true;
	}
	
	public inline function resume() {
		updater.paused = false;
	}
	
	public inline function chain(nextAnim:String) {
		next.push(nextAnim);
	}
	
	public function advance() {
		if (currAnim == null) return;
		if (currAnim.loop)
			index = (index + 1) % frames.length;
		else if (index + 1 < frames.length)
			index++;
		else if (next.length > 0)
			play(next.shift(), false);
	}
}

@:structInit @:publicFields
private class AnimData {
	var name:String = "";
	var frames:Array<Tile>;
	var loop:Bool = true;
	var fps:Float = 1;
}

@:structInit @:publicFields
class AnimationCallback {
	var cachedName:String = "";
	var cachedIndex:Int = -1;
	var callback:(anim:Animation)->Void;
}