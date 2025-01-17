extends Node

var network := ENetMultiplayerPeer.new()
var ip := "127.0.0.1"
var port := 1912
var gateway_api := MultiplayerAPI.create_default_interface()

@onready var gameserver = get_node("/root/Server")

func _ready() -> void:
	ConnectToServer()

func _process(_delta: float) -> void:
	if not get_tree().get_multiplayer() == gateway_api:
		return
	if not gateway_api.has_multiplayer_peer():
		return
	gateway_api.poll()

func ConnectToServer():
	network.create_client(ip, port)
	get_tree().set_multiplayer(gateway_api, self.get_path())
	gateway_api.multiplayer_peer = network

	gateway_api.connection_failed.connect(_OnConnectionFailed)
	gateway_api.connected_to_server.connect(_OnConnectionSucceeded)
	gateway_api.server_disconnected.connect(_OnDisconnection)

func _OnConnectionFailed():
	print("Failed to connect to the game server hub")


func _OnConnectionSucceeded():
	print("Succesfully connected to game server hub")

@rpc("reliable")
func authenticator_to_server_DistributeLoginToken(token, uuid):
	gameserver.expected_tokens[token] = uuid


func _OnDisconnection():
	print("Succesfully disconnected to login server")
