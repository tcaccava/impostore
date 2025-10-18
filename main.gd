extends Node2D

@onready var crt_screen = $UI/CRTScreen
@onready var choice_container = $UI/ChoiceContainer
@onready var timer = $Timer
@onready var npcs = $NPCs.get_children()

var doors = []
var current_level = 0
var current_question = 0
var current_response = 0

var human_names = ["Antonio", "Lucia", "Ciro", "Gianni", "Rosa", "Marco", "Pietro", "Nadia", "Elena", "Franco"]
var glitchy_names = ["Geeno","Peeno","Neeno","Agosteeno","Abbateeno","Reeno","Leeno"]
var npc_names = []

func _ready():
	if not FileAccess.file_exists("res://data.json"):
		print("Questions not found!")
		return

	var json_text = FileAccess.get_file_as_string("res://data.json")
	var json_result = JSON.parse_string(json_text)
	doors = json_result.result["doors"]
	choose_questions()
	show_question(current_question)

	timer.wait_time = 1.0
	timer.one_shot = false
	timer.start()
	timer.timeout.connect(_on_Timer_timeout)

	assign_npc_names()
	assign_names_to_responses()

func choose_questions():
	for door in doors:
		var questions = door["questions"]
		questions.shuffle()
		door["questions"] = [questions[0]]

func assign_npc_names():
	npc_names.clear()
	var humans = human_names.duplicate()
	humans.shuffle()
	npc_names.append(humans[0])
	npc_names.append(humans[1])

	var glitches = glitchy_names.duplicate()
	glitches.shuffle()
	npc_names.append(glitches[0])

func assign_names_to_responses():
	for door in doors:
		for q in door["questions"]:
			q["responses"][0]["name"] = npc_names[0]
			q["responses"][1]["name"] = npc_names[1]
			q["responses"][2]["name"] = npc_names[2]

func show_question(index):
	crt_screen.clear()
	var q = doors[current_level]["questions"][index]
	crt_screen.append_bbcode("[color=#00FF66][b]Question:[/b] " + q["question"] + "[/color]")
	current_response = 0

func _on_Timer_timeout():
	var q = doors[current_level]["questions"][current_question]
	if current_response < 3:
		var r = q["responses"][current_response]
		crt_screen.append_bbcode("\n[color=#00FF66]" + r["name"] + ": " + r["text"] + "[/color]")
		current_response += 1
	else:
		timer.stop()
		await get_tree().create_timer(2.0).timeout
		next_question()
		timer.start()

func next_question():
	current_question += 1
	if current_question >= doors[current_level]["questions"].size():
		current_question = 0
		current_level += 1
		if current_level >= doors.size():
			crt_screen.append_bbcode("\n[color=#00FF66][b]End of all layers[/b][/color]")
			timer.stop()
			return
	show_question(current_question)
