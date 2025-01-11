extends Node


@onready var player_container_scene = preload("res://player_container.tscn")

var awaiting_verification = {}

func start(player_id):
	awaiting_verification[player_id] = {"Timestamp" : int(Time.get_unix_time_from_system())}
	get_parent().server_to_client_token(player_id)


func CreatePlayerContainer(player_id):
	var new_player_container = player_container_scene.instantiate()
	new_player_container.name = str(player_id)
	get_parent().add_child(new_player_container, true)
	FillPlayerContainer(player_id)

func FillPlayerContainer(player_id):
	print(get_parent().get_node(str(player_id)).player_name)

func Verify(player_id, token):
	var token_verification = false
	while int(Time.get_unix_time_from_system()) - int(token.right(-64)) <= 30:
		if get_parent().expected_tokens.has(token):
			token_verification = true
			CreatePlayerContainer(player_id)
			awaiting_verification.erase(player_id)
			get_parent().expected_tokens.erase(token)
			break
		else:
			await get_tree().create_timer(2).timeout
	get_parent().server_to_player_token_result(player_id, token_verification)
	if token_verification == false:
		awaiting_verification.erase(player_id)
		get_parent().network.get_peer(player_id).peer_disconnect_now()


func _on_verification_expiration_timer_timeout() -> void:
	var current_time = int(Time.get_unix_time_from_system())
	var start_time
	if awaiting_verification == {}:
		pass
	else:
		for key in awaiting_verification.keys():
			start_time = awaiting_verification[key].Timestamp
			if current_time - start_time >= 30:
				awaiting_verification.erase(key)
				var connected_peers = Array(get_parent().multiplayer.get_peers())
				if connected_peers.has(key):
					get_parent().server_to_player_token_result(key, false)
					get_parent().network.get_peer(key).peer_disconnect_now()
