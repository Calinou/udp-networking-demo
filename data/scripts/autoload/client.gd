extends Node

onready var packet_peer_udp
onready var send_timer = 0
var running = false

var player_position = Vector3(0, 0, 0)

# Mouse look
var yaw = 0
var pitch = 0
var view_sensitivity = 0.1

const NETWORK_FPS = 5

const IMPULSE_PLAYER_JOIN = 0
const IMPULSE_PLAYER_LEAVE = 1
const IMPULSE_MOVE_FORWARDS = 2
const IMPULSE_MOVE_BACKWARDS = 3
const IMPULSE_MOVE_LEFT = 4
const IMPULSE_MOVE_RIGHT = 5
const IMPULSE_MOVE_UP = 6
const IMPULSE_MOVE_DOWN = 7
const MOUSE_RELATIVE_X = 8
const MOUSE_RELATIVE_Y = 9

var c2s = [
	false, # IMPULSE_PLAYER_JOIN
	false, # IMPULSE_PLAYER_LEAVE
	false, # IMPULSE_MOVE_FORWARDS
	false, # IMPULSE_MOVE_BACKWARDS
	false, # IMPULSE_MOVE_LEFT
	false, # IMPULSE_MOVE_RIGHT
	false, # IMPULSE_MOVE_UP
	false, # IMPULSE_MOVE_DOWN
]

var s2c = []

func _ready():
	set_process(true)

func _process(delta):
	if running:
		send_timer += delta

		if Input.is_action_pressed("move_forwards"):
			c2s[IMPULSE_MOVE_FORWARDS] = true
		else:
			c2s[IMPULSE_MOVE_FORWARDS] = false

		if Input.is_action_pressed("move_backwards"):
			c2s[IMPULSE_MOVE_BACKWARDS] = true
		else:
			c2s[IMPULSE_MOVE_BACKWARDS] = false

		if Input.is_action_pressed("move_left"):
			c2s[IMPULSE_MOVE_LEFT] = true
		else:
			c2s[IMPULSE_MOVE_LEFT] = false

		if Input.is_action_pressed("move_right"):
			c2s[IMPULSE_MOVE_RIGHT] = true
		else:
			c2s[IMPULSE_MOVE_RIGHT] = false

		if send_timer >= 1 / NETWORK_FPS:
			send(c2s)
			c2s[IMPULSE_PLAYER_JOIN] = false
			send_timer = 0

		if packet_peer_udp.get_available_packet_count() >= 1:
			var s2c = receive()
			print("CLIENT: Received packet | " + str(s2c))
			get_node("/root/Game/Player").set_translation(s2c[Server.IMPULSE_PLAYER_POSITION])

func start():
	packet_peer_udp = PacketPeerUDP.new()
	packet_peer_udp.set_send_address("127.0.0.1", 4300)

	Game.print_timestamp("Connecting to 127.0.0.1:4300...")
	get_tree().change_scene("res://data/scenes/maps/test.tscn")
	# A player joined, us
	c2s[IMPULSE_PLAYER_JOIN] = true
	Game.new_player(Vector3(0, 5, 0), true)
	running = true

# Send data to server
func send(data):
	packet_peer_udp.put_var(data)

# Receive data from server
func receive():
	return packet_peer_udp.get_var()
