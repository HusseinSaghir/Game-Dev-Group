extends Node
# AudioManager - Global audio controller accessible from anywhere
# This is an Autoload (singleton) - only one exists in the entire game
# Access it from any script with: AudioManager.play_sfx() or AudioManager.set_music_volume()
# Audio bus indices (must match Project Settings > Audio > Buses)
const MUSIC_BUS = "Music"
const SFX_BUS = "SFX"
# Current volume levels (0.0 to 1.0)
var music_volume: float = 0.7
var sfx_volume: float = 0.8
# Audio players - we'll create these in _ready()
var music_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer
func _ready():
	# Create audio players
	music_player = AudioStreamPlayer.new()
	music_player.bus = MUSIC_BUS
	add_child(music_player)
	
	sfx_player = AudioStreamPlayer.new()
	sfx_player.bus = SFX_BUS
	add_child(sfx_player)
	
	# Load saved volume settings
	load_audio_settings()

# Load volume settings from file
func load_audio_settings():
	var config = ConfigFile.new()
	var err = config.load("user://audio_settings.cfg")
	
	if err == OK:
		music_volume = config.get_value("audio", "music_volume", 0.7)
		sfx_volume = config.get_value("audio", "sfx_volume", 0.8)
	else:
		# No config file exists - use defaults
		music_volume = 0.7
		sfx_volume = 0.8
	
	# Don't allow volumes below 0.1 (prevent silent defaults)
	if music_volume < 0.1:
		music_volume = 0.7
	if sfx_volume < 0.1:
		sfx_volume = 0.8
	
	# Apply loaded volumes
	set_music_volume(music_volume)
	set_sfx_volume(sfx_volume)

# Play background music (loops automatically)
func play_music(stream: AudioStream):
	if music_player.stream != stream:
		music_player.stream = stream
		music_player.play()

# Stop music
func stop_music():
	music_player.stop()

# Play a sound effect once
func play_sfx(stream: AudioStream):
	sfx_player.stream = stream
	sfx_player.play()

# Set music volume (0.0 to 1.0)
func set_music_volume(value: float):
	music_volume = clamp(value, 0.0, 1.0)
	var bus_idx = AudioServer.get_bus_index(MUSIC_BUS)
	# Convert linear 0-1 to decibels (dB) for AudioServer
	AudioServer.set_bus_volume_db(bus_idx, linear_to_db(music_volume))
	save_audio_settings()

# Set SFX volume (0.0 to 1.0)
func set_sfx_volume(value: float):
	sfx_volume = clamp(value, 0.0, 1.0)
	var bus_idx = AudioServer.get_bus_index(SFX_BUS)
	AudioServer.set_bus_volume_db(bus_idx, linear_to_db(sfx_volume))
	save_audio_settings()

# Save volume settings to file
func save_audio_settings():
	var config = ConfigFile.new()
	config.set_value("audio", "music_volume", music_volume)
	config.set_value("audio", "sfx_volume", sfx_volume)
	config.save("user://audio_settings.cfg")
