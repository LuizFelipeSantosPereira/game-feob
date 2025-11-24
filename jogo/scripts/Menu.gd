extends Node2D

@onready var video_player = $CanvasLayer/VideoPlayer
@onready var vbox_container = $CanvasLayer/VBoxContainer
@onready var title_label = $CanvasLayer/Title
@onready var left_arrow = $CanvasLayer/LeftArrow
@onready var right_arrow = $CanvasLayer/RightArrow
@onready var menu_buttons = [
	$CanvasLayer/VBoxContainer/StartGameButton,
	$CanvasLayer/VBoxContainer/QuitGameButton
]

var current_index := 0
var video_playing := false

func _ready():
	# Carrega o vídeo pelo script
	if video_player:
		# Tenta carregar o MP4
		var video_path = "res://sprites/animacao_cidade_ofc.mp4"
		var video_stream = load(video_path)
		
		if not video_stream or video_stream.get_class() != "VideoStream":
			# Tenta carregar como OGV como fallback
			video_stream = load("res://sprites/animacao_cidade_final.ogv")
		
		if video_stream:
			video_player.stream = video_stream
		
		# Configura o vídeo para ocupar toda a tela
		_setup_video_fullscreen()
		
		# Carrega e pausa no primeiro frame
		_init_video_background()
	
	# Garante que o vídeo ocupa toda a tela após alguns frames
	await get_tree().process_frame
	await get_tree().process_frame
	_apply_video_fullscreen()
	
	# Reaplica após o vídeo carregar para garantir que não há margens
	await get_tree().process_frame
	_apply_video_fullscreen()
	
	# Esconde as setas permanentemente
	if left_arrow:
		left_arrow.visible = false
	if right_arrow:
		right_arrow.visible = false
	
	# Atualiza a seleção inicial
	await get_tree().process_frame
	_update_selection()

func _apply_video_fullscreen():
	if not video_player:
		return
	
	# Garante que o vídeo ocupa toda a viewport com margens iguais
	var viewport_size = get_viewport().get_visible_rect().size
	
	# Configura os anchors para Full Rect
	video_player.anchors_preset = 15
	video_player.anchor_left = 0.0
	video_player.anchor_top = 0.0
	video_player.anchor_right = 1.0
	video_player.anchor_bottom = 1.0
	
	# Configura os offsets para ocupar toda a viewport (vídeo movido para baixo para não encostar no topo)
	video_player.offset_left = -50
	video_player.offset_top = 40
	video_player.offset_right = viewport_size.x + 50
	video_player.offset_bottom = viewport_size.y + 140
	
	# Usa scale para aumentar o vídeo um pouco
	video_player.scale = Vector2(1.1, 1.1)

func _setup_video_fullscreen():
	if not video_player:
		return
	
	# Configura o vídeo para ocupar toda a tela
	var viewport_size = get_viewport().get_visible_rect().size
	
	# Configura os anchors para Full Rect
	video_player.anchors_preset = 15
	video_player.anchor_left = 0.0
	video_player.anchor_top = 0.0
	video_player.anchor_right = 1.0
	video_player.anchor_bottom = 1.0
	
	# Configura os offsets para ocupar toda a viewport com margens iguais em cima e embaixo
	var margin = 50
	video_player.offset_left = -margin
	video_player.offset_top = -margin
	video_player.offset_right = viewport_size.x + margin
	video_player.offset_bottom = viewport_size.y + margin
	
	# Usa scale para aumentar o vídeo um pouco
	video_player.scale = Vector2(1.1, 1.1)
	
	# Garante visibilidade
	video_player.visible = true

func _init_video_background():
	if not video_player:
		return
		
	# Reproduz brevemente para carregar o primeiro frame
	video_player.stream_position = 0.0
	video_player.paused = false
	video_player.play()
	
	# Espera o vídeo carregar alguns frames
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(0.15).timeout
	
	# Pausa no primeiro frame
	video_player.paused = true
	video_player.stream_position = 0.0

func _process(_delta):
	if video_playing:
		return
		
	if Input.is_action_just_pressed("ui_down"):
		current_index = (current_index + 1) % menu_buttons.size()
		_update_selection()
	elif Input.is_action_just_pressed("ui_up"):
		current_index = (current_index - 1 + menu_buttons.size()) % menu_buttons.size()
		_update_selection()
	elif Input.is_action_just_pressed("ui_accept"):
		_activate_option()

func _update_selection():
	if menu_buttons.size() == 0:
		return
		
	# Garante que todos os botões têm o mesmo tamanho e estão alinhados
	for button in menu_buttons:
		if button:
			button.custom_minimum_size = Vector2(550, 80)
			button.scale = Vector2(1.0, 1.0)  # Remove qualquer escala
	
	# Esconde as setas
	if left_arrow:
		left_arrow.visible = false
	if right_arrow:
		right_arrow.visible = false
	
	# Destaca o botão selecionado
	for i in range(menu_buttons.size()):
		if i == current_index:
			menu_buttons[i].modulate = Color(1, 1, 1, 1)
			# Não aplica escala para manter alinhamento
		else:
			menu_buttons[i].modulate = Color(0.8, 0.8, 0.8, 0.9)

func _activate_option():
	if video_playing:
		return
		
	match current_index:
		0:
			_on_start_game_pressed()
		1:
			_on_quit_game_pressed()

func _on_start_game_pressed():
	if video_playing:
		return
		
	video_playing = true
	
	# Esconde os elementos do menu
	if vbox_container:
		vbox_container.visible = false
	if title_label:
		title_label.visible = false
	if left_arrow:
		left_arrow.visible = false
	if right_arrow:
		right_arrow.visible = false
	
	# Reproduz o vídeo
	if video_player:
		video_player.paused = false
		video_player.play()

func _on_quit_game_pressed():
	if not video_playing:
		get_tree().quit()

func _on_video_finished():
	# Quando o vídeo terminar, vai direto para o jogo
	get_tree().change_scene_to_file("res://cenas/jogo.tscn")
