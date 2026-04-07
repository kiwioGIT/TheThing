extends CharacterBody3D



var accel = 100
var friction = 200
var max_speed = 30

var mouse_captured = false
var jump_force = 20


var gravity = 40
const H_LOOK_SENS = 0.0012
const V_LOOK_SENS = 0.0012


@onready var cam = $Camera3D

@onready var cast = $Camera3D/RayCast3D

@onready var anim = $AnimationPlayer

func _input(event):
	if event is InputEventMouseMotion:
		cam.rotation.x -= event.relative.y * V_LOOK_SENS
		cam.rotation.x = clamp(cam.rotation.x, -PI/2, PI/2)
		rotation.y -= event.relative.x * H_LOOK_SENS

func _ready():
	pass

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if !mouse_captured:
			mouse_captured = true
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			mouse_captured = false
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(delta):
	var friction_modifier = 1
	if is_on_floor():
		if Input.is_action_pressed("slide"):
			friction_modifier = 0.1
		velocity.y = 0
		if Input.is_action_pressed("jump"):
			velocity.y += jump_force
	else:
		friction_modifier = 0.2
		velocity.y -= gravity * delta
	
	var move_vector = Vector3(0,0,0)
	move_vector.x = - Input.get_action_strength("left") + Input.get_action_strength("right")
	move_vector.z = - Input.get_action_strength("forward") + Input.get_action_strength("back")
	move_vector = move_vector.rotated(Vector3(0,1,0),rotation.y)
	move_vector = move_vector.normalized()
	
	if Vector3(velocity.x,0,velocity.z).length() < max_speed:
		velocity.z += move_vector.z * friction_modifier * delta * accel
		velocity.x += move_vector.x * friction_modifier * delta * accel
		if Vector3(velocity.x,0,velocity.z).length() > max_speed:
			velocity.x *= max_speed / Vector3(velocity.x,0,velocity.z).length()
			velocity.z *= max_speed / Vector3(velocity.x,0,velocity.z).length()
	
	var frict_ind = 1 - max(Vector3(velocity.x,0,velocity.z).normalized().dot(move_vector),0)
	var frict_velocity = velocity - Vector3(velocity.x,0,velocity.z).normalized() * friction * friction_modifier * frict_ind * delta
	
	if Vector3(velocity.x,0,velocity.z).dot(frict_velocity) >= 0:
		velocity = frict_velocity
	else:
		velocity.x = 0
		velocity.z = 0
		
	if is_on_floor() and !Input.is_action_pressed("slide"):
		if Vector3(velocity.x,0,velocity.z).length() > max_speed:
			velocity.x *= max_speed / Vector3(velocity.x,0,velocity.z).length()
			velocity.z *= max_speed / Vector3(velocity.x,0,velocity.z).length()
	
	
	if Input.is_action_just_pressed("f"):
		var dash_vector = Vector3(0,0,-1.0).rotated(Vector3(1,0,0),cam.rotation.x)
		dash_vector = dash_vector.rotated(Vector3(0,1,0),rotation.y)
		velocity = dash_vector * velocity.length()
	
	if Input.is_action_just_pressed("right_click"):
		var device_pos = cast.get_collision_point()
		get_parent().move_blue(device_pos)
		anim.play("pif")
		
	
	if Input.is_action_just_pressed("click"):
		var device_pos = cast.get_collision_point()
		get_parent().move_red(device_pos)
		anim.play("pif")
	
	get_node("Label").text = str(Vector3(velocity.x,0,velocity.z).length())
	get_node("Label2").text = str(is_on_floor())
	
	move_and_slide()
