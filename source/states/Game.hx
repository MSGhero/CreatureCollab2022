package states;

import creature.CreatureLayout;
import json2object.JsonParser;
import hxd.Res;
import graphics.Spritesheet;
import configs.Config;

class Game implements IState {
	
	public var active(default, null):Bool;
	public var universe(default, null):Universe;
	
	public function new(universe) {
		active = false;
		this.universe = universe;
	}
	
	public function onEnter(sheet:Spritesheet) {
		
		active = true;
		
		var parser = new JsonParser<Config>();
		var creatures = parser.fromJson(Res.CreatureCollab2022.entry.getText(), "assets/CreatureCollab2022.json").creatures;
		var layout:CreatureLayout = {
			maxRows : Math.ceil(creatures.length / 4),
			maxCols : 4,
			displayedRows : 2,
			displayedCols : 4
		};
		
		universe.setResources(creatures, layout);
	}
	
	public function onExit() {
		active = false;
	}
}