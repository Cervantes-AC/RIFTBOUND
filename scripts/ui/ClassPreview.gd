class_name ClassPreview
extends Node2D
## Shows a class's fighter on menu screens and loops idle -> attack animations (uses the real CharacterVisual).

var fighter: Fighter
var class_id := ""
var _t := 0.0
var _style := "slash"


func show_class(id: String, facing: int = 1) -> void:
	if fighter != null:
		fighter.queue_free()
	class_id = id
	fighter = Fighter.new()
	fighter.setup(0, 0, Library.get_class_data(id), "", 1.0, null)
	fighter.facing = facing
	add_child(fighter)
	fighter.set_physics_process(false)  # must come after add_child (entering the tree re-enables it)
	var d := fighter.data
	_style = "slash"
	match d.id:
		"vanguard", "duelist":
			_style = "slash"
		"ranger", "gunslinger":
			_style = "shoot"
		_:
			_style = "cast"
	_t = 0.0


func _process(delta: float) -> void:
	if fighter == null:
		return
	_t += delta
	fighter.anim_time += delta
	var cycle := fmod(_t, 4.0)
	if cycle > 2.6 and cycle < 3.4:
		fighter.state = Fighter.State.ACTION
		fighter.act_style = _style
		fighter.act_progress = (cycle - 2.6) / 0.8
	else:
		fighter.state = Fighter.State.IDLE
