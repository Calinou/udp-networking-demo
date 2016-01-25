extends Node

const PLAYER_SCENE = preload("res://data/scenes/actors/player.tscn")
const LOCAL_PLAYER_SCENE = preload("res://data/scenes/actors/local_player.tscn")
onready var player

# YYYY-MM-DD
func get_date():
    return str(OS.get_date()["year"]) + "-" + str(OS.get_date()["month"]).pad_zeros(2) + "-" + str(OS.get_date()["day"]).pad_zeros(2)

# hh:mm:ss
func get_time():
    return str(OS.get_time()["hour"]).pad_zeros(2) + ":" + str(OS.get_time()["minute"]).pad_zeros(2) + ":" + str(OS.get_time()["second"]).pad_zeros(2)

# [YYYY-MM-DD | hh:mm:ss]
func print_timestamp(text):
    print("[" + get_date() + " | " + get_time() + "] " + text)

# Spawn a player, with a "local" flag for physics
func new_player(position, local):
	if local:
		player = LOCAL_PLAYER_SCENE.instance()
	else:
		player = PLAYER_SCENE.instance()
	player.set_translation(position)
	add_child(player)