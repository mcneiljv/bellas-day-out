extends Node

const SAVE_PATH := "user://settings.cfg"

var sfx_muted := false
var music_muted := false

func _ready() -> void:
	_load()
	_apply()

func set_sfx_muted(value: bool) -> void:
	sfx_muted = value
	_apply()
	_save()

func set_music_muted(value: bool) -> void:
	music_muted = value
	_apply()
	_save()

func _apply() -> void:
	_set_bus_mute("SFX", sfx_muted)
	_set_bus_mute("Music", music_muted)

func _set_bus_mute(bus_name: String, muted: bool) -> void:
	var idx := AudioServer.get_bus_index(bus_name)
	if idx == -1:
		push_warning("Audio bus '%s' not found" % bus_name)
		return
	AudioServer.set_bus_mute(idx, muted)

func _load() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) == OK:
		sfx_muted = cfg.get_value("audio", "sfx_muted", false)
		music_muted = cfg.get_value("audio", "music_muted", false)

func _save() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("audio", "sfx_muted", sfx_muted)
	cfg.set_value("audio", "music_muted", music_muted)
	cfg.save(SAVE_PATH)
