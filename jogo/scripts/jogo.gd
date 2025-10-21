extends Node2D

@onready var input_code = $Control/TextEdit
@onready var run_button = $Control/Button
@onready var mensagem = $mensagem
@onready var vilao = $vilao/TextureProgressBar

var vilao_vida = 100

func _ready():
	mensagem.text = "Digite um comando e clique em Executar!"
	run_button.pressed.connect(_on_run_button_pressed)
	atualizar_vilao()

func _on_run_button_pressed():
	var code = input_code.text.strip_edges()

	if code == "attack()":
		aplicar_dano(20)
	elif code == "fireball()":
		aplicar_dano(40)
	else:
		mensagem.text = "Comando inválido!"

func aplicar_dano(valor):
	vilao_vida -= valor
	if vilao_vida < 0:
		vilao_vida = 0
	mensagem.text = "Vilão recebeu %s de dano! Vida restante: %s" % [valor, vilao_vida]
	atualizar_vilao()

	if vilao_vida <= 0:
		mensagem.text = "🎉 Vilão derrotado!"

func atualizar_vilao():
	# Se o vilão for um Sprite2D, pode mudar a cor quando leva dano
	if vilao.has_method("modulate"):
		vilao.modulate = Color(1, vilao_vida / 100.0, vilao_vida / 100.0)
