extends CharacterBody3D



const JUMP_VELOCITY = 4.5

var SPEED = 3.0
var walking_speed = 3.0
var running_speed = 5.0
var is_running = false

var is_locked = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var camera_mount = $CameraMount
@onready var animation_player = $visuals/AnimationPlayer
@onready var visuals = $visuals



var sens_horizontal = 0.2
var sens_vertical = 0.1


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * sens_horizontal))
		visuals.rotate_y(deg_to_rad(event.relative.x * sens_horizontal)) # set visuals static, this keep visuals does not look at mouse direction on idle state

		camera_mount.rotate_x(deg_to_rad(event.relative.y * sens_vertical))
		camera_mount.rotation.x = clamp(camera_mount.rotation.x, deg_to_rad(-60), deg_to_rad(30)) # set rotate camera amount to certain degree

func _physics_process(delta):
	
	if !animation_player.is_playing():
		is_locked = false
	
	# Handle kick
	if Input.is_action_just_pressed("jab") and is_on_floor():
		if animation_player.current_animation != "jab":
			animation_player.play("jab")
			is_locked = true
	
	# Handle run.
	if Input.is_action_pressed("run") and is_on_floor():
		SPEED = running_speed
		is_running = true
	else:
		SPEED = walking_speed
		is_running = false
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		print("jump")
		if animation_player.current_animation != "jump":
			animation_player.play("jump")
			is_locked = true
		#velocity.y = JUMP_VELOCITY # this should be applied to mesh as well to actually get top velocity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction and is_on_floor():
		if !is_locked:
			if is_running:
				if animation_player.current_animation != "run":
					animation_player.play("run")
			else:
				if animation_player.current_animation != "walk":
					animation_player.play("walk")
			visuals.look_at(position + direction)
			
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		if !is_locked:
			if animation_player.current_animation != "idle":
				animation_player.play("idle")
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	if !is_locked:
		move_and_slide()
