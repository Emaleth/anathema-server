extends Node


@onready var player_container_scene = preload("res://player_container.tscn")


func start(player_id):
	CreatePlayerContainer(player_id)


func CreatePlayerContainer(player_id):
	var new_player_container = player_container_scene.instantiate()
	new_player_container.name = str(player_id)
	get_parent().add_child(new_player_container, true)
	FillPlayerContainer(player_id)

func FillPlayerContainer(player_id):
	print(get_parent().get_node(str(player_id)).player_name)
