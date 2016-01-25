extends Node

onready var packet_peer_udp
var running = false
var packets_total = 0

onready var player
onready var player_position = Vector3(0, 0, 0)

const IMPULSE_PLAYER_POSITION = 0

var c2s = []

var s2c = [
	player_position,
]

var player_pos = Vector3(0, 0, 0)
var velocity = Vector3(0, 0, 0)
var speed = Vector2(0, 0)
const MAX_SPEED = 100

func _ready():
	set_process(true)

func _process(delta):
	if running and packet_peer_udp.get_available_packet_count() >= 1:

		var c2s = receive()

		if c2s[Client.IMPULSE_PLAYER_JOIN]:
			Game.new_player(Vector3(0, 5, 0), false)
			player = get_node("/root/Game/Player")

		print(str(packet_peer_udp.get_packet_ip()) + ":" + str(packet_peer_udp.get_packet_port()))
		print("SERVER: Received packet | " + str(c2s))
		packets_total += 1
		
		velocity = get_node("/root/Game/Player").get_linear_velocity()
		
		if c2s[Client.IMPULSE_MOVE_FORWARDS]:
			speed.y = -MAX_SPEED

		if c2s[Client.IMPULSE_MOVE_BACKWARDS]:
			speed.y = MAX_SPEED

		if c2s[Client.IMPULSE_MOVE_LEFT]:
			speed.x = -MAX_SPEED

		if c2s[Client.IMPULSE_MOVE_RIGHT]:
			speed.x = MAX_SPEED

		player.set_linear_velocity(Vector3(speed.x * delta, velocity.y, speed.y * delta))

		player_position = get_node("/root/Game/Player").get_translation()
		s2c[IMPULSE_PLAYER_POSITION] = player_position
		
		send(s2c, packet_peer_udp.get_packet_ip(), packet_peer_udp.get_packet_port())
		
		

func start():
	packet_peer_udp = PacketPeerUDP.new()
	packet_peer_udp.listen(4300)

	Game.print_timestamp("Listening on port 4300...")
	get_tree().change_scene("res://data/scenes/maps/test.tscn")
	running = true

# Send data to a client
func send(data, address, port):
	packet_peer_udp.set_send_address(str(address), int(port))
	packet_peer_udp.put_var(data)

# Receive data from clients
func receive():
	return packet_peer_udp.get_var()

func is_moving():
	if c2s[Client.IMPULSE_MOVE_FORWARDS] or c2s[Client.IMPULSE_MOVE_BACKWARDS] or c2s[Client.IMPULSE_MOVE_LEFT] or c2s[Client.IMPULSE_MOVE_RIGHT]:
		return true
	else:
		return false
