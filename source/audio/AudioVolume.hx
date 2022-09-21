package audio;

@:structInit @:publicFields
class AudioVolume {
	var master:Float = 1;
	var music:Float = 1;
	var sfx:Float = 1;
	var voice:Float = 1;
	
	var musicMult(get, never):Float;
	var sfxMult(get, never):Float;
	var voiceMult(get, never):Float;
	
	inline function get_musicMult() { return master * music; }
	inline function get_sfxMult() { return master * sfx; }
	inline function get_voiceMult() { return master * voice; }
}