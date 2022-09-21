package creature;

import io.newgrounds.NG;
import h2d.Interactive;
import hxd.Cursor;
import h2d.filter.Outline;
import h3d.Vector;
import h2d.Text;
import ui.UIAbstracts.ScrollChild;
import graphics.Layer;
import h2d.Object;
import h2d.Tile;
import timing.Timing;
import configs.Config.CreatureConfig;
import ecs.Entity;
import graphics.Animation;
import hxd.Res;
import graphics.RenderObject;
import h2d.Bitmap;
import ecs.System;
import ecs.Universe;
import h2d.filter.Blur;
import ui.UIAbstracts.ScrollLayer;

class CreatureDisplaySystem extends System {
     
     @:fullFamily
     var crDisplay : {
          resources : {
               scroll:ScrollLayer,
               creatures:Array<CreatureConfig>,
               layout:CreatureLayout
          }
     };
     
     @:fastFamily
     var mousers : {
          ro:RenderObject,
		cb:MouseCB,
		_:ScrollChild
     }
     
	@:fullFamily
	var ng : {
		resources : {
			ng:NG
		}
	}
	
     @:fastFamily
     var objs : {
          ro:RenderObject
     }
     
     @:fastFamily
     var events : {
          event:Event
     }
     
     var crEnts:Array<Entity>;
	var largeEnt:Entity;
	var xEnt:Entity;
	var upEnt:Entity;
	var downEnt:Entity;
     
     var hoverIndex:Int;
	
	var titleText:Text;
	var titleEnt:Entity;
	var authorText:Text;
	var authorEnt:Entity;
	var linkInt:Interactive;
     
     final SCALE_DEFAULT:Float = 1.0;
     final SCALE_HOVER:Float = 1.5;
     
     public function new(ecs:Universe) {
          super(ecs);
          
     }
     
     override function onEnabled() {
          super.onEnabled();
          
          events.onEntityAdded.subscribe(handleEvent);
          crDisplay.onActivated.subscribe(createDisplay);
     }
     
     // disposal?
     
     function handleEvent(eventity) {
          
          fetch(events, eventity, {
			
			switch (event) {
                    
                    case CR_HOVER_IN(index):
                         
					if (index < 0 || index >= crEnts.length) return;
                         if (hoverIndex >= 0) hoverOut();
                         
                         var ent = crEnts[index];
                         hoverIndex = index;
                         
					setup(crDisplay, {
						
						var row = Std.int(index / layout.maxCols);
						var col = index % layout.maxCols;
						
						var dx = 0.0, dy = 0.0;
						
						if (layout.scrollRow > row || layout.scrollRow + layout.displayedRows <= row) {
							layout.scrollRow = Std.int(row / layout.displayedRows) * layout.displayedRows;
							dy = -Std.int(layout.scrollRow / layout.displayedRows) * 1080 - scroll.y;
						}
						
						if (layout.scrollCol > col || layout.scrollCol + layout.displayedCols <= col) {
							layout.scrollCol = Std.int(col / layout.displayedCols) * layout.displayedCols;
							dx = -Std.int(layout.scrollCol / layout.displayedCols) * 1920 - scroll.x;
						}
						
						if (dx != 0 || dy != 0) {
							
							var sx = scroll.x, sy = scroll.y;
							
							Timing.tween(universe.createEntity(), 0.5, 1, f -> {
								scroll.x = sx + dx * f;
								scroll.y = sy + dy * f;
								ECS.event(VIS_CHECK);
								// consider changing screen size
							}, () -> {
								ECS.event(ENABLE_INPUT);
								iterate(mousers, {
									cb.enabled = true;
								});
							});
							
							ECS.event(DISABLE_INPUT);
							iterate(mousers, {
								cb.enabled = false;
							});
						}
					});
                         
					fetch(objs, ent, {
                              var tw = ro.sprite.tile.width, th = ro.sprite.tile.height;
                              ro.sprite.x += tw * SCALE_DEFAULT / 2 - tw * SCALE_HOVER / 2;
                              ro.sprite.y += th * SCALE_DEFAULT / 2 - th * SCALE_HOVER / 2;
                              ro.sprite.width = tw * SCALE_HOVER;
                              ro.sprite.height = th * SCALE_HOVER;
                         });
                    
                    case CR_HOVER_OUT:
                         hoverOut();
                    
                    case BLUR_SCENE(enable):
                         setup(crDisplay, {
                              
                              if (enable) {
                                   
                                   var b = new Blur(0, 0.4, 4);
                                   scroll.filter = b;
                                   
                                   Timing.tween(universe.createEntity(), 0.25, f -> {
                                        b.radius = 8 * f;
                                   }); // oncomplete to enable something else?
                              }
                              
                              else {
                                   scroll.filter = null;
                              }
                              
                              0; // for ecs to not break
                         });
                    
				case CR_DISPLAY(index):
					
					select(index);
					
					iterate(mousers, {
						cb.enabled = false;
					});
					
					// shut up
					fetch(objs, xEnt, {
						ro.sprite.visible = true;
					});
					
					fetch(objs, upEnt, {
						ro.sprite.visible = false;
					});
					
					fetch(objs, downEnt, {
						ro.sprite.visible = false;
					});
				
				case CR_HIDE:
					
					fetch(objs, largeEnt, {
						ro.sprite.visible = titleText.visible = authorText.visible = linkInt.visible = false;
						iterate(mousers, {
							cb.enabled = true;
						});
					});
					
					// shut up
					fetch(objs, xEnt, {
						ro.sprite.visible = false;
					});
					
					fetch(objs, upEnt, {
						ro.sprite.visible = true;
					});
					
					fetch(objs, downEnt, {
						ro.sprite.visible = true;
					});
				
				case CR_DISPLAY_CHANGE(index):
					
					select(index);
				
                    default:
               }
          });
     }
     
