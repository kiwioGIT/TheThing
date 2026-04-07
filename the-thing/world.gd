extends Node3D



var device_scene = preload("res://device.tscn")

@onready var blue = $blue
@onready var red = $red

@onready var blue_wall = $blue_wall
@onready var red_wall = $red_wall

func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func update_walls():
	blue_wall.position = blue.position
	red_wall.position = red.position
	
	blue_wall.look_at(red.position)
	red_wall.look_at(blue.position)

func move_blue(pos : Vector3):
	blue.position = pos
	update_walls()

	


func move_red(pos : Vector3):
	red.position = pos
	update_walls()
	
	
