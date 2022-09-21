package creature;

@:structInit @:publicFields
class MouseCB {
	var enabled:Bool = true;
	var onOver:()->Void = null;
	var onOut:()->Void = null;
	var onClick:()->Void = null;
	var scroll:Bool = true; // this shouldn't be here... tbh mouse should use some aabb system that is given l2g coords
}