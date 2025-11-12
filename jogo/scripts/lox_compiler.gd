extends RefCounted

## Wrapper para executar o compilador Lox e capturar output
class_name LoxCompiler

const COMPILER_PATH = "res://../compilador/lox/"
var compiler_dir: String
var java_path: String = "java"

func _init():
	# Encontra o caminho absoluto do compilador
	var project_path = ProjectSettings.globalize_path("res://")
	# Remove /jogo do final se existir
	if project_path.ends_with("/jogo"):
		compiler_dir = project_path.replace("/jogo", "") + "/compilador/lox"
	else:
		# Tenta outros padrões
		compiler_dir = project_path.get_base_dir().get_base_dir() + "/compilador/lox"
	
	# Tenta encontrar Java
	java_path = _find_java()
	
	# Tenta compilar se necessário
	_ensure_compiled()
	
	print("DEBUG - Compiler dir: ", compiler_dir)

func _find_java() -> String:
	# Tenta encontrar java no PATH
	var output = []
	var exit_code = OS.execute("which", ["java"], output, true, false)
	if exit_code == 0 and output.size() > 0:
		return output[0].strip_edges()
	return "java"

func _ensure_compiled():
	# Verifica se LoxRunner.class existe em compiler_dir/lox/LoxRunner.class
	# Porque os arquivos com package lox; são compilados para lox/
	var dir = DirAccess.open(compiler_dir)
	if dir == null:
		push_error("Não foi possível abrir diretório do compilador: " + compiler_dir)
		return
	
	# Verifica se existe o diretório lox/ e o arquivo LoxRunner.class dentro dele
	if dir.dir_exists("lox"):
		var lox_dir = DirAccess.open(compiler_dir + "/lox")
		if lox_dir and lox_dir.file_exists("LoxRunner.class"):
			print("LoxRunner já compilado.")
			return
	
	# Se não existe, compila
	print("Compilando LoxRunner...")
	_compile_java()

## Executa código Lox e retorna resultado
func execute_code(code: String) -> Dictionary:
	var result = {
		"success": false,
		"output": "",
		"error": ""
	}
	
	# Codifica o código em base64 para passar como argumento
	var code_base64 = Marshalls.utf8_to_base64(code)
	
	# Garante que está compilado
	_ensure_compiled()
	
	# Executa o LoxRunner
	# O classpath deve apontar para o diretório que CONTÉM o diretório "lox"
	# Se compiler_dir = /path/to/compilador/lox, o classpath deve ser /path/to/compilador
	var classpath_dir = compiler_dir.get_base_dir()
	var args = ["-cp", classpath_dir, "lox.LoxRunner", code_base64]
	var output = []
	# No Godot 4: OS.execute(path, arguments, output, blocking, read_stderr)
	print("DEBUG - Executando: ", java_path, " com args: ", args)
	print("DEBUG - Classpath: ", classpath_dir)
	print("DEBUG - Compiler dir: ", compiler_dir)
	print("DEBUG - Código (primeiros 100 chars): ", code.substr(0, 100))
	var exit_code = OS.execute(java_path, args, output, true, true)
	
	var full_output = ""
	if output.size() > 0:
		full_output = "\n".join(output)
	
	print("DEBUG - Exit code: ", exit_code)
	print("DEBUG - Full output: '", full_output, "'")
	
	# Parse JSON response
	if full_output.begins_with("{"):
		var json = JSON.new()
		var parse_result = json.parse(full_output)
		if parse_result == OK:
			result = json.get_data()
			print("DEBUG - JSON parsed: ", result)
		else:
			result.error = "Erro ao parsear resposta JSON: " + full_output
			print("DEBUG - JSON parse error: ", parse_result)
	else:
		result.error = "Erro ao executar compilador. Verifique se Java está instalado. Output: " + full_output
	
	return result

func _compile_java() -> Dictionary:
	var result = {"success": false, "error": ""}
	
	# Lista todos os arquivos .java no diretório
	var java_files = []
	var dir = DirAccess.open(compiler_dir)
	if dir == null:
		result.error = "Não foi possível abrir diretório: " + compiler_dir
		return result
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name.ends_with(".java"):
			java_files.append(compiler_dir + "/" + file_name)
		file_name = dir.get_next()
	
	if java_files.is_empty():
		result.error = "Nenhum arquivo .java encontrado em " + compiler_dir
		return result
	
	# Compila todos os arquivos .java
	# Compila para o diretório compiler_dir (que contém o diretório lox/)
	# Os arquivos com package lox; serão colocados em compiler_dir/lox/
	var args = ["-d", compiler_dir.get_base_dir()] + java_files
	var output = []
	# No Godot 4: OS.execute(path, arguments, output, blocking, read_stderr)
	print("DEBUG - Compilando Java com args: ", args)
	var exit_code = OS.execute("javac", args, output, true, true)
	
	if exit_code == 0:
		result.success = true
		print("Compilação bem-sucedida!")
	else:
		var error_msg = "Erro na compilação:\n" + "\n".join(output) if output.size() > 0 else "Erro desconhecido"
		result.error = error_msg
		push_error(result.error)
	
	return result
