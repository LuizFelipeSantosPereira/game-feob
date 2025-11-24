extends Control

## Tela de fim de jogo (vitória ou derrota)
class_name GameOverScreen

signal restart_requested
signal quit_requested

@onready var title_label = $Panel/VBoxContainer/TitleLabel
@onready var message_label = $Panel/VBoxContainer/MessageLabel
@onready var restart_button = $Panel/VBoxContainer/ButtonContainer/RestartButton
@onready var quit_button = $Panel/VBoxContainer/ButtonContainer/QuitButton

var is_victory: bool = false

func _ready():
	# Conecta os botões
	restart_button.pressed.connect(_on_restart_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# Configura a tela para cobrir toda a viewport
	set_anchors_preset(Control.PRESET_FULL_RECT)

func show_victory():
	is_victory = true
	title_label.text = "🎉 VITÓRIA! 🎉"
	message_label.text = "Parabéns! Você derrotou o Otto e salvou a cidade!\nTodos os desafios foram completados com sucesso!"
	visible = true

func show_defeat():
	is_victory = false
	title_label.text = "💀 GAME OVER 💀"
	message_label.text = "Você perdeu todas as vidas!\nO Otto conseguiu escapar...\nTente novamente e seja mais cuidadoso com seu código!"
	visible = true

func _on_restart_pressed():
	restart_requested.emit()

func _on_quit_pressed():
	quit_requested.emit()

