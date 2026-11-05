extends Node
## Nhạc nền + tiếng môi trường (mưa) + hiệu ứng âm thanh. Autoload "Audio".
##   Audio.music("cafe_day")   -> res://assets/audio/music/cafe_day.ogg (tự lặp)
##   Audio.ambient("rain_loop") / Audio.ambient("")  -> bật / tắt tiếng mưa
##   Audio.sfx("meow")         -> res://assets/audio/sfx/meow.ogg
## File không tồn tại thì bỏ qua (không crash).

const MUSIC_DIR := "res://assets/audio/music/"
const SFX_DIR := "res://assets/audio/sfx/"
const MUSIC_DB := -9.0
const AMBIENT_DB := -10.0

var _music: AudioStreamPlayer
var _ambient: AudioStreamPlayer
var _current := ""
var _current_ambient := ""
var _music_tween: Tween


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_music = AudioStreamPlayer.new()
	add_child(_music)
	_ambient = AudioStreamPlayer.new()
	add_child(_ambient)


func _vol(base_db: float, kind: String) -> float:
	var v: float = clampf(float(GameState.settings.get(kind, 1.0)), 0.0, 1.0)
	if v <= 0.001:
		return -80.0
	return base_db + linear_to_db(v)


func refresh_volume() -> void:
	_music.volume_db = _vol(MUSIC_DB, "music")
	_ambient.volume_db = _vol(AMBIENT_DB, "sfx")


func _load_loop(path: String) -> AudioStream:
	if not ResourceLoader.exists(path):
		return null
	var s := load(path) as AudioStream
	if s is AudioStreamOggVorbis:
		(s as AudioStreamOggVorbis).loop = true
	elif s is AudioStreamMP3:
		(s as AudioStreamMP3).loop = true
	return s


func music(track: String, fade: float = 1.2) -> void:
	if track == "":
		stop_music(fade)
		return
	if track == _current:
		return
	var stream := _load_loop(MUSIC_DIR + track + ".ogg")
	if stream == null:
		return
	_current = track
	if _music_tween:
		_music_tween.kill()
	_music_tween = create_tween()
	if _music.playing:
		_music_tween.tween_property(_music, "volume_db", -40.0, fade * 0.5)
	_music_tween.tween_callback(func() -> void:
		_music.stream = stream
		_music.volume_db = -40.0
		_music.play())
	_music_tween.tween_property(_music, "volume_db", _vol(MUSIC_DB, "music"), fade * 0.5)


func stop_music(fade: float = 1.0) -> void:
	_current = ""
	if _music_tween:
		_music_tween.kill()
	_music_tween = create_tween()
	_music_tween.tween_property(_music, "volume_db", -40.0, fade)
	_music_tween.tween_callback(_music.stop)


func ambient(track: String) -> void:
	if track == _current_ambient:
		return
	_current_ambient = track
	if track == "":
		var tw := create_tween()
		tw.tween_property(_ambient, "volume_db", -40.0, 1.0)
		tw.tween_callback(_ambient.stop)
		return
	var stream := _load_loop(SFX_DIR + track + ".ogg")
	if stream == null:
		return
	_ambient.stream = stream
	_ambient.volume_db = -40.0
	_ambient.play()
	create_tween().tween_property(_ambient, "volume_db", _vol(AMBIENT_DB, "sfx"), 1.5)


func sfx(track: String, db: float = 0.0, pitch: float = 1.0) -> void:
	var path := SFX_DIR + track + ".ogg"
	if track == "" or not ResourceLoader.exists(path):
		return
	var p := AudioStreamPlayer.new()
	p.stream = load(path)
	p.volume_db = _vol(db, "sfx")
	p.pitch_scale = pitch
	add_child(p)
	p.finished.connect(p.queue_free)
	p.play()
