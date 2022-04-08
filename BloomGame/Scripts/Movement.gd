extends KinematicBody2D


const JUMP_FORCE = 700			# Force applied on jumping
const MOVE_SPEED = 250			# Speed to walk with
const GRAVITY = 30				# Gravity applied every second
const MAX_SPEED = 1000000			# Maximum speed the player is allowed to move
const FRICTION_GROUND = 0.5	# The friction while on the ground
const CHAIN_PULL = 30
const CLIMB_SPEED = 100

var velocity = Vector2(0,0)		# The velocity of the player (kept over time)
var chain_velocity := Vector2(0,0)
var can_jump = false			# Whether the player used their air-jump


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			# We clicked the mouse -> shoot()
			$Chain.shoot(event.position - get_viewport().size * 0.5)
		else:
			# We released the mouse -> release()
			$Chain.release()


onready var _animated_sprite_Body = $Body
onready var _animated_sprite_RightArm = $RightArm
onready var _animated_sprite_LeftArm = $LeftArm
onready var _animated_sprite_LeftLeg = $LeftLeg
onready var _animated_sprite_RightLeg = $RightLeg
onready var _animated_sprite_Idle = $IdleSprite
onready var _animated_sprite_Wall_Climb = $TransitionSprite

var time_elapsed = 0.0








func _physics_process(_delta: float) -> void:
	# Walking
	var walk = (Input.get_action_strength("Right") - Input.get_action_strength("Left")) * MOVE_SPEED

	# Falling
	velocity.y += GRAVITY

	# Hook physics
	# you can ignore this cam
	if $Chain.hooked:
		# `to_local($Chain.tip).normalized()` is the direction that the chain is pulling
		chain_velocity = to_local($Chain.tip).normalized() * CHAIN_PULL
		if chain_velocity.y > 0:
			# Pulling down isn't as strong
			chain_velocity.y *= 0.55
		else:
			# Pulling up is stronger
			chain_velocity.y *= 1.65
		if sign(chain_velocity.x) != sign(walk):
			# if we are trying to walk in a different
			# direction than the chain is pulling
			# reduce its pull
			chain_velocity.x *= 0.7
	else:
		# Not hooked -> no chain velocity
		chain_velocity = Vector2(0,0)
	velocity += chain_velocity



#this deals with walking
	velocity.x += walk		# apply the walking
	move_and_slide(velocity, Vector2.UP)	# Actually apply all the forces
	velocity.x -= walk		# take away the walk speed again
	# ^ This is done so we don't build up walk speed over time

	# Manage friction and refresh jump and stuff
	velocity.y = clamp(velocity.y, -MAX_SPEED, MAX_SPEED)	# Make sure we are in our limits
	velocity.x = clamp(velocity.x, -MAX_SPEED, MAX_SPEED)
	var grounded = is_on_floor()
	if grounded:
		velocity.x *= FRICTION_GROUND	# Apply friction only on x (we are not moving on y anyway)
		can_jump = true 				# We refresh our air-jump
		if velocity.y >= 5:		# Keep the y-velocity small such that
			velocity.y = 5		# gravity doesn't make this number huge
	elif is_on_ceiling() and velocity.y <= -5:	# Same on ceilings
		velocity.y = -5
#
	# Jumping
	if Input.is_action_just_pressed("Jump"):
		if grounded:
			velocity.y = -JUMP_FORCE	# Apply the jump-force
		elif can_jump:
			can_jump = false	# Used air-jump
			velocity.y = -JUMP_FORCE
			
			GlobalVariables.isClimbing = false


