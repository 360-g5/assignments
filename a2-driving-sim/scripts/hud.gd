extends CanvasLayer

@export var player_path: NodePath

@onready var player: Node = get_node_or_null(player_path)
@onready var time_label: Label = get_node_or_null("Control/MarginContainer/HBoxContainer/TimeLabel")
@onready var lap_label: Label = get_node_or_null("Control/MarginContainer/HBoxContainer/LapLabel")
@onready var speed_label: Label = get_node_or_null("Control/MarginContainer/HBoxContainer/SpeedLabel")
@onready var countdown_label: Label = get_node_or_null("Control/CenterContainer/CountdownLabel")

func _ready():
	assert(time_label and lap_label and speed_label and countdown_label,
		"HUD labels missing—check node names/paths.")
	RaceManager.time_updated.connect(_on_time_updated)
	RaceManager.lap_changed.connect(_on_lap_changed)
	RaceManager.race_over.connect(_on_race_over)
	RaceManager.race_started.connect(_on_race_started)
	RaceManager.countdown_tick.connect(_on_countdown_tick)
	RaceManager.countdown_go.connect(_on_countdown_go)

	_on_time_updated(RaceManager.elapsed_time)
	_on_lap_changed(RaceManager.current_lap)
	countdown_label.visible = true
	countdown_label.text = ""

func _process(_delta):
	if player:
		var v := _get_velocity(player).length()
		speed_label.text = "Speed: %.0f km/h" % (v * 3.6)

func _get_velocity(n: Node) -> Vector3:
	if "velocity" in n: return n.velocity
	if "linear_velocity" in n: return n.linear_velocity
	return Vector3.ZERO

func _on_time_updated(t: float) -> void:
	var m := int(t) / 60
	var s := int(t) % 60
	var cs := int((t - int(t)) * 100)
	if time_label:
		time_label.text = "Elapsed: %02d:%02d.%02d" % [m, s, cs]


func _on_lap_changed(l: int):
	lap_label.text = "Lap %d / %d" % [l, RaceManager.target_laps]

func _on_race_started():
	countdown_label.visible = false
	countdown_label.text = ""

func _on_race_over():
	countdown_label.visible = true
	countdown_label.text = "FINISH"

func _on_countdown_tick(val: int):
	countdown_label.visible = true
	countdown_label.text = str(val)

func _on_countdown_go():
	countdown_label.visible = true
	countdown_label.text = "GO!"
