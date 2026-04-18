extends SubViewport

var screen_size : Vector2

func _ready() -> void:
	update_size()
	
	get_window().size_changed.connect(update_size)

func update_size():
	screen_size = get_window().size
	size = screen_size;
