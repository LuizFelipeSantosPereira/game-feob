extends Node2D

@onready var input_code = $Control/TextEdit
@onready var run_button = $Control/Button
@onready var mensagem = $mensagem   # usa a Label que está em /jogo/mensagem
@onready var vilao = $vilao

func _ready():
	mensagem.text = "🧠 Resolva o enigma para deter a criatura!"
	run_button.pressed.connect(_on_run_button_pressed)
	input_code.gui_input.connect(_on_input_code_gui_input)

# --- Detecta Ctrl + Enter dentro do TextEdit ---
func _on_input_code_gui_input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ENTER and event.ctrl_pressed:
			executar_comando()
			get_viewport().set_input_as_handled()

# --- Botão "Executar" ---
func _on_run_button_pressed():
	executar_comando()

# --- Execução do comando digitado ---
func executar_comando():
	var code = input_code.text.strip_edges()
	print("Comando digitado:", code)

	match code:
		"attack()":
			atacar_vilao(20)
			mensagem.text = "🗡️ Ataque simples executado!"
			feedback_cor(true)
		"fireball()":
			atacar_vilao(40)
			mensagem.text = "🔥 Bola de fogo lançada!"
			feedback_cor(true)
		_:
			mensagem.text = "❌ Comando inválido!"
			print("Comando inválido:", code)
			feedback_cor(false)

	input_code.text = ""

# --- Envia dano ao vilão ---
func atacar_vilao(dano):
	if vilao and vilao.has_method("levar_dano"):
		print("Chamando vilao.levar_dano com", dano)
		vilao.levar_dano(dano)
		mensagem.text = "💥 Vilão recebeu %s de dano!" % dano
	else:
		mensagem.text = "⚠️ Vilão não encontrado ou já derrotado!"
		print("ERRO: vilao não encontrado ou sem método.")

# --- Feedback visual no campo de texto ---
func feedback_cor(certo: bool):
	var cor_inicial = Color(1, 1, 1)
	var cor_final = Color(0.2, 1, 0.2) if certo else Color(1, 0.2, 0.2)

	input_code.modulate = cor_final
	await get_tree().create_timer(0.3).timeout
	input_code.modulate = cor_inicial
