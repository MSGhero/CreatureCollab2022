package;

import audio.AudioProps;
import states.States;
import audio.AudioProps.AudioType;
import timing.Updater;
import ecs.Entity;

enum Event {
	
	STATE_ENTER(name:States);
	STATE_EXIT(name:States);
	
	AUDIO_START(props:AudioProps);
	AUDIO_STOP(fadeDur:Float, type:AudioType);
	AUDIO_STOP_ALL;
	
	UPDATER(entity:Entity, updater:Updater);
	UPDATER_PAUSE(entity:Entity);
	UPDATER_RESUME(entity:Entity);
	UPDATER_COMPLETE(entity:Entity);
	UPDATER_CANCEL(entity:Entity);
	
	FX_FADE(entity:Entity, from:Float, to:Float, dur:Float, onComplete:()->Void);
	FX_FLICKER(entity:Entity, from:Bool, to:Bool, dur:Float, count:Int, onComplete:()->Void);
	FX_FLASH(entity:Entity, color:Int, dur:Float, count:Int, onComplete:()->Void);
	FX_COLOR(entity:Entity, color:Int, dur:Float, count:Int, onComplete:()->Void);
	
	DISABLE_INPUT;
	ENABLE_INPUT;
	
	CR_SELECT;
	CR_HOVER_IN(index:Int);
	CR_HOVER_OUT;
	CR_DISPLAY(index:Int);
	CR_DISPLAY_CHANGE(index:Int);
	CR_HIDE;
	CR_LINK;
	CR_FORCE_INDEX(shift:Int);
	
	RESIZE(scale:Float);
	BLUR_SCENE(enable:Bool);
	
	VIS_CHECK;
	
	DEBUG(entity:Entity);
}