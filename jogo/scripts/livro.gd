extends Node2D

@onready var book_button = $book_button
@onready var guide_panel = $guide_panel
@onready var guide_text = $guide_panel/guide_text

var is_open = false
var challenge_callback: Callable

func _ready():
	if book_button:
		book_button.pressed.connect(_on_book_button_pressed)
	else:
		push_error("⚠️ Nó 'book_button' não encontrado!")

	if guide_panel:
		guide_panel.visible = false
	else:
		push_error("⚠️ Nó 'guide_panel' não encontrado!")

	# Define o texto do painel de documentação da linguagem Lox
	if guide_text:
		_update_documentation()
	else:
		push_error("⚠️ Nó 'guide_text' não encontrado!")

func set_challenge_callback(callback: Callable):
	challenge_callback = callback

func _update_documentation():
	if not guide_text:
		return
	
	# Ajusta o tamanho do texto para caber no painel
	if guide_text:
		guide_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		guide_text.vertical_alignment = VERTICAL_ALIGNMENT_TOP
		guide_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	
	# Usa texto simples (sem BBCode) pois Label não suporta BBCode no Godot 4
	guide_text.text = """📖 DOCUMENTAÇÃO DA LINGUAGEM LOX

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

VARIÁVEIS
   var nome = "valor";
   var numero = 42;

IMPRESSÃO
   print "Olá, mundo!";
   print 10 + 5;

OPERADORES ARITMÉTICOS
   +  (adição)
   -  (subtração)
   *  (multiplicação)
   /  (divisão)
   
   Exemplo: print 10 + 5;  // 15
   Exemplo: print 10 * 5;  // 50

OPERADORES DE COMPARAÇÃO
   >   (maior que)
   >=  (maior ou igual)
   <   (menor que)
   <=  (menor ou igual)
   ==  (igual)
   !=  (diferente)

ESTRUTURAS CONDICIONAIS
   if (condicao) {
	 print "verdadeiro";
   } else {
	 print "falso";
   }
   
   if (nota >= 90) {
	 print "A";
   } else if (nota >= 80) {
	 print "B";
   } else {
	 print "C";
   }

CLASSES E OBJETOS
   class Pessoa {
	 init(nome) {
	   this.nome = nome;
	 }
	 
	 ola() {
	   print "Olá, " + this.nome;
	 }
   }
   
   var p = Pessoa("João");
   p.ola();

CONCATENAÇÃO DE STRINGS
   print "Olá" + " " + "Mundo";  // "Olá Mundo"

DICAS
   • Use ponto e vírgula (;) no final
   • Strings são definidas com aspas duplas ("")
   • Números podem ser inteiros ou decimais
   • Use this. para acessar propriedades da classe
   • Substitua "?" pelo código correto nos desafios

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Clique novamente no livro para fechar."""

func _on_book_button_pressed():
	if guide_panel:
		is_open = !is_open
		guide_panel.visible = is_open

		if is_open:
			print("📘 Painel aberto")
			_update_documentation()
		else:
			print("📕 Painel fechado")
			# Chama callback se existir (para recarregar desafio)
			if challenge_callback and challenge_callback.is_valid():
				challenge_callback.call()
	else:
		push_error("⚠️ Tentou acessar guide_panel mas ele é nulo!")
