extends Node2D

@onready var crt_screen = $UI/CRTScreen
@onready var timer = $Timer
@onready var npcs = $NPCs.get_children()

var doors = []
var current_level = 0
var current_question = 0
var current_response = 0
var awaiting_good_guy = false

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
	if is_last_question():
		ask_good_guy()

func _on_Timer_timeout():
	if awaiting_good_guy:
		return
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
			awaiting_good_guy = true
			return
	show_question(current_question)

func _process(delta):
	if awaiting_good_guy:
		if Input.is_key_pressed(Key.KEY_1):
			check_good_guy(0)
		elif Input.is_key_pressed(Key.KEY_2):
			check_good_guy(1)
		elif Input.is_key_pressed(Key.KEY_3):
			check_good_guy(2)

func is_last_question() -> bool:
	return current_level == doors.size() - 1 and current_question == doors[current_level]["questions"].size() - 1

func ask_good_guy():
	awaiting_good_guy = true
	var q = doors[current_level]["questions"][current_question]
	crt_screen.append_bbcode("\n\n[b]Who is the good guy?[/b]")
	for i in range(3):
		crt_screen.append_bbcode("\n" + str(i+1) + ". " + q["responses"][i]["name"])

func check_good_guy(index):
	awaiting_good_guy = false
	var q = doors[current_level]["questions"][current_question]
	var chosen_role = q["responses"][index]["role_hint"]

	var final_scene = load("res://ending.tscn").instantiate()
	final_scene.is_victory = chosen_role == "good"
	get_tree().change_scene_to_file("res://ending.tscn")
