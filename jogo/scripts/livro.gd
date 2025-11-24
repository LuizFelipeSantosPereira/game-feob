extends Node2D

@onready var book_button = $book_button
@onready var guide_panel = $guide_panel
@onready var guide_text = $guide_panel/ScrollContainer/VBoxContainer/guide_text
@onready var close_button = $guide_panel/close_button

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
	
	# Conecta o botão de fechar
	if close_button:
		close_button.pressed.connect(_on_close_button_pressed)
	else:
		push_error("⚠️ Nó 'close_button' não encontrado!")

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
	
	# Documentação completa da linguagem Lox
	guide_text.text = """📖 LINGUAGEM LOX

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Implementação: Java Lox (Crafting Interpreters)
Autor: Robert Nystrom
Implementador: Luiz Felipe dos Santos Pereira

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📝 ESTRUTURA LÉXICA

Comentários:
   // Este é um comentário de linha única.

Identificadores:
   • Devem começar com letra ou sublinhado (_)
   • Podem conter letras, dígitos e sublinhados
   • São case-sensitive (maiúsculas/minúsculas importam)
   
   Exemplo:
   var minhaVariavel = 10;
   var _valorOculto = 5;

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔑 PALAVRAS-CHAVE

and      → Operador lógico E
class    → Define uma classe
else     → Bloco alternativo do if
false    → Booleano falso
for      → Laço for
fun      → Define uma função
if       → Condicional
nil      → Valor nulo
or       → Operador lógico OU
print    → Imprime no console
return   → Retorna de uma função
super    → Acessa métodos da superclasse
this     → Referência à instância atual
true     → Booleano verdadeiro
var      → Declara uma variável
while    → Laço while

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 TIPOS DE DADOS

Número:    123, 3.14
String:    "olá", "mundo"
Booleano:  true, false
Nil:       nil (sem valor)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚙️ OPERADORES

Aritméticos:    +, -, *, /
Comparação:     >, >=, <, <=, ==, !=
Lógicos:        and, or, !
Atribuição:     =
Concatenação:   + (em strings)

Exemplo:
   var a = 10 + 5;
   print a > 8;              // true
   print "Olá, " + "mundo!"; // Olá, mundo!

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📦 VARIÁVEIS

   var nome = "Lox";
   var idade;
   idade = 25;

   • Variáveis são declaradas com var
   • Variáveis não inicializadas = nil

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔄 ESTRUTURAS DE CONTROLE

IF:
   if (condicao) {
	 print "Condição verdadeira";
   } else {
	 print "Condição falsa";
   }

WHILE:
   while (x < 10) {
	 x = x + 1;
   }

FOR:
   for (var i = 0; i < 5; i = i + 1) {
	 print i;
   }

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔧 FUNÇÕES

Declaração:
   fun cumprimentar(nome) {
	 print "Olá, " + nome;
   }

Chamada:
   cumprimentar("mundo"); // Olá, mundo

Retorno:
   fun somar(a, b) {
	 return a + b;
   }
   print somar(2, 3); // 5

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🏛️ CLASSES E OBJETOS

Definição:
   class Pessoa {
	 init(nome) {
	   this.nome = nome;
	 }
	 
	 cumprimentar() {
	   print "Oi, eu sou " + this.nome;
	 }
   }

Instanciação:
   var luiz = Pessoa("Luiz");
   luiz.cumprimentar(); // Oi, eu sou Luiz

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📚 BIBLIOTECA PADRÃO

print(valor)  → Imprime um valor na saída padrão
clock()       → Retorna o tempo do sistema em segundos

Exemplo:
   print clock();

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠️ ERROS

Erros são apenas em tempo de execução
(não há verificação de tipos em compilação).

Exemplos:
   print 1 / 0;              // Erro em tempo de execução
   print variavelInexistente; // Variável indefinida

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

💡 DICAS

   • Use ponto e vírgula (;) no final
   • Strings são definidas com aspas duplas ("")
   • Números podem ser inteiros ou decimais
   • Use this. para acessar propriedades da classe
   • Substitua "?" pelo código correto nos desafios

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Clique novamente no livro para fechar."""


func _on_close_button_pressed():
	# Fecha o painel quando o botão X é clicado
	_close_panel()

func _close_panel():
	if guide_panel:
		is_open = false
		guide_panel.visible = false
		print("📕 Painel fechado")
		# Chama callback se existir (para recarregar desafio)
		if challenge_callback and challenge_callback.is_valid():
			challenge_callback.call()

func _on_book_button_pressed():
	if guide_panel:
		is_open = !is_open
		guide_panel.visible = is_open

		if is_open:
			print("📘 Painel aberto")
			_update_documentation()
		else:
			_close_panel()
	else:
		push_error("⚠️ Tentou acessar guide_panel mas ele é nulo!")
