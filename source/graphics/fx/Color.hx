package graphics.fx;

import graphics.shaders.ForceColorShader;
import h2d.filter.Group;
import hxsl.Types.Vec;
import h2d.filter.Shader;
import h2d.Object;
import timing.Updater;

@:forward
abstract Color(Updater) to Updater {
	
	public function new(obj:Object, color:Int, dur:Float, count:Int, onComplete:()->Void = null) {
		
		var cs = new ForceColorShader();
		cs.color = new Vec(((color >> 16) & 0xff) / 255, ((color >> 8) & 0xff) / 255, (color & 0xff) / 255, ((color >> 24) & 0xff) / 255);
		cs.active = true;
		var shader = new Shader<ForceColorShader>(cs);
		(cast obj.filter:Group).add(shader);
		
		var reps = count * 2 - 1;
		
		this = {
			duration : dur / reps,
			repetitions : reps,
			callback : () -> {
				cs.active = !cs.active;
			},
			onComplete : () -> {
				(cast obj.filter:Group).remove(shader);
				if (onComplete != null) onComplete();
			},
			onCancel : () -> {
				(cast obj.filter:Group).remove(shader);
			}
		};
	}
}