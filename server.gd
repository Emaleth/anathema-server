extends Node

var network := ENetMultiplayerPeer.new()
var port := 1989
var max_players := 100


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


func _Peer_Disconnected(player_id):
	print("User " + str(player_id) + " Disconnected")

@rpc("any_peer", "reliable")
func client_to_server_new_chat_message(text):
	server_to_client_broadcast_new_chat_message(text)

@rpc("reliable")
func server_to_client_broadcast_new_chat_message(text):
	for i in multiplayer.get_peers():
		multiplayer.rpc(i, self, "server_to_client_broadcast_new_chat_message", [text])
