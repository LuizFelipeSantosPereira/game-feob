extends Node2D

@onready var code_editor = $CanvasLayer/code_panel/ScrollContainer/code_editor
@onready var code_panel = $CanvasLayer/code_panel
@onready var run_button = $CanvasLayer/Button
@onready var mensagem = $CanvasLayer/mensagem
@onready var vilao = $CanvasLayer/vilao
@onready var background = $CanvasLayer/background
@onready var player_life_bar = $CanvasLayer/player_life_bar
@onready var game_over_screen = $CanvasLayer/GameOverScreen

var challenge_manager: ChallengeManager
var current_challenge: Dictionary = {}
var challenges_completed: int = 0
var total_challenges: int = 0
var player_lives_max: int = 5
var player_lives: int = player_lives_max
var game_over := false

func _ready():
	# Carrega o sistema de desafios
	challenge_manager = ChallengeManager.new()
	
	# Conta o total de desafios
	total_challenges = challenge_manager.challenges.size()
	challenges_completed = 0
	player_lives = player_lives_max
	game_over = false
	_update_player_life_bar()
	run_button.disabled = false
	run_button.mouse_filter = Control.MOUSE_FILTER_STOP
	if code_editor:
		code_editor.editable = true
	
	# Carrega o primeiro desafio
	current_challenge = challenge_manager.get_current_challenge()
	_load_challenge()
	
	mensagem.text = "🧠 Complete o código para atacar o Otto!"
	run_button.pressed.connect(_on_run_button_pressed)
	
	# Conecta o livro para atualizar quando fechar
	var livro = $CanvasLayer/BookBotton
	if livro and livro.has_method("set_challenge_callback"):
		livro.set_challenge_callback(_load_challenge)

	# Conecta a tela de game over
	if game_over_screen:
		game_over_screen.restart_requested.connect(_on_restart_requested)
		game_over_screen.quit_requested.connect(_on_quit_requested)

func _load_challenge():
	if current_challenge.is_empty():
		mensagem.text = "⚠️ Nenhum desafio encontrado!"
		return
	
	current_challenge = challenge_manager.get_current_challenge()
	var code = current_challenge.get("code", "")
	
	# Define o código no editor
	if code_editor:
		code_editor.text = code
		code_editor.editable = true
	
	mensagem.text = "💻 Desafio: " + current_challenge.get("name", "Desconhecido")

# --- Botão "Executar" ---
func _on_run_button_pressed():
	executar_comando()

# --- Execução do comando digitado ---
func executar_comando():
	if game_over:
		mensagem.text = "💀 Você já perdeu todas as vidas! Reinicie o jogo."
		return

	if not code_editor:
		mensagem.text = "⚠️ Editor de código não encontrado!"
		return
	
	# Obtém o código do editor
	var code = code_editor.text
	
	if code.strip_edges().is_empty():
		mensagem.text = "⚠️ O código está vazio!"
		feedback_cor(false)
		return
	
	# Valida o código usando o compilador Lox
	var expected_output = current_challenge.get("expected_output", "")
	var validation = challenge_manager.validate_solution(code, expected_output)
	
	if validation.valid:
		challenges_completed += 1
		mensagem.text = "✅ " + validation.message + "\n💥 O Otto recebeu dano!"
		feedback_cor(true)
		atacar_vilao(20)
		
		# Verifica se todos os desafios foram completados
		if challenges_completed >= total_challenges:
			# Todos os desafios completados - boss morre
			await get_tree().create_timer(1.5).timeout
			if vilao and vilao.has_method("morrer"):
				vilao.morrer()
			# Mostra tela de vitória
			await get_tree().create_timer(0.5).timeout
			_show_victory_screen()
		else:
			# Avança para o próximo desafio após um delay
			await get_tree().create_timer(1.5).timeout
			current_challenge = challenge_manager.next_challenge()
			_load_challenge()
	else:
		mensagem.text = "❌ " + validation.message
		feedback_cor(false)
		_penalizar_jogador()

# --- Envia dano ao vilão ---
func atacar_vilao(dano):
	if vilao and vilao.has_method("levar_dano"):
		print("Chamando vilao.levar_dano com", dano)
		# Só causa dano se ainda não completou todos os desafios
		if challenges_completed < total_challenges:
			vilao.levar_dano(dano)
	else:
		mensagem.text = "⚠️ Vilão não encontrado ou já derrotado!"
		print("ERRO: vilao não encontrado ou sem método.")

# --- Feedback visual no editor ---
func feedback_cor(certo: bool):
	var cor_inicial = Color(1, 1, 1)
	var cor_final = Color(0.2, 1, 0.2) if certo else Color(1, 0.2, 0.2)

	# Aplica feedback visual no editor
	if code_editor:
		code_editor.modulate = cor_final
		await get_tree().create_timer(0.3).timeout
		code_editor.modulate = cor_inicial

func _penalizar_jogador():
	if game_over:
		return
	player_lives -= 1
	if player_lives < 0:
		player_lives = 0
	_update_player_life_bar()
	if player_lives == 0:
		game_over = true
		if code_editor:
			code_editor.editable = false
		run_button.disabled = true
		run_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
		# Mostra tela de game over
		await get_tree().create_timer(0.5).timeout
		_show_defeat_screen()

func _update_player_life_bar():
	if player_life_bar:
		player_life_bar.max_value = player_lives_max
		player_life_bar.value = player_lives

func _show_victory_screen():
	if game_over_screen:
		game_over_screen.show_victory()

func _show_defeat_screen():
	if game_over_screen:
		game_over_screen.show_defeat()

func _on_restart_requested():
	# Reinicia o jogo recarregando a cena
	get_tree().reload_current_scene()

func _on_quit_requested():
	# Volta para o menu principal
	get_tree().change_scene_to_file("res://cenas/Menu.tscn")
