package creature;

import input.Input;
import ui.UIAbstracts.Scale;
import ecs.Entity;
import hxd.Window;
import ecs.System;
import graphics.RenderObject;
import ecs.Universe;
import ui.UIAbstracts.ScrollLayer;

class MouseSystem extends System {
     
	@:fullFamily
     var mousers : {
          resources : {
               scroll:ScrollLayer,
			input:Input
          },
          requires : {
               ro:RenderObject,
			cbs:MouseCB
          }
     };
     
     @:fullFamily
     var windowInfo : {
          resources : {
               scale:Scale
          }
     };
     
     @:fastFamily
     var events : {
          event:Event
     }
     
     var mx:Float;
     var my:Float;
     
     var currentOver:Entity;
     
     public function new(ecs:Universe) {
          super(ecs);
          
          mx = my = 0;
          
          currentOver = Entity.none;
     }
     
     override function onEnabled() {
          super.onEnabled();
          
          Window.getInstance().addEventTarget(checkMove);
          
          events.onEntityAdded.subscribe(handleEvent);
     }
     
     function handleEvent(eventity) {
          
          fetch(events, eventity, {
			
			switch (event) {
                    // I don't think hoverin needs to be handled? 
                    case CR_HOVER_OUT:
                         currentOver = Entity.none;
                    default:
               }
          });
     }
     
     function checkMove(e:hxd.Event) {
          
          switch (e.kind) {
               case EMove:
				setup(windowInfo, {
					mx = e.relX / (scale:Float);
					my = e.relY / (scale:Float);
				});
               default:
          }
     }
     
     override function update(dt:Float) {
          super.update(dt);
          
		setup(mousers, {
			
			var oox = 0.0, ooy = 0.0, ox = 0.0, oy = 0.0, ow = 0.0, oh = 0.0;
			var overs = [];
			iterate(mousers, entity -> {
				
				if (!ro.sprite.visible || !cbs.enabled) continue;
				
				oox = cbs.scroll ? scroll.x : 0;
				ooy = cbs.scroll ? scroll.y : 0;
				
				ox = ro.sprite.x + oox;
				oy = ro.sprite.y + ooy;
				ow = ro.sprite.width;
				oh = ro.sprite.height;
				
				if (mx >= ox && mx < ox + ow && my >= oy && my < oy + oh) {
					overs.push(entity);
				}
			});
			
			if (currentOver != Entity.none && input.actions.justPressed.getAction(CLICK)) {
				
				fetch(mousers, currentOver, {
					if (cbs.onClick != null) cbs.onClick();
				});
			}
			
			if (currentOver != Entity.none && !overs.contains(currentOver)) {
				
				fetch(mousers, currentOver, {
					if (cbs.onOut != null) cbs.onOut();
				});
				
				currentOver = Entity.none; // also gets set in event handler for hoverout
			}
			
			if (currentOver == Entity.none && overs.length > 0) {
				var ent = overs[0];
				fetch(mousers, ent, {
					if (cbs.onOver != null) cbs.onOver();
				});
				
				currentOver = ent;
			}
		});
     }
}