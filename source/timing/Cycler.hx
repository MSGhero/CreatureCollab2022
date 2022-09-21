package timing;

import timing.Updater;

@:structInit
class Cycler extends Updater {
	
	public var updaters:Array<Updater>;
	public var updaterReps:Array<Int>; // copies from here after the first runthrough
	public var index(default, null):Int = 0;
	
	override function dispose() {
		super.dispose();
		
		if (updaters != null) {
			for (up in updaters) up.dispose();
			updaters = null;
		}
	}
	
	override function cancel() {
		super.cancel();
		
		if (updaters != null) {
			for (up in updaters) up.cancel();
		}
	}
	
	override function forceCallback() {
		
		if (callback != null) callback();
		
		updaters[index].resetCounter();
		++index;
		
		if (index >= updaters.length) {
			
			if (repetitions > 0) {
				--repetitions;
				if (repetitions == 0 && onComplete != null) onComplete();
			}
			
			index -= updaters.length;
			resetUpdaters();
		}
	}
	
	override function update(dt:Float) {
		
		if (changed) changed = false;
		
		if (isActive) {
			
			updaters[index].update(dt);
			
			if (updaters[index].repetitions == 0) {
				
				++index;
				
				if (index >= updaters.length) {
					
					if (callback != null) callback();
					
					if (repetitions > 0) {
						--repetitions;
						if (repetitions == 0 && onComplete != null) onComplete();
					}
					
					index -= updaters.length;
					resetUpdaters();
				}
			}
			
			changed = true;
		}
	}
	
	function resetUpdaters() {
		
		for (i in 0...updaters.length) {
			updaters[i].resetCounter();
			updaters[i].repetitions = updaterReps[i];
		}
	}
	
	override function incrementCounter(dt:Float) { }
	override function decrementCounter(dt:Float) { }
}