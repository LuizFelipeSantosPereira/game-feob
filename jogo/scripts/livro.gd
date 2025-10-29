extends Node2D

@onready var book_button = $book_button
@onready var guide_panel = $guide_panel
@onready var guide_text = $guide_panel/guide_text

var is_open = false

func _ready():
	if book_button:
		book_button.pressed.connect(_on_book_button_pressed)
	else:
		push_error("⚠️ Nó 'book_button' não encontrado!")

	if guide_panel:
		guide_panel.visible = false
	else:
		push_error("⚠️ Nó 'guide_panel' não encontrado!")

	# Define o texto do painel de instruções
	if guide_text:
		guide_text.text = """
📖 *Guia do Jogo*

🔹 Use CTRL + Enter para confirmar comandos
🔹 Comandos disponíveis:
   - attack(): causa 20 de dano
   - fireball(): causa 40 de dano
🔹 O vilão perde vida ao ser atacado
🔹 Clique novamente no livro para fechar o painel
"""
	else:
		push_error("⚠️ Nó 'guide_text' não encontrado!")

func _on_book_button_pressed():
	if guide_panel:
		is_open = !is_open
		guide_panel.visible = is_open

		if is_open:
			print("📘 Painel aberto")
		else:
			print("📕 Painel fechado")
	else:
		push_error("⚠️ Tentou acessar guide_panel mas ele é nulo!")
