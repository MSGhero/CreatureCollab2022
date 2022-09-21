package graphics;

import h3d.Engine;
import ui.UIAbstracts.Scale;
import ecs.Entity;
import h2d.Scene;
import ecs.Universe;
import ecs.System;
import h2d.Object;
import input.Input;

class RenderSystem extends System {
	
	// animated objects
	@:fullFamily
	var sprites : {
		requires : {
			sprite:RenderObject
		}
	}
	
	// anything added to the screen besides UI
	@:fullFamily
	var display : {
		resources : {
			scene:Scene
		},
		requires : {
			obj:Object,
			layer:Layer
		}
	}
	
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
	
	var toBeAdded:Array<Entity>;
	
	public function new(ecs:Universe) {
		super(ecs);
		
		toBeAdded = [];
	}
	
	override function onEnabled() {
		display.onEntityAdded.subscribe(addToScene);
		display.onEntityRemoved.subscribe(removeFromScene);
		
		events.onEntityAdded.subscribe(handleEvent);
	}
	
	function handleEvent(eventity) {
          
          fetch(events, eventity, {
			
			switch (event) {
                    case RESIZE(scale):
					universe.setResources((scale:Scale));
                    default:
               }
          });
     }
	
	function addToScene(entity) {
		// delay add until next update to align with render timings
		toBeAdded.push(entity);
		fetch(sprites, entity, {
			// set immediately to populate wh
			
			if (sprite.anim.hasStarted) {
				sprite.sprite.tile = sprite.anim.currFrame;
				sprite.sprite.width = sprite.sprite.tile.width;
				sprite.sprite.height = sprite.sprite.tile.height;
			}
		});
	}
	
	function removeFromScene(entity) {
		
		setup(display, {
			fetch(display, entity, {
				scene.removeChild(obj);
			});
		});
	}
	
	override function update(dt:Float) {
		super.update(dt);
		
		if (toBeAdded.length > 0) {
			
			setup(display, {
				
				for (entity in toBeAdded) {
					fetch(display, entity, {
						scene.add(obj, layer);
					});
				}
			});
			
			toBeAdded.splice(0, toBeAdded.length);
		}
		
		iterate(sprites, {
			if (sprite.sprite.visible) sprite.sprite.tile = sprite.anim.currFrame;
		});
		
		iterate(inputs, {
			
			if (input.actions.justPressed.getAction(FULLSCREEN)) {
				
				var engine = Engine.getCurrent();
				
				if (engine.fullScreen) {
					engine.fullScreen = false;
					ECS.event(RESIZE(0.5));
				}
				
				else {
					engine.fullScreen = true;
					ECS.event(RESIZE(1.0));
				}
			}
		});
	}
}