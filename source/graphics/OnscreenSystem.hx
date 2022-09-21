package graphics;

import ui.UIAbstracts.ScrollChild;
import ecs.Universe;
import ecs.System;
import graphics.RenderObject;
import ui.UIAbstracts.ScrollLayer;

class OnscreenSystem extends System {
     
     @:fullFamily
     var objs : {
          resources : {
               scroll:ScrollLayer
          },
          requires : {
               ro:RenderObject,
			_:ScrollChild
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
                    
                    case VIS_CHECK:
                         
                         setup(objs, {
                              
                              final sx = 0.0, sy = 0.0, sw = 1920, sh = 1080;
                              var oox = scroll.x, ooy = scroll.y, ox = 0.0, oy = 0.0, ow = 0.0, oh = 0.0;
						
                              iterate(objs, {
                                   
                                   ox = ro.sprite.x + oox;
                                   oy = ro.sprite.y + ooy;
                                   ow = ro.sprite.width;
                                   oh = ro.sprite.height;
                                   
                                   ro.sprite.visible = !(sx + sw < ox || sy + sh < oy || ox + ow < sx || oy + oh < sy);
                              });
                         });
                    
                    default:
               }
          });
     }
}