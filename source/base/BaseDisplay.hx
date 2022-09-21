package base;

import graphics.Spritesheet;
import configs.Config.AnimConfig;
import h2d.Bitmap;
import graphics.RenderObject;
import graphics.Animation;
import ecs.Entity;

class BaseDisplay {
	
	public var id(default, null):Entity;
	public var anim(default, null):Animation;
	public var display(default, null):RenderObject;
	
	public function new(sprite:Bitmap) {
		
		id = ECS.ecs.createEntity();
		
		anim = {
			updater : { }
		};
		
		display = {
			sprite : sprite,
			anim : anim
		};
		
		ECS.ecs.setComponents(id, anim, display);
	}
	
	public function createAnim(configs:Array<AnimConfig>, sheet:Spritesheet) {
		
		for (config in configs) {
			anim.add(config.name, {
				frames : sheet.map(config.frameNames),
				loop : config.loop,
				fps : config.fps
			});
		}
	}
}