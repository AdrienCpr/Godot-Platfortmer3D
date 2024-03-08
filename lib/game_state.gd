extends Node

var is_loading_game:bool = false
var current_level
var current_level_key = "choice_level"
var player

var player_health:int = 3
var is_player_dead:bool = false
var has_key:bool = false
var player_health_change:bool = false
var coins:int = 0

var Stars:Dictionary = {
	"level_1": {"end": false, "coin": false},
	"level_2": {"end": false, "coin": false},
}
