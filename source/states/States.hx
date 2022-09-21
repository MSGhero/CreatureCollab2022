package states;

enum abstract States(String) from String {
	var GAME = "game";
	var POPUP = "popup";
	var TITLE = "title";
}