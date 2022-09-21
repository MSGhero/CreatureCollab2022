package graphics.fx;

import ecs.Universe;
import ecs.System;
import h2d.Object;

class FXSystem extends System {
	
	@:fastFamily
	var objs : {
		obj:Object
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
		// maybe cleanup refs onRemove?
	}
	
	override function onDisabled() {
		events.onEntityAdded.unsubscribe(handleEvent);
		// maybe cleanup refs onRemove?
	}
	
	function handleEvent(eventity) {
		
		fetch(events, eventity, {
			
			switch (event) {
				
				case FX_FADE(entity, from, to, dur, onComplete):
					
					fetch(objs, entity, {
						
						ECS.event(UPDATER(
							entity,
							new FadeAlpha(
								obj,
								from, to, dur,
								onComplete
							)
						));
					});
					
				case FX_FLICKER(entity, from, to, dur, count, onComplete):
					
					fetch(objs, entity, {
						
						ECS.event(UPDATER(
							entity,
							new Flicker(
								obj,
								from, to, dur, count,
								onComplete
							)
						));
					});
					
				case FX_FLASH(entity, color, dur, count, onComplete):
					
					fetch(objs, entity, {
						
						ECS.event(UPDATER(
							entity,
							new Flash(
								obj,
								color, dur, count,
								onComplete
							)
						));
					});
					
				case FX_COLOR(entity, color, dur, count, onComplete):
					
					fetch(objs, entity, {
						
						ECS.event(UPDATER(
							entity,
							new Color(
								obj,
								color, dur, count,
								onComplete
							)
						));
					});
					
				default:
			}
		});
	}
}
