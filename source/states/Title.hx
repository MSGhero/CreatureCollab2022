package states;

import ecs.Universe;
import graphics.Layer;
import h2d.Object;
import hxd.Res;
import h2d.Bitmap;
import graphics.Animation;
import graphics.RenderObject;
import ecs.Entity;
import graphics.Spritesheet;

class Title implements IState {
	
	public var active(default, null):Bool;
	public var universe(default, null):Universe;
	
	var image:Entity;
	
	public function new(universe) {
		active = false;
		this.universe = universe;
	}
	
	public function onEnter(sheet:Spritesheet) {
		
		active = true;
		
		image = universe.createEntity();
		
		var anim:Animation = { updater : { } };
		anim.add("default", {
			frames : [Res.load("bgs/title.png").toTile()],
			loop : false
		});
		anim.play("default");
		
		var ro:RenderObject = {
			anim : anim,
			sprite : new Bitmap(null)
		};
		
		ro.sprite.tile = ro.anim.currFrame;
		// if I were tracking commits, you could see exactly when I stopped caring about code elegance
		ro.sprite.x = (960 / 0.5 - ro.sprite.tile.width) / 2;
		ro.sprite.y = (540 / 0.5 - ro.sprite.tile.height) / 2;
		
		universe.setComponents(image, ro, anim, (ro.sprite:Object), Layer.GAME);
	}
	
	public function onExit() {
		active = false;
		ECS.ecs.deleteEntity(image);
	}
}