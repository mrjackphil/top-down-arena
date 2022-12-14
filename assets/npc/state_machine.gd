extends Node3D
class_name StateMachine


const IDLE_TIME_SEC = 3
const ENGAGE_TIME_SEC = 3

@onready var _idle_timer: Timer = $IdleTimer
@onready var _engage_timer: Timer = $EngageTimer


# Possible NPC states.
enum State {
	IDLE,	# Just stay at current point.
	PATROL,	# Movement along a given trajectory.
	ENGAGE,	# Wanna kick some asses.
	FIRING,	# Fire at enemies.
}

signal state_changed(state: State, prev_state: State)

# Current NPC state.
var _state: State = State.IDLE:
	get:
		return _state
	set(state):
		if state == _state:
			return
		
		_state = _parse_new_state(state)

# Mech under state machine.
var mech: Mech = null
# Main NPC node.
var npc: CharacterBody3D = null

# Group of current mech enemies.
var enemy_group: String = GLOBALS.ALLY_GROUP
# Approaching enemies.
var found_enemies: Array = []
# Targets to fire.
var target_objects: Array = []
# Is NPC pushing enemies.
var _pushing: bool = false

func _physics_process(delta: float) -> void:
	if mech == null or npc == null:
		return
	
	global_transform = npc.global_transform
	
	match _state:
		State.IDLE:
			_parse_idle_state()
		State.PATROL:
			_parse_patrol_state()
		State.ENGAGE:
			_parse_engage_state(delta)
		State.FIRING:
			_parse_firing_state(delta)
		_:
			print('Unable to get ', name, ' state')


# Just staying.
func _parse_idle_state() -> void:
	if _idle_timer.is_stopped():
		_idle_timer.start(IDLE_TIME_SEC)
	
	_stop_movement()
	
	var direction: Vector3 = Vector3(0, 0, 0)
	mech.update_body_direction(direction)
	mech.update_weapons_direction(direction)


# Moving along a given trajectory.
func _parse_patrol_state() -> void:
	pass


# Aim to found enemies.
func _parse_engage_state(delta: float) -> void:
	if found_enemies.is_empty():
		print('state machine of ', name, ' is broken')
		return
	
	if _engage_timer.is_stopped():
		_engage_timer.start(ENGAGE_TIME_SEC)
	
	_aim_to_target(found_enemies.front())
	
	if _pushing:
		_move_to(found_enemies.front().global_transform.origin, delta)


# Try to kick enemy ass.
func _parse_firing_state(delta: float) -> void:
	if target_objects.is_empty():
		print('state machine of ', name, ' is broken')
		return
	
	_aim_to_target(target_objects.front())
	_move_to(target_objects.front().global_transform.origin, delta)
	
	if mech.reloaded:
		mech.spawn_bullet()


# Move npc to point.
func _move_to(point: Vector3, delta: float) -> void:
	if npc == null:
		print('no parent found for ', name)
		return
	
	# BUG: works not as expected
	point = point.normalized()
	npc.velocity.x = point.x * mech.mech_speed * delta
	npc.velocity.z = point.z * mech.mech_speed * delta
	
	mech.update_legs_direction(point.rotated(Vector3.UP, PI/2))
	npc.move_and_slide()


# Stop npc movement.
func _stop_movement() -> void:
	npc.velocity.x = move_toward(npc.velocity.x, 0, mech.mech_speed)
	npc.velocity.z = move_toward(npc.velocity.z, 0, mech.mech_speed)


# Rotate to target.
func _aim_to_target(target: Node) -> void:
	var direction: Vector3 = target.global_transform.origin
	direction = direction.rotated(Vector3.FORWARD, PI)
	mech.update_body_direction(direction)
	mech.update_weapons_direction(direction)


# Checking new state.
func _parse_new_state(state: State) -> int:
	if state in [State.IDLE, State.PATROL]:
		_engage_timer.stop()
		_pushing = false
	elif state in [State.ENGAGE, State.FIRING]:
		_idle_timer.stop()
	
	emit_signal("state_changed", state, _state)
	return state


# Check if someone wants some bullets.
func _on_detection_zone_body_entered(body: Node) -> void:
	if body.is_in_group(enemy_group):
		found_enemies.append(body)
		if _state != State.FIRING:
			_state = State.ENGAGE


# Fire at bastard in fire zone.
func _on_fire_zone_body_entered(body: Node) -> void:
	if body.is_in_group(enemy_group):
		target_objects.append(body)
		_state = State.FIRING
		_pushing = false


# Check if enemy is gone.
# TODO: check if dying parses as body exited.
func _on_detection_zone_body_exited(body: Node) -> void:
	if body in found_enemies:
		found_enemies.erase(body)
		if found_enemies.is_empty():
			_state = State.IDLE


# Check if enemy is gone from fire zone.
# TODO: check if dying parses as body exited.
func _on_fire_zone_body_exited(body):
	if body in target_objects:
		target_objects.erase(body)
		if target_objects.is_empty():
			if found_enemies.is_empty():
				_state = State.IDLE
			else:
				_state = State.ENGAGE


# Start patroling on stopping idle.
func _on_idle_timer_timeout():
	_state = State.PATROL


# Start pushing enemies.
func _on_engage_timer_timeout():
	_pushing = true
