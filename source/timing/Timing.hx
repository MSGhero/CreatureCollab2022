package timing;

import ecs.Entity;

class Timing {
	
	public static function every(entity:Null<Entity>, dur:Float, reps:Int = -1, callback:() -> Void, onComplete:() -> Void = null) {
		
		var ev:Updater = {
			duration : dur,
			repetitions : reps,
			callback : callback,
			onComplete : onComplete
		};
		
		if (entity != null) ECS.event(UPDATER(entity, ev));
		
		return ev;
	}
	
	public static function delay(entity:Null<Entity>, dur:Float, onComplete:() -> Void) {
		
		var del:Updater = {
			duration : dur,
			repetitions : 1,
			onComplete : onComplete
		};
		
		if (entity != null) ECS.event(UPDATER(entity, del));
		
		return del;
	}
	
	// maybe make TweenerProps<T> that has from<T> to<T> dur onComplete ease, etc
	public static function tween(entity:Null<Entity>, dur:Float, reps:Int = 1, onUpdate:(f:Float) -> Void, onComplete:() -> Void = null) {
		
		var tw:Tweener = {
			duration : dur,
			repetitions : reps,
			onUpdate : onUpdate,
			onComplete : onComplete
		};
		
		if (entity != null) ECS.event(UPDATER(entity, tw));
		
		return tw;
	}
	
	public static function cycle(entity:Null<Entity>, updaters:UpdaterList, overallReps:Int = -1) {
		
		var cycle:Cycler = {
			updaters : updaters,
			updaterReps : [for (up in updaters) up.repetitions],
			repetitions : overallReps
		};
		
		if (entity != null) ECS.event(UPDATER(entity, cycle));
		
		return cycle;
	}
	
	public static function schedule(entity:Null<Entity>, onComplete:() -> Void = null) {
		
		var scheduler:Scheduler = {
			repetitions : 1,
			onComplete : onComplete
		};
		
		if (entity != null) ECS.event(UPDATER(entity, scheduler));
		
		return scheduler.init();
	}
	
	// cooldowner?
	// replenisher?
}