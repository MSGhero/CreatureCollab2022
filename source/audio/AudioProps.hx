package audio;

@:structInit @:publicFields
class AudioProps {
	var type(default, null):AudioType;
	var loop(default, null):Bool = false;
	var fadeDur(default, null):Float = 0;
	var position(default, null):Float = 0;
}

enum AudioType {
	MUSIC(name:String);
	SFX(name:String);
	UI(name:String);
}