#my code ends here, everything below is cams
# i commented out some of your movement

	#setting global variable for the kinematicbody's y velocity
	GlobalVariables.yVelocity = velocity.y













	#  Animation 
	if Input.is_action_pressed("Right"):
		
		_animated_sprite_Idle.visible = false
		_animated_sprite_Wall_Climb.visible = false
		_animated_sprite_Body.visible = true
		_animated_sprite_LeftArm.visible = true
		_animated_sprite_LeftLeg.visible = true
		_animated_sprite_RightArm.visible = true
		_animated_sprite_RightLeg.visible = true

		_animated_sprite_Idle.stop()
		_animated_sprite_Idle.frame = 0
		time_elapsed = 0
		
		GlobalVariables.isClimbing = false
	
	elif Input.is_action_pressed("Left"):
	
		#Turns anims on
		_animated_sprite_Idle.visible = false
		_animated_sprite_Wall_Climb.visible = false
		_animated_sprite_Body.visible = true
		_animated_sprite_LeftArm.visible = true
		_animated_sprite_LeftLeg.visible = true
		_animated_sprite_RightArm.visible = true
		_animated_sprite_RightLeg.visible = true

		_animated_sprite_Idle.stop()
		_animated_sprite_Idle.frame = 0
		time_elapsed = 0
		
		GlobalVariables.isClimbing = false
		
		
	elif Input.is_action_just_pressed("EnterClimb"):
		print("enter climb")
		GlobalVariables.isClimbing = true
	elif Input.is_action_pressed("Climb"):
		velocity.y -= CLIMB_SPEED
		
	#Idle anim
	else:
		
		if((velocity.y == 5 && grounded) && (GlobalVariables.isPlanting == false && GlobalVariables.isClimbing == false)):
			_animated_sprite_Idle.visible = true
			_animated_sprite_Wall_Climb.visible = false
			_animated_sprite_Body.visible = false
			_animated_sprite_LeftArm.visible = false
			_animated_sprite_LeftLeg.visible = false
			_animated_sprite_RightArm.visible = false
			_animated_sprite_RightLeg.visible = false
			
			_animated_sprite_Wall_Climb.stop()
			_animated_sprite_Wall_Climb.frame = 0
			
			time_elapsed += _delta
			if(time_elapsed > 3):
				_animated_sprite_Idle.play("Idle")
				
		elif((velocity.y > 5 || velocity.y < 5) && (GlobalVariables.isPlanting == false && GlobalVariables.isClimbing == false)):
			_animated_sprite_Idle.visible = false
			_animated_sprite_Wall_Climb.visible = false
			_animated_sprite_Body.visible = true
			_animated_sprite_LeftArm.visible = true
			_animated_sprite_LeftLeg.visible = true
			_animated_sprite_RightArm.visible = true
			_animated_sprite_RightLeg.visible = true

			_animated_sprite_Wall_Climb.stop()
			_animated_sprite_Wall_Climb.frame = 0
			
			_animated_sprite_Idle.stop()
			_animated_sprite_Idle.frame = 0
			time_elapsed = 0

			_animated_sprite_Body.animation = "TorsoJumpAnim"
			_animated_sprite_Body.flip_h = false

			_animated_sprite_RightArm.animation = "RightArmJumpAnim"
			_animated_sprite_RightArm.flip_h = false

			_animated_sprite_LeftArm.animation = "LeftArmJumpAnim"
			_animated_sprite_LeftArm.flip_h = false

			_animated_sprite_LeftLeg.animation = "LeftLegJumpAnim"
			_animated_sprite_LeftLeg.flip_h = false

			_animated_sprite_RightLeg.animation = "RightLegJumpAnim"
			_animated_sprite_RightLeg.flip_h = false
			
			
			_animated_sprite_Body.play("TorsoJumpAnim")
			_animated_sprite_RightArm.play("RightArmJumpAnim")
			_animated_sprite_LeftArm.play("LeftArmJumpAnim")
			_animated_sprite_LeftLeg.play("LeftLegJumpAnim")
			_animated_sprite_RightLeg.play("RightLegJumpAnim")
			
		elif(GlobalVariables.inPlantArea && GlobalVariables.isPlanting):
			_animated_sprite_Idle.visible = false
			_animated_sprite_Wall_Climb.visible = false
			_animated_sprite_Body.visible = true
			_animated_sprite_LeftArm.visible = true
			_animated_sprite_LeftLeg.visible = true
			_animated_sprite_RightArm.visible = true
			_animated_sprite_RightLeg.visible = true

			_animated_sprite_Wall_Climb.stop()
			_animated_sprite_Wall_Climb.frame = 0
			
			_animated_sprite_Idle.stop()
			_animated_sprite_Idle.frame = 0
			time_elapsed = 0

			_animated_sprite_Body.animation = "TorsoPlantingAnim"
			_animated_sprite_Body.flip_h = false

			_animated_sprite_RightArm.animation = "RightArmPlantingAnim"
			_animated_sprite_RightArm.flip_h = false

			_animated_sprite_LeftArm.animation = "LeftArmPlantingAnim"
			_animated_sprite_LeftArm.flip_h = false

			_animated_sprite_LeftLeg.animation = "LeftLegPlantingAnim"
			_animated_sprite_LeftLeg.flip_h = false

			_animated_sprite_RightLeg.animation = "RightLegPlantingAnim"
			_animated_sprite_RightLeg.flip_h = false
			
			
			_animated_sprite_Body.play("TorsoPlantingAnim")
			_animated_sprite_RightArm.play("RightArmPlantingAnim")
			_animated_sprite_LeftArm.play("LeftArmPlantingAnim")
			_animated_sprite_LeftLeg.play("LeftLegPlantingAnim")
			_animated_sprite_RightLeg.play("RightLegPlantingAnim")
			
			
		elif(GlobalVariables.inClimbArea && GlobalVariables.isClimbing):
			_animated_sprite_Idle.visible = false
			_animated_sprite_Wall_Climb.visible = true
			_animated_sprite_Body.visible = false
			_animated_sprite_LeftArm.visible = false
			_animated_sprite_LeftLeg.visible = false
			_animated_sprite_RightArm.visible = false
			_animated_sprite_RightLeg.visible = false
			
			_animated_sprite_Idle.stop()
			_animated_sprite_Idle.frame = 0
			time_elapsed = 0
			
			_animated_sprite_Wall_Climb.play("TransitionToWall")
			if(_animated_sprite_Wall_Climb.frame == 13):
				_animated_sprite_Wall_Climb.stop()
