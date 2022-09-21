package input;

enum abstract Actions(Int) from Int to Int {
	
	var L;
	var R;
	var U;
	var D;
	
	var SELECT;
	var DESELECT;
	var CLICK;
	var LINK;
	
	var DEBUG;
	var MUTE;
	var VOL_DOWN;
	var VOL_UP;
	
	var FULLSCREEN;
}