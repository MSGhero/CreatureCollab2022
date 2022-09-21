package timing;

import timing.Updater;

@:forward
abstract UpdaterList(Array<Updater>) from Array<Updater> to Array<Updater> {
	public function new() this = [];
}