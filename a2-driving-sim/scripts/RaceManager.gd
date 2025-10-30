extends Node

# Signals
signal time_updated(elapsed: float)   # elapsed time since "GO!"
signal lap_changed(current_lap: int)
signal countdown_tick(value: int)     # 5,4, 3, 2, 1
signal countdown_go()                 # "GO!"
signal race_started()
signal race_over()

# Tunables
@export var target_laps: int = 3
@export var countdown_from: int = 5
@export var countdown_interval: float = 1.0

# State
var _state := "IDLE"                  # IDLE, COUNTDOWN, RUNNING, FINISHED
var _count_val := 0
var _count_accum := 0.0
var elapsed_time := 0.0
var current_lap := 0

var running: bool:
	get: return _state == "RUNNING"

func _ready() -> void:
	reset_race()
	start_countdown()

func _process(delta: float) -> void:
	match _state:
		"COUNTDOWN":
			_countdown_process(delta)
		"RUNNING":
			elapsed_time += delta
			emit_signal("time_updated", elapsed_time)

# Public API
func reset_race() -> void:
	elapsed_time = 0.0
	current_lap = 0
	_state = "IDLE"
	emit_signal("time_updated", elapsed_time)
	emit_signal("lap_changed", current_lap)

func start_countdown() -> void:
	_state = "COUNTDOWN"
	_count_val = countdown_from
	_count_accum = 0.0
	emit_signal("countdown_tick", _count_val)

func _countdown_process(delta: float) -> void:
	_count_accum += delta
	if _count_accum >= countdown_interval:
		_count_accum -= countdown_interval
		_count_val -= 1
		if _count_val >= 1:
			emit_signal("countdown_tick", _count_val)
		else:
			emit_signal("countdown_go")
			_start_race()

func _start_race() -> void:
	_state = "RUNNING"
	emit_signal("race_started")
	emit_signal("time_updated", elapsed_time)
	emit_signal("lap_changed", current_lap)

func pause_race() -> void:
	if _state == "RUNNING":
		_state = "IDLE"

func add_lap() -> void:
	if _state != "RUNNING": return
	current_lap += 1
	emit_signal("lap_changed", current_lap)
	if current_lap >= target_laps:
		_finish_race()

func set_target_laps(laps: int) -> void:
	target_laps = max(1, laps)

func _finish_race() -> void:
	_state = "FINISHED"
	emit_signal("race_over")
