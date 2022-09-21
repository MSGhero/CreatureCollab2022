package configs;

typedef Config = {
     creatures:Array<CreatureConfig>
}

typedef CreatureConfig = {
     var title:String;
     var image:String;
     var artist:String;
     var profile:String;
     @:default(true)
     var exist:Bool;
	@:default(false)
	var visited:Bool;
	@:default(true)
	var medal:Bool; // counts toward the medal
}