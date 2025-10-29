extends Node2D

@onready var menu_items = [
	$"CanvasLayer/VBoxContainer/StartGame",
	$"CanvasLayer/VBoxContainer/Options",
	$"CanvasLayer/VBoxContainer/QuitGame"
]
@onready var left_arrow = $LeftArrow
@onready var right_arrow = $RightArrow

var current_index := 0

func _ready():
	_update_selection()

func _process(event):
	if Input.is_action_just_pressed("ui_down"):
		current_index = (current_index + 1) % menu_items.size()
		_update_selection()
	elif Input.is_action_just_pressed("ui_up"):
		current_index = (current_index - 1 + menu_items.size()) % menu_items.size()
		_update_selection()
	elif Input.is_action_just_pressed("ui_accept"):
		_activate_option()

func _update_selection():
	# Centraliza as setas ao redor do item atual
	var selected = menu_items[current_index]
	var pos = selected.global_position

	left_arrow.position = Vector2(pos.x - 100, pos.y)
	right_arrow.position = Vector2(pos.x + selected.size.x + 100, pos.y)

	# Destaca o item selecionado
	for i in range(menu_items.size()):
		menu_items[i].modulate = Color(1, 1, 1, 0.5)
	selected.modulate = Color(1, 1, 1, 1)

func _activate_option():
	match current_index:
		0:
			print("Start Game")
			# get_tree().change_scene_to_file("res://scenes/game.tscn")
		1:
			print("Options")
		2:
			get_tree().quit()
