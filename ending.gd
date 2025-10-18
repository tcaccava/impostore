extends CanvasLayer

@onready var final_text = $EndingText
@onready var replay_button = $RestartButton

var is_victory = true

func _ready():
	final_text.bbcode_enabled = true
	final_text.modulate = Color(1,1,1,1)
	replay_button.text = "PLAY AGAIN"
	
	if is_victory:
		final_text.text = "Your developer rank is legendary, and thanks to your skills, you have saved the world once again."
	else:
		final_text.text = "Noob. If you hadn’t wasted time playing ping pong during the piscine, the world would be safe now, dummy."

	replay_button.visible = true

func _on_restart_button_pressed() -> void:
	get_tree().change_scene_to_file("res://startscreen.tscn")
