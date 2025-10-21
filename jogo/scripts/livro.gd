extends Node2D

@onready var book_button = $book_button
@onready var guide_panel = $guide_panel

var is_open = false

func _ready():
	# Segurança: verifica se os nós existem antes de conectar
	if book_button:
		book_button.pressed.connect(_on_book_button_pressed)
	else:
		push_error("⚠️ Nó 'book_button' não encontrado!")

	if guide_panel:
		guide_panel.visible = false
	else:
		push_error("⚠️ Nó 'guide_panel' não encontrado!")

func _on_book_button_pressed():
	if guide_panel:
		is_open = !is_open
		guide_panel.visible = is_open
	else:
		push_error("⚠️ Tentou acessar guide_panel mas ele é nulo!")
