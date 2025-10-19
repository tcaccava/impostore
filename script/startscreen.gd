extends CanvasLayer

@onready var intro_text = $IntroScreen
@onready var start_button = $StartButton

var fade_in_time = 3.0
var delay_before_button = 2.0
var elapsed = 0.0
var show_button = false

func _ready():
	intro_text.text = """\
YEAR 2048.

The world is split in two factions:
The Developers and the AIs.
Both fight for the nuclear launch codes,
buried deep inside Area 51 servers.

Three entities are entering the bunker.
Two are impostors...and one is
the real good guy.

You, Chief Security Officer of the base,
are the only one who can tell who’s who.

Will you save humanity...
or doom it to a world ruled by
those damn machines?
"""
	intro_text.modulate = Color(1,1,1,0)
	start_button.visible = false
	start_button.text = "START"

func _process(delta):
	if intro_text.modulate.a < 1.0:
		intro_text.modulate.a += delta / fade_in_time
	else:
		if not show_button:
			elapsed += delta
			if elapsed >= delay_before_button:
				start_button.visible = true
				show_button = true

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")
