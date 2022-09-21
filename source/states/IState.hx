package states;

import ecs.Universe;
import graphics.Spritesheet;

interface IState {
	var active(default, null):Bool;
	var universe(default, null):Universe;
	function onEnter(sheet:Spritesheet):Void;
	function onExit():Void;
}