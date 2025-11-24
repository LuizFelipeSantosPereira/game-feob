extends RefCounted

## Gerenciador de desafios
class_name ChallengeManager

const CHALLENGES_PATH = "res://../compilador/desafios/"
var challenges: Array[Dictionary] = []
var current_challenge_index: int = 0

func _init():
	_load_challenges()

func _load_challenges():
	var dir = DirAccess.open(CHALLENGES_PATH)
	if dir == null:
		push_error("Erro ao abrir diretório de desafios: " + CHALLENGES_PATH)
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if file_name.ends_with(".lox"):
			var challenge = _load_challenge(file_name)
			if challenge:
				challenges.append(challenge)
		file_name = dir.get_next()

func _load_challenge(file_name: String) -> Dictionary:
	var file_path = CHALLENGES_PATH + file_name
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		return {}
	
	var code = file.get_as_text()
	file.close()
	
	# Extrai output esperado dos comentários
	var expected_output = _extract_expected_output(code)
	
	return {
		"name": file_name.get_file().get_basename(),
		"code": code,
		"expected_output": expected_output,
		"file_path": file_path
	}

func _extract_expected_output(code: String) -> String:
	# Procura por comentários com "//" seguido de um valor esperado
	var lines = code.split("\n")
	
	print("DEBUG - Extraindo output esperado do código com ", lines.size(), " linhas")
	
	# Primeiro, procura comentários inline em linhas com print
	for i in range(lines.size()):
		var line = lines[i]
		if line.contains("//") and "print" in line.to_lower():
			var comment_start = line.find("//")
			var comment = line.substr(comment_start + 2).strip_edges()
			
			print("DEBUG - Linha ", i, " com print: '", line, "'")
			print("DEBUG - Comentário extraído: '", comment, "'")
			
			# Ignora comentários que são instruções (começam com palavras-chave)
			if comment.begins_with("substitua") or comment.begins_with("Complete"):
				print("DEBUG - Comentário ignorado (instrução)")
				continue
			
			# Se o comentário é um número ou string simples, pode ser o output esperado
			if comment.length() > 0 and comment.length() < 100:
				# Remove aspas se existirem
				if comment.begins_with('"') and comment.ends_with('"'):
					comment = comment.substr(1, comment.length() - 2)
				
				# Se não começa com uma palavra de instrução, provavelmente é o output
				print("DEBUG - Output esperado encontrado: '", comment, "'")
				return comment
	
	# Se não encontrou, procura no final do arquivo ou em comentários separados
	# Para desafios mais complexos, pode ter output esperado em comentário separado
	for i in range(lines.size() - 1, -1, -1):
		var line = lines[i].strip_edges()
		if line.begins_with("//") and line.length() > 2:
			var comment = line.substr(2).strip_edges()
			# Se é um número ou string curta, pode ser output esperado
			if comment.length() > 0 and comment.length() < 50:
				if comment.is_valid_float() or (not comment.contains(" ") and not comment.begins_with("substitua")):
					print("DEBUG - Output esperado encontrado no final: '", comment, "'")
					return comment
	
	print("DEBUG - Nenhum output esperado encontrado!")
	return ""

func get_current_challenge() -> Dictionary:
	if challenges.is_empty():
		return {}
	if current_challenge_index >= challenges.size():
		current_challenge_index = 0
	return challenges[current_challenge_index]

func next_challenge() -> Dictionary:
	current_challenge_index += 1
	if current_challenge_index >= challenges.size():
		current_challenge_index = 0
	return get_current_challenge()

func previous_challenge() -> Dictionary:
	current_challenge_index -= 1
	if current_challenge_index < 0:
		current_challenge_index = challenges.size() - 1
	return get_current_challenge()

func _format_friendly_error(error: String) -> String:
	# Remove informações técnicas desnecessárias e torna a mensagem mais amigável
	var friendly = error.strip_edges()
	
	# Extrai o número da linha se existir
	var line_number = ""
	if "[line " in friendly:
		var line_start = friendly.find("[line ")
		var line_end = friendly.find("]", line_start)
		if line_end != -1:
			line_number = friendly.substr(line_start + 6, line_end - line_start - 6)
			friendly = friendly.replace("[line " + line_number + "]", "")
	
	# Remove prefixos técnicos
	friendly = friendly.replace("Error:", "")
	friendly = friendly.replace("Error", "")
	friendly = friendly.strip_edges()
	
	# Traduz mensagens comuns de erro para algo mais amigável e CURTO
	if "Unexpected character" in friendly:
		var hint = ""
		if line_number != "":
			hint = " (linha " + line_number + ")"
		friendly = "❌ Caractere inesperado" + hint + "!"
	elif "Expect" in friendly and "property name" in friendly:
		var hint = ""
		if line_number != "":
			hint = " (linha " + line_number + ")"
		friendly = "❌ Erro de sintaxe" + hint + "!"
	elif "Expect" in friendly and ";" in friendly:
		var hint = ""
		if line_number != "":
			hint = " (linha " + line_number + ")"
		friendly = "❌ Falta ponto e vírgula" + hint + "!"
	elif "Expect" in friendly:
		var hint = ""
		if line_number != "":
			hint = " (linha " + line_number + ")"
		friendly = "❌ Erro de sintaxe" + hint + "!"
	elif "Undefined variable" in friendly:
		friendly = "❌ Variável não definida!"
	elif "Unexpected token" in friendly:
		friendly = "❌ Token inesperado!"
	else:
		# Se não conseguir traduzir, pelo menos simplifica
		var hint = ""
		if line_number != "":
			hint = " (linha " + line_number + ")"
		friendly = "❌ Erro no código" + hint + "!"
	
	# Limpa múltiplas quebras de linha e espaços extras
	friendly = friendly.replace("\n\n", "\n")
	friendly = friendly.replace("  ", " ")
	friendly = friendly.strip_edges()
	
	return friendly

func validate_solution(code: String, expected_output: String) -> Dictionary:
	var compiler = LoxCompiler.new()
	var result = compiler.execute_code(code)
	
	# Debug: mostra o que está sendo comparado
	print("DEBUG - Expected output: '", expected_output, "'")
	print("DEBUG - Compiler result: ", result)
	
	if not result.success:
		var friendly_error = _format_friendly_error(result.error)
		return {
			"valid": false,
			"message": friendly_error
		}
	
	var output = result.output.strip_edges()
	expected_output = expected_output.strip_edges()
	
	# Debug
	print("DEBUG - Raw output: '", output, "'")
	print("DEBUG - Raw expected: '", expected_output, "'")
	
	# Remove quebras de linha extras e espaços
	output = output.replace("\n", " ").replace("\r", " ").replace("  ", " ").strip_edges()
	expected_output = expected_output.replace("\n", " ").replace("\r", " ").replace("  ", " ").strip_edges()
	
	# Debug
	print("DEBUG - Cleaned output: '", output, "'")
	print("DEBUG - Cleaned expected: '", expected_output, "'")
	
	# Compara output
	# Para números, compara diretamente
	# Para strings, compara case-insensitive
	var output_match = false
	
	# Tenta comparação numérica primeiro
	if output.is_valid_float() and expected_output.is_valid_float():
		var output_num = float(output)
		var expected_num = float(expected_output)
		output_match = abs(output_num - expected_num) < 0.0001
		print("DEBUG - Numeric comparison: ", output_num, " == ", expected_num, " -> ", output_match)
	else:
		# Comparação de strings (case-insensitive)
		var output_lower = output.to_lower()
		var expected_lower = expected_output.to_lower()
		output_match = output_lower == expected_lower
		print("DEBUG - String comparison: '", output_lower, "' == '", expected_lower, "' -> ", output_match)
	
	if output_match:
		return {
			"valid": true,
			"message": "✓ Desafio concluído!",
			"output": output
		}
	else:
		return {
			"valid": false,
			"message": "Output esperado: '%s', mas obteve: '%s'" % [expected_output, output],
			"expected": expected_output,
			"got": output
		}
