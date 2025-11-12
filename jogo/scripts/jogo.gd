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
	
	# Verifica se ainda tem "?" no código (ignorando comentários e strings)
	if _has_unresolved_question_marks(code):
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

# --- Verifica se há "?" não resolvidos no código (ignora comentários e strings) ---
func _has_unresolved_question_marks(code: String) -> bool:
	var lines = code.split("\n")
	
	for line in lines:
		# Remove comentários da linha
		var comment_pos = line.find("//")
		var code_part = line
		if comment_pos >= 0:
			code_part = line.substr(0, comment_pos)
		
		# Verifica strings e ignora "?" dentro delas
		var in_string = false
		var string_char = ""
		var i = 0
		
		while i < code_part.length():
			var char = code_part[i]
			
			# Detecta início/fim de strings
			if (char == '"' or char == "'") and (i == 0 or code_part[i-1] != "\\"):
				if not in_string:
					in_string = true
					string_char = char
				elif char == string_char:
					in_string = false
					string_char = ""
			
			# Verifica se há "?" que não está em string
			if not in_string and char == "?":
				# Verifica se não é parte de uma palavra (como "substitua")
				var before = "" if i == 0 else code_part[i-1]
				var after = "" if i >= code_part.length() - 1 else code_part[i+1]
				
				# Verifica se é um caractere alfanumérico ou underscore
				var before_is_alpha = before.length() > 0 and (before.is_valid_float() or before == "_" or before.to_lower() >= "a" and before.to_lower() <= "z")
				var after_is_alpha = after.length() > 0 and (after.is_valid_float() or after == "_" or after.to_lower() >= "a" and after.to_lower() <= "z")
				
				# Se está entre caracteres alfanuméricos, é parte de uma palavra (ignora)
				if not (before_is_alpha or after_is_alpha):
					# É um "?" solto que precisa ser substituído
					return true
			
			i += 1
	
	return false

# --- Feedback visual no campo de texto ---
func feedback_cor(certo: bool):
	var cor_inicial = Color(1, 1, 1)
	var cor_final = Color(0.2, 1, 0.2) if certo else Color(1, 0.2, 0.2)

	input_code.modulate = cor_final
	await get_tree().create_timer(0.3).timeout
	input_code.modulate = cor_inicial
