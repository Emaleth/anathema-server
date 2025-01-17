extends Node

var network := ENetMultiplayerPeer.new()
var port := 1989
var max_players := 100

@onready var player_verification := $PlayerVerification
var expected_tokens := {}

func _ready() -> void:
	StartServer()


func StartServer() -> void:
	network.create_server(port, max_players)
	multiplayer.multiplayer_peer = network
	print("Server started")

	multiplayer.peer_connected.connect(_Peer_Connected)
	multiplayer.peer_disconnected.connect(_Peer_Disconnected)


func _Peer_Connected(player_id):
	print("User " + str(player_id) + " Connected")
	player_verification.start(player_id)


func _Peer_Disconnected(player_id):
	print("User " + str(player_id) + " Disconnected")
	get_node(str(player_id)).queue_free()


@rpc("any_peer", "reliable")
func client_to_server_new_chat_message(text):
	var sender = multiplayer.get_remote_sender_id()
	var time = Time.get_time_dict_from_system()
	var timestamp = str(time.hour, ":" ,time.minute)
	server_to_client_broadcast_new_chat_message(sender, timestamp, text)

@rpc("reliable")
func server_to_client_broadcast_new_chat_message(sender, timestamp, text):
	for i in multiplayer.get_peers():
		multiplayer.rpc(i, self, "server_to_client_broadcast_new_chat_message", [sender, timestamp, text])


func _on_token_expiration_timer_timeout() -> void:
	var current_time = int(Time.get_unix_time_from_system())
	var token_time
	if expected_tokens == []:
		pass
	else:
		for i in range(expected_tokens.size() -1, -1, -1):
			token_time = int(expected_tokens[i].right(-64))
			if current_time - token_time >= 30:
				expected_tokens.remove_at(i)

@rpc("reliable")
func server_to_client_token(player_id):
	multiplayer.rpc(player_id, self, "server_to_client_token")

@rpc("reliable", "any_peer")
func client_to_server_token(token):
	var player_id = multiplayer.get_remote_sender_id()
	player_verification.Verify(player_id, token)

@rpc("reliable")
func server_to_player_token_result(player_id, token_verification):
	multiplayer.rpc(player_id, self, "server_to_player_token_result", [token_verification])
