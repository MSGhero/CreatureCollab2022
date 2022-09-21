package states;

import graphics.Spritesheet;

class Popup implements IState {
	
	public var active(default, null):Bool;
	public var universe(default, null):Universe;
	
	public function new(universe) {
		active = false;
		this.universe = universe;
	}
	
	public function onEnter(sheet:Spritesheet) {
		
		active = true;
		
		ECS.event(BLUR_SCENE(true));
	}
	
	public function onExit() {
		active = false;
		ECS.event(BLUR_SCENE(false));
	}
}