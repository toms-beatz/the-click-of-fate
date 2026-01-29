extends Node

# Simple watchdog that logs when a single frame takes longer than `threshold` seconds.
@export var threshold: float = 0.12
@export var log_file: String = "user://perf_watchdog.log"

var _last_time: float = 0.0

func _ready() -> void:
	_last_time = OS.get_ticks_msec() / 1000.0

func _process(delta: float) -> void:
	var now := OS.get_ticks_msec() / 1000.0
	var frame_time := now - _last_time
	_last_time = now
	if frame_time > threshold:
		var msg := "Slow frame: %.3fs at scene=%s\n" % [frame_time, get_tree().get_current_scene().name if get_tree().get_current_scene() else "(no-scene)"]
		print(msg)
		# Append to persistent log for later analysis
		var f := File.new()
		if f.open(log_file, File.WRITE_READ) == OK:
			f.seek_end()
			f.store_string(msg)
			f.close()
*** End Patch