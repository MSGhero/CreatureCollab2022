package states;

import ecs.Universe;
import ecs.System;
import graphics.Spritesheet;
import input.Input;

class StateSystem extends System {
	
	@:fullFamily
	var info : {
		resources : {
			sheet:Spritesheet
		},
		requires : {
			input:Input
		}
	}
	
	@:fastFamily
	var events : {
		event:Event
	}
	
	var states:Array<IState>;
	
	var game:Game;
	var popup:Popup;
	var title:Title;
	
	public function new(ecs:Universe) {
		super(ecs);
		
		game = new Game(ecs);
		popup = new Popup(ecs);
		title = new Title(ecs);
		
		states = [game, popup, title];
	}
	
	override function onEnabled() {
		super.onEnabled();
		
		events.onEntityAdded.subscribe(handleEvent);
	}
	
	function handleEvent(eventity) {
		
		fetch(events, eventity, {
			
			switch (event) {
				
				case STATE_ENTER(name):
					
					setup(info, {
						
						var st = switch(name) {
							case GAME: game;
							case POPUP: popup;
							case TITLE: title;
							default: null;
						};
						
						if (st == null) throw '$name is an invalid state';
						if (!st.active) st.onEnter(sheet);
					});
					
				case STATE_EXIT(name):
					
					setup(info, {
						
						var st = switch(name) {
							case GAME: game;
							case POPUP: popup;
							case TITLE: title;
							default: null;
						};
						
						if (st == null) throw '$name is an invalid state';
						if (st.active) st.onExit();
					});
					
				default:
			}
		});
	}
	
	override function update(dt:Float) {
		super.update(dt);
		
		if (title != null && title.active) {
			
			iterate(info, {
				if (input.actions.justPressed.getAction(SELECT)) {
					ECS.event(STATE_EXIT(TITLE));
					ECS.event(STATE_ENTER(GAME));
				}
			});
		}
	}
}