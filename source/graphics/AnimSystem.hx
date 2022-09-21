package graphics;

import graphics.Animation.AnimationCallback;
import ecs.Universe;
import ecs.System;

class AnimSystem extends System {
	
	@:fullFamily
	var anims : {
		requires : {
			anim:Animation
		}
	}
	
	@:fastFamily
	var animCBs : {
		anim:Animation,
		animCB:AnimationCallback
	}
	
	@:fastFamily
	var events : {
		event:Event
	}
	
	public function new(ecs:Universe) {
		super(ecs);
		
	}
	
	override function onEnabled() {
		
		anims.onEntityAdded.subscribe(onAnimAdded);
		anims.onEntityRemoved.subscribe(onAnimRemoved);
	}
	
	function onAnimAdded(entity) {
		
		fetch(anims, entity, {
			anim.updater.callback = anim.advance;
		});
	}
	
	function onAnimRemoved(entity) {
		
		fetch(anims, entity, {
			anim.updater.callback = null;
		});
	}
	
	override function update(dt:Float) {
		super.update(dt);
		
		iterate(anims, {
			anim.updater.update(dt);
		});
		
		iterate(animCBs, {
			if (animCB.cachedName != anim.name || animCB.cachedIndex != anim.index) {
				animCB.cachedName = anim.name;
				animCB.cachedIndex = anim.index;
				animCB.callback(anim);
			}
		});
	}
}