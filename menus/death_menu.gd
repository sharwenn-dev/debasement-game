extends CanvasLayer

@onready var message_box = $Panel/message
@onready var aud = $AudioStreamPlayer
@onready var life = $Panel/life
@onready var death = $Panel/death
var chosen_message = null
var activated = false

@onready var death_sound = preload("res://assets/sound/sfx/death.wav")
@onready var death_sound2 = preload("res://assets/sound/sfx/death2.wav")

@export var death_messages = [
	"You were enough. It was just your time.",
	"What a frail existence. This one has no meaning to give.",
	"No one will remember this one. But it still mattered.",
	"Nothing was learned. But not all stories teach.",
	"You were too light for this place. Still, you reached.",
	"Your death was not special. But it was real.",
	"The others won't know what you saw. That was yours alone.",
	"This was always waiting for you. You still stepped forward.",
	"You returned the way all things do. Quietly, suddenly.",
	"The walls did not echo your name. But they heard it.",
	"You felt everything. Then nothing. It was honest.",
	"Your hunger meant nothing to the void. But it drove you.",
	"Even here, something noticed you. Just for a moment.",
	"You weren't ready. No one ever is.",
	"You were small. That never made you unworthy.",
	"It hurt. That means you were alive.",
	"You tried. That’s more than most things here can say.",
	"The world didn't flinch. But you still struck it."
]


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func activate_death():
	if not activated:
		self.show()
		aud.stream = death_sound
		aud.play()
		await get_tree().create_timer(randf_range(3.0, 6.0)).timeout
		chosen_message = death_messages.pick_random()
		message_box.text = chosen_message
		life.show()
		death.show()
		aud.stream = death_sound2
		aud.play()
		activated = true

func _on_life_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://test_world_2.tscn")

func _on_death_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://menus/main_menu.tscn")
