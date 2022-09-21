package audio;

import hxd.Res;
import ecs.Entity;
import timing.Timing;
import hxd.snd.ChannelGroup;
import ecs.Universe;
import ecs.System;
import hxd.snd.Manager;
import hxd.snd.Channel;
import input.Input;

class AudioSystem extends System {
	
	@:fullFamily
	var audio : {
		resources : {
			manager:Manager,
			volume:AudioVolume
		},
		requires : {
			props:AudioProps,
			channel:Channel
		}
	};
	
	@:fullFamily
	var volControl : {
		resources : {
			manager:Manager
		},
		requires : {
			input:Input
		}
	};
	
	@:fastFamily
	var events : {
		event:Event
	};
	
	var audioEnt:Entity;
	
	var musicChannel:Channel;
	var sfxChannels:ChannelGroup;
	var uiChannels:ChannelGroup;
	
	public function new(ecs:Universe) {
		super(ecs);
		
		audioEnt = ecs.createEntity();
		
		musicChannel = null;
		sfxChannels = new ChannelGroup("sfx");
		uiChannels = new ChannelGroup("ui");
	}
	
	override function onEnabled() {
		super.onEnabled();
		
		events.onEntityAdded.subscribe(handleEvent);
	}
	
	function handleEvent(eventity) {
		
		fetch(events, eventity, {
			switch (event) {
				case AUDIO_START(props):
					
					setup(audio, {
						
						if (props.fadeDur == 0) {
							
							var channel:Channel = null;
							
							switch (props.type) {
								case MUSIC(name):
									if (musicChannel != null && !musicChannel.isReleased()) musicChannel.stop();
									channel = musicChannel = Res.load('music/$name.ogg').toSound().play(props.loop, volume.musicMult);
									channel.position = props.position;
									trace(channel.position, props.position, channel.duration);
								case SFX(name):
									channel = Res.load('sfx/$name.ogg').toSound().play(props.loop, volume.sfxMult, sfxChannels);
									channel.position = props.position;
								case UI(name):
									channel = Res.load('sfx/$name.ogg').toSound().play(props.loop, volume.sfxMult, uiChannels);
									channel.position = props.position;
							}
							
							if (channel != null) {
								universe.setComponents(universe.createEntity(), channel, props); // is props needed?
							}
						}
						
						else {
							
							var channel:Channel = null;
							
							switch (props.type) {
								
								case MUSIC(name):
									
									if (musicChannel != null && !musicChannel.isReleased()) {
										Timing.schedule(audioEnt)
											.thenTween(props.fadeDur, f -> musicChannel.volume = (1 - f) * volume.musicMult)
											.then(() -> {
												musicChannel.stop();
												musicChannel = Res.load('music/$name.ogg').toSound().play(props.loop, 0);
												musicChannel.position = props.position;
												universe.setComponents(universe.createEntity(), musicChannel, props);
											})
											.thenTween(props.fadeDur, f -> musicChannel.volume = f * volume.musicMult)
										;
									}
									
									else {
										channel = musicChannel = Res.load('music/$name.ogg').toSound().play(props.loop, 0);
										channel.position = props.position;
										Timing.tween(audioEnt, props.fadeDur, f -> musicChannel.volume = f * volume.musicMult);
									}
									
								case SFX(name):
									channel = Res.load('sfx/$name.ogg').toSound().play(props.loop, 0, sfxChannels);
									channel.position = props.position;
									Timing.tween(audioEnt, props.fadeDur, f -> channel.volume = f * volume.sfxMult);
									
								case UI(name):
									channel = Res.load('sfx/$name.ogg').toSound().play(props.loop, 0, sfxChannels);
									channel.position = props.position;
									Timing.tween(audioEnt, props.fadeDur, f -> channel.volume = f * volume.sfxMult);
							}
							
							if (channel != null) {
								universe.setComponents(universe.createEntity(), channel, props); // is props needed?
							}
						}
					});
					
				case AUDIO_STOP(fadeDur, type):
					
					if (fadeDur == 0) {
						switch (type) {
							case MUSIC(name): if (musicChannel != null && !musicChannel.isReleased()) musicChannel.stop();
							case SFX(name): Res.load('sfx/$name.ogg').toSound().stop();
							case UI(name): Res.load('sfx/$name.ogg').toSound().stop();
							default:
						}
					}
					
					else {
						setup(audio, {
							switch (type) {
								case MUSIC(name):
									if (musicChannel != null && !musicChannel.isReleased())
										Timing.tween(audioEnt, fadeDur, f -> musicChannel.volume = (1 - f) * volume.musicMult, musicChannel.stop);
								// rest?
								default:
							}
						});
					}
					
				case AUDIO_STOP_ALL:
					
					setup(audio, {
						manager.stopAll();
					});
					
				default:
			}
		});
	}
	
	override function update(dt:Float) {
		super.update(dt);
		
		setup(audio, {
			iterate(volControl, {
				
				if (input.actions.justPressed.getAction(MUTE)) {
					manager.suspended = !manager.suspended;
				}
				
				else if (input.actions.justPressed.getAction(VOL_DOWN)) {
					// should be an event or something, to update all playing sounds
					// but I don't feel like it
					volume.master = Math.max(0, volume.master - 0.1);
					if (musicChannel != null && !musicChannel.isReleased()) {
						musicChannel.volume = volume.musicMult;
					}
				}
				
				else if (input.actions.justPressed.getAction(VOL_UP)) {
					volume.master = Math.min(1, volume.master + 0.1);
					if (musicChannel != null && !musicChannel.isReleased()) {
						musicChannel.volume = volume.musicMult;
					}
				}
			});
		});
		
		iterate(audio, entity -> {
			if (channel.isReleased()) {
				universe.deleteEntity(entity);
			}
		});
	}
}