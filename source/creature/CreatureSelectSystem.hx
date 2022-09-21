package creature;

import ecs.System;
import ecs.Universe;
import configs.Config.CreatureConfig;
import input.Input;

class CreatureSelectSystem extends System {
	
	@:fullFamily
	var crSelection : {
		resources : {
			input:Input,
			layout:CreatureLayout,
			creatures:Array<CreatureConfig>
		}
	}
	
	@:fastFamily
	var events : {
		event:Event
	}
	
	var crRow:Int;
	var crCol:Int;
	
	var inPopup:Bool; // need a better way to do this
	
	public function new(ecs:Universe) {
		super(ecs);
		
		crRow = crCol = 0;
		inPopup = false;
	}
	
	override function onEnabled() {
		super.onEnabled();
		
		events.onEntityAdded.subscribe(handleEvent);
	}
	
	function handleEvent(eventity) {
		
		fetch(events, eventity, {
			
			switch (event) {
				
				case CR_FORCE_INDEX(shift):
					
					setup(crSelection, {
						ECS.event(CR_HOVER_IN(crRow * layout.maxCols + crCol + shift));
					});
				
				case CR_HOVER_IN(index):
					// in case hover was caused by something external, like the mouse or an event
					setup(crSelection, {
						
						if (index < 0 || index >= creatures.length) return;
						
						var rr = Std.int(index / layout.maxCols);
						var cc = index % layout.maxCols;
						
						// this is kinda useless, but in principle it should be here to handle external changes (mouse)
						if (rr == crRow && cc == crCol) return;
						
						crRow = rr;
						crCol = cc;
					});
				
				case CR_LINK:
					
					setup(crSelection, {
						var index = crRow * layout.maxCols + crCol;
						var creature = creatures[index];
						
						if (creature != null && creature.exist) {
							hxd.System.openURL(creature.profile);
						}
					});
				
				case CR_DISPLAY(index):
					inPopup = true;
				
				case CR_HIDE:
					inPopup = false;
				
				case CR_SELECT:
					
					setup(crSelection, {
						
						var index = crRow * layout.maxCols + crCol;
						var creature = creatures[index];
						
						if (creature != null && creature.exist) {
							ECS.event(STATE_ENTER(POPUP));
							ECS.event(CR_DISPLAY(index)); // kinda belongs in popup, but don't have the index there
							// should become a resource maybe?
						}
					});
					
				default:
			}
		});
	}
	
	override function update(dt:Float) {
		super.update(dt);
		
		setup(crSelection, {
			
			var s = input.actions.justPressed.getAction(SELECT);
			
			if (s) {
				
				var index = crRow * layout.maxCols + crCol;
				
				if (index < creatures.length) {
					ECS.event(STATE_ENTER(POPUP));
					ECS.event(CR_DISPLAY(index)); // kinda belongs in popup, but don't have the index there
					// should become a resource maybe?
				}
			}
			
			var ds = input.actions.justPressed.getAction(DESELECT);
			
			if (ds) {
				ECS.event(STATE_EXIT(POPUP));
				ECS.event(CR_HIDE);
			}
			
			var link = input.actions.justPressed.getAction(LINK);
			
			if (link && inPopup) {
				ECS.event(CR_LINK);
			}
			
			var l = input.actions.justPressed.getAction(L);
			var r = input.actions.justPressed.getAction(R);
			var u = input.actions.justPressed.getAction(U);
			var d = input.actions.justPressed.getAction(D);
			
			if (l && r) l = r = false;
			if (u && d) u = d = false;
			
			if (l || r || u || d) {
				
				var prevIndex = crRow * layout.maxCols + crCol;
				
				if (l) {
					if (--crCol < 0) crCol += layout.maxCols;
				}
				
				if (r) {
					if (++crCol >= layout.maxCols) crCol = 0;
				}
				
				if (u) {
					if (--crRow < 0) crRow = 0;
				}
				
				if (d) {
					if (++crRow >= layout.maxRows) crRow = layout.maxRows - 1;
				}
				
				var currIndex = crRow * layout.maxCols + crCol;
				
				if (currIndex != prevIndex) {
					ECS.event(CR_HOVER_OUT);
					ECS.event(CR_HOVER_IN(currIndex));
					if (inPopup) ECS.event(CR_DISPLAY_CHANGE(currIndex));
				}
			}
		});
	}
}