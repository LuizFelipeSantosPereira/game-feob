extends Node2D

@onready var input_code = $Control/TextEdit
@onready var run_button = $Control/Button
@onready var mensagem = $mensagem   # usa a Label que está em /jogo/mensagem
@onready var vilao = $vilao

var challenge_manager: ChallengeManager
var current_challenge: Dictionary = {}

func _ready():
	# Carrega o sistema de desafios
	challenge_manager = ChallengeManager.new()
	
	# Carrega o primeiro desafio
	current_challenge = challenge_manager.get_current_challenge()
	_load_challenge()
	
	mensagem.text = "🧠 Complete o código para atacar a IA!"
	run_button.pressed.connect(_on_run_button_pressed)
	input_code.gui_input.connect(_on_input_code_gui_input)
	
	# Conecta o livro para atualizar quando fechar
	var livro = $BookBotton
	if livro and livro.has_method("set_challenge_callback"):
		livro.set_challenge_callback(_load_challenge)

func _load_challenge():
	if current_challenge.is_empty():
		mensagem.text = "⚠️ Nenhum desafio encontrado!"
		return
	
	current_challenge = challenge_manager.get_current_challenge()
	input_code.text = current_challenge.get("code", "")
	mensagem.text = "💻 Desafio: " + current_challenge.get("name", "Desconhecido") + "\nComplete o código substituindo '?'"

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
	
	if code.is_empty():
		mensagem.text = "⚠️ Digite algum código!"
		feedback_cor(false)
		return
	
	# Verifica se ainda tem "?" no código
	if "?" in code:
		mensagem.text = "❌ Complete o código substituindo todos os '?'"
		feedback_cor(false)
		return
	
	# Valida o código usando o compilador Lox
	var expected_output = current_challenge.get("expected_output", "")
	var validation = challenge_manager.validate_solution(code, expected_output)
	
	if validation.valid:
		mensagem.text = "✅ " + validation.message + "\n💥 A IA recebeu dano!"
		feedback_cor(true)
		atacar_vilao(20)
		
		# Avança para o próximo desafio após um delay
		await get_tree().create_timer(1.5).timeout
		current_challenge = challenge_manager.next_challenge()
		_load_challenge()
	else:
		mensagem.text = "❌ " + validation.message
		feedback_cor(false)

# --- Envia dano ao vilão ---
func atacar_vilao(dano):
	if vilao and vilao.has_method("levar_dano"):
		print("Chamando vilao.levar_dano com", dano)
		vilao.levar_dano(dano)
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