     function createDisplay(_) {
          
          var anim:Animation, ro:RenderObject;
		var types = ["1a", "1b", "1c", "1d", "1e", "2a", "2b", "2c", "2d", "2e", "3a", "3b", "3c", "3d", "3e"];
          var curr = "";
		var index = -1;
		
		for (i in 0...types.length) {
			index = Std.random(types.length);
			curr = types[index];
			types[index] = types[i];
			types[i] = curr;
		}
		
		index = 0;
		curr = "";
		
          setup(crDisplay, {
               for (i in 0...Math.ceil(creatures.length / layout.maxCols / layout.displayedRows)) {
				
				while (curr.length > 0 && types[index].charAt(1) == curr.charAt(1)) {
					index = (index + 1) % types.length;
				}
				
                    anim = { updater : { } };
                    anim.add("default", {
                         name : "default",
                         frames : [Res.load("bgs/" + types[index] + ".png").toTile()],
                         loop : false
                    });
                    
				curr = types[index];
				index = (index + 1) % types.length;
				
                    anim.play("default");
                    
                    ro = { anim : anim, sprite : new Bitmap(null) };
				
				ro.sprite.tile = ro.anim.currFrame; // this shouldn't be this way, but I realize now rendersys adding directly to s2d isn't great
                    ro.sprite.width = ro.sprite.tile.width; // since there's a blur filter applied to "all of scrolling display but not all of s2d"
                    ro.sprite.height = ro.sprite.tile.height;
				
                    ro.sprite.x = 0;
                    ro.sprite.y = i * 1080 + (1080 - ro.sprite.height) / 2;
                    scroll.addChild(ro.sprite);
                    
                    universe.setComponents(universe.createEntity(), ro, anim, (true:ScrollChild));
               }
          });
          
          // scrolling display
		var cr:Tile;
		
          setup(crDisplay, {
               
			var xs = [178, 612, 1066, 1472, 200, 632, 1016, 1467];
			var ys = [466, 495, 503, 508, 760, 797, 807, 794]; // these are the foot positions
			
               crEnts = [];
               var count = creatures.length;
               var ent:Entity;
               for (i in 0...count) {
				
				if (!creatures[i].exist) {
					crEnts.push(ent = universe.createEntity());
					continue;
				}
				
				cr = Res.load('thumbs/${creatures[i].image}.png').toTile();
				anim = { updater : { } };
				
				anim.add("default", {
					name : "default",
					frames : [cr],
					loop : false
				});
				
				anim.play("default");
                    
                    ro = { anim : anim, sprite : new Bitmap(null) };
				
                    ro.sprite.tile = ro.anim.currFrame;
				ro.sprite.width = ro.sprite.tile.width;
				ro.sprite.height = ro.sprite.tile.height;
				
				// kinda lost the max vs displayed distinction at some point, so this would need to be modified in order to generalize
                    ro.sprite.x = xs[i % (layout.displayedRows * layout.displayedCols)] + (250 - ro.sprite.width) / 2;
                    ro.sprite.y = Std.int(i / layout.maxCols / layout.displayedRows) * 1080 + ys[i % (layout.displayedRows * layout.displayedCols)] - ro.sprite.height;
                    scroll.addChild(ro.sprite);
                    
				var cb:MouseCB = {
					onClick : () -> {
						ECS.event(CR_SELECT);
					},
					onOver : () -> {
						hxd.System.setCursor(Cursor.Button);
						ECS.event(CR_HOVER_IN(i));
					},
					onOut : () -> {
						hxd.System.setCursor(Cursor.Default);
						ECS.event(CR_HOVER_OUT);
					}
				};
				
                    crEnts.push(ent = universe.createEntity());
                    universe.setComponents(ent, ro, anim, cb, (true:ScrollChild));
               }
          });
		
		setup(crDisplay, {
			
			largeEnt = universe.createEntity();
			xEnt = universe.createEntity();
			titleEnt = universe.createEntity();
			authorEnt = universe.createEntity();
			
			var anim:Animation = { updater : { } };
			
			// this takes a while and freezes lower spec computers
			// load on demand instead
			/*
			for (cr in creatures) {
				
				if (!cr.exist) continue;
				
				anim.add(cr.image, {
					frames : [Res.load('sprites/${cr.image}.png').toTile()],
					loop : false
				});
			}
			
			anim.play(creatures[0].image);
			*/
			
			var ro:RenderObject = {
				anim : anim,
				sprite : new Bitmap(null)
			};
			
			// really don't like doing this, but an alternative requires thinking
			// ro.sprite.tile = ro.anim.currFrame;
			// ro.sprite.width = ro.sprite.tile.width;
			// ro.sprite.height = ro.sprite.tile.height;
			
			ro.sprite.visible = false;
			
			universe.setComponents(largeEnt, ro, anim, (ro.sprite:Object), Layer.GAME);
			
			// this is a lot of boilerplate to add a clickable image
			// x to close
			anim = { updater : { } };
			anim.add("default", {
				frames : [Res.load('ui/x.png').toTile()]
			});
			anim.play("default");
			
			ro = {
				anim : anim,
				sprite : new Bitmap(null)
			};
			
			ro.sprite.tile = ro.anim.currFrame;
			ro.sprite.width = ro.sprite.tile.width;
			ro.sprite.height = ro.sprite.tile.height;
			
			ro.sprite.visible = false;
			
			ro.sprite.x = 50;
			ro.sprite.y = 50;
			
			var cb:MouseCB = {
				onClick : () -> {
					ECS.event(STATE_EXIT(POPUP));
					ECS.event(CR_HIDE);
				},
				onOver : () -> {
					hxd.System.setCursor(Cursor.Button);
				},
				onOut : () -> {
					hxd.System.setCursor(Cursor.Default);
				},
				scroll : false
			};
			
			universe.setComponents(xEnt, ro, anim, (ro.sprite:Object), cb, Layer.GAME);
			
			// up arrow
			upEnt = universe.createEntity();
			
			anim = { updater : { } };
			anim.add("default", {
				frames : [Res.load('ui/arrowup.png').toTile()]
			});
			anim.play("default");
			
			ro = {
				anim : anim,
				sprite : new Bitmap(null)
			};
			
			ro.sprite.tile = ro.anim.currFrame;
			ro.sprite.width = ro.sprite.tile.width;
			ro.sprite.height = ro.sprite.tile.height;
			
			ro.sprite.visible = true;
			
			ro.sprite.x = (1920 - ro.sprite.width) / 2;
			ro.sprite.y = 20;
			
			// shut up
			var cb:MouseCB = {
				onClick : () -> {
					ECS.event(CR_FORCE_INDEX(-8));
				},
				onOver : () -> {
					hxd.System.setCursor(Cursor.Button);
				},
				onOut : () -> {
					hxd.System.setCursor(Cursor.Default);
				},
				scroll : false
			};
			
			universe.setComponents(upEnt, ro, anim, (ro.sprite:Object), cb, Layer.GAME);
			
			// up arrow
			downEnt = universe.createEntity();
			
			anim = { updater : { } };
			anim.add("default", {
				frames : [Res.load('ui/arrowdown.png').toTile()]
			});
			anim.play("default");
			
			ro = {
				anim : anim,
				sprite : new Bitmap(null)
			};
			
			ro.sprite.tile = ro.anim.currFrame;
			ro.sprite.width = ro.sprite.tile.width;
			ro.sprite.height = ro.sprite.tile.height;
			
			ro.sprite.visible = true;
			
			ro.sprite.x = (1920 - ro.sprite.width) / 2;
			ro.sprite.y = 1080 - 20 - ro.sprite.height;
			
			// shut up x2
			var cb:MouseCB = {
				onClick : () -> {
					ECS.event(CR_FORCE_INDEX(8));
				},
				onOver : () -> {
					hxd.System.setCursor(Cursor.Button);
				},
				onOut : () -> {
					hxd.System.setCursor(Cursor.Default);
				},
				scroll : false
			};
			
			universe.setComponents(downEnt, ro, anim, (ro.sprite:Object), cb, Layer.GAME);
			
			// text
			var ngf = Res.fonts.ng.toFont();
			
			titleText = new Text(ngf);
			authorText = new Text(ngf);
			
			titleText.x = 20; titleText.y = 600;
			authorText.x = 20;
			
			titleText.maxWidth = authorText.maxWidth = 600;
			titleText.textAlign = authorText.textAlign = Center;
			titleText.visible = authorText.visible = false;
			
			titleText.color = new Vector(255 / 255, 119 / 255, 42 / 255);
			titleText.filter = new Outline(2, 0xffffff, 0.7, true);
			
			authorText.color = new Vector(255 / 255, 14 / 255, 160 / 255);
			authorText.filter = new Outline(2, 0xffffff, 0.7, true);
			
			// this was written before I finished mouse click and no-scroll handling
			linkInt = new Interactive(600, 1);
			linkInt.x = 20; linkInt.y = 600;
			linkInt.visible = false;
			linkInt.onClick = e -> {
				ECS.event(CR_LINK);
			};
			
			universe.setComponents(titleEnt, (titleText:Object), Layer.GAME);
			universe.setComponents(authorEnt, (authorText:Object), Layer.GAME);
			universe.setComponents(universe.createEntity(), (linkInt:Object), Layer.GAME);
		});
		
          // misc
          hoverIndex = -1;
          
          ECS.event(VIS_CHECK);
          ECS.event(CR_HOVER_IN(0));
     }
     
     function hoverOut() {
          
          if (hoverIndex < 0) return;
          var ent = crEnts[hoverIndex];
          
          fetch(objs, ent, {
               var tw = ro.sprite.tile.width, th = ro.sprite.tile.height;
               ro.sprite.x += tw * SCALE_HOVER / 2 - tw * SCALE_DEFAULT / 2;
               ro.sprite.y += th * SCALE_HOVER / 2 - th * SCALE_DEFAULT / 2;
               ro.sprite.width = tw * SCALE_DEFAULT;
               ro.sprite.height = th * SCALE_DEFAULT;
          });
          
          hoverIndex = -1;
     }
	
	function select(index:Int) {
		
		setup(crDisplay, {
			fetch(objs, largeEnt, {
				
				if (index >= creatures.length) return;
				
				if (creatures[index].exist) {
					
					var name = creatures[index].image;
					
					if (!ro.anim.has(name)) {
						ro.anim.add(name, {
							frames : [Res.load('sprites/${name}.png').toTile()],
							loop : false
						});
					}
					
					ro.anim.play(creatures[index].image);
					ro.sprite.visible = titleText.visible = authorText.visible = linkInt.visible = true;
					
					creatures[index].visited = true;
					
					ro.sprite.tile = ro.anim.currFrame;
					ro.sprite.width = ro.sprite.tile.width;
					ro.sprite.height = ro.sprite.tile.height;
					
					// give enough space in bottom right for title and author
					// center sprite in remaining space
					ro.sprite.x = (1920 + 360 - ro.sprite.width) / 2;
					ro.sprite.y = (1080 - ro.sprite.height) / 2;
					
					titleText.text = "\"" + creatures[index].title + "\"";
					authorText.text = "by " + creatures[index].artist;
					authorText.y = titleText.y + titleText.textHeight + 20;
					
					linkInt.height = authorText.y + authorText.textHeight - titleText.y;
				}
				
				else {
					ro.sprite.visible = titleText.visible = authorText.visible = linkInt.visible = false;
				}
				
				iterate(mousers, {
					cb.enabled = false; // probably doesn't need to loop here
				});
				
				setup(ng, {
					
					if (!ng.medals.getById(70528).unlocked) {
						
						var unlock = true;
						for (cr in creatures) {
							if (cr.exist && cr.medal && !cr.visited) {
								unlock = false;
								break;
							}
						}
						
						if (unlock) {
							ng.medals.getById(70528).sendUnlock();
						}
					}
					
					if (!ng.medals.getById(70677).unlocked && creatures[creatures.length - 1].visited) {
						ng.medals.getById(70677).sendUnlock();
					}
				});
			});
		});
	}
     
     override function update(dt:Float) {
          super.update(dt);
          
     }
}