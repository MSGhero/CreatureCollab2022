package input;

import ecs.Universe;
import ecs.System;

class InputSystem extends System {
	
	@:fullFamily
	var inputs : {
		requires : {
			input:Input
		}
	};
	
	@:fastFamily
	var events : {
		event:Event
	};
	
	public function new(ecs:Universe) {
		super(ecs);
		
	}
	
	override function onEnabled() {
		super.onEnabled();
		
		events.onEntityAdded.subscribe(handleEvent);
	}
	
	function handleEvent(eventity) {
		
		fetch(events, eventity, {
			switch (event) {
				case DISABLE_INPUT:
					iterate(inputs, {
						input.enabled = false;
					});
				case ENABLE_INPUT:
					iterate(inputs, {
						input.enabled = true;
					});
				default:
			}
		});
	}
	
	override function update(dt:Float) {
		super.update(dt);
		
		// reset on focus lost or something?
		
		iterate(inputs, {
			
			input.previous.copyFrom(input.actions);
			
			for (i in 0...input.actions.pressed.length)
				input.actions.pressed[i] = false;
			
			if (input.enabled) {
				
				for (device in input.devices) {
					
					for (i in 0...input.actions.pressed.length) {
						if (input.actions.pressed[i]) continue;
						input.actions.pressed[i] = device.getStatus(i);
					}
				}
			}
			
			input.actions.updateJust(input.previous);
		});
	}
}