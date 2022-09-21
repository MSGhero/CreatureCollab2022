package input;

@:structInit @:publicFields
class Input {
	var actions:ActionSet;
	var previous:ActionSet;
	var devices:Array<InputDevice>;
	var enabled:Bool = true;
}

abstract InputMapping(Array<Array<Int>>) {

	public function new() this = [];

	@:op([])
	public function get(action:Actions) {
		return this[action];
	}

	@:op([])
	public function set(action:Actions, mapping:Array<Int>) {
		return this[action] = mapping;
	}
}