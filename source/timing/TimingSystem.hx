package timing;

import ecs.Entity;
import ecs.Universe;
import ecs.System;

class TimingSystem extends System {
	
	@:fastFamily
	var timings : {
		updaters:UpdaterList
	}
	
	@:fastFamily
	var events : {
		event:Event
	}
	
	public function new(ecs:Universe) {
		super(ecs);
		
	}
	
	override function onEnabled() {
		events.onEntityAdded.subscribe(handleEvent);
	}
	
	override function onDisabled() {
		events.onEntityAdded.unsubscribe(handleEvent);
	}
	
	function handleEvent(eventity) {
		
		fetch(events, eventity, {
			
			var ups:UpdaterList;
			
			switch(event) {
				
				case UPDATER(entity, updater):
					
					ups = getUpdaters(entity);
					ups.push(updater);
					
				case UPDATER_PAUSE(entity):
				
					ups = getUpdaters(entity);
					for (up in ups) up.paused = true;
					
				case UPDATER_RESUME(entity):
					
					ups = getUpdaters(entity);
					for (up in ups) up.paused = false;
					
				case UPDATER_COMPLETE(entity):
					
					ups = getUpdaters(entity);
					for (up in ups) up.forceComplete();
					
				case UPDATER_CANCEL(entity):
					
					ups = getUpdaters(entity);
					for (up in ups) up.cancel();
					
				default:
			}
		});
	}
	
	function getUpdaters(entity:Entity) {
		
		var ups = null;
		
		fetch(timings, entity, {
			ups = updaters;
		});
		
		if (ups == null) {
			ups = new UpdaterList();
			universe.setComponents(entity, ups);
		}
		
		return ups;
	}
	
	override function update(dt:Float) {
		super.update(dt);
		
		iterate(timings, {
			
			for (updater in updaters) {
				
				if (updater.repetitions == 0) {
					updater.dispose();
					updaters.remove(updater);
				}
				
				else {
					updater.update(dt);
				}
			}
		});
	}
}