extends RigidBody3D

## amount of vertical force is applied when moving
@export_range(750.0, 3000.0) var thrust_speed: float = 1000.0
## how fast the rocket rotates
@export_range(10.0, 1000.0) var rotate_speed: float = 100.0

@onready var explosion_audio_player: AudioStreamPlayer = $AudioPlayers/ExplosionAudioPlayer
@onready var victory_audio_player: AudioStreamPlayer = $AudioPlayers/VictoryAudioPlayer
@onready var rocket_audio_player: AudioStreamPlayer3D = $AudioPlayers/RocketAudioPlayer

@onready var booster_particles: GPUParticles3D = $ParticleSystems/BoosterParticles
@onready var booster_particles_right: GPUParticles3D = $ParticleSystems/BoosterParticlesRight
@onready var booster_particles_left: GPUParticles3D = $ParticleSystems/BoosterParticlesLeft
@onready var explosion_particles: GPUParticles3D = $ParticleSystems/ExplosionParticles
@onready var success_particles: GPUParticles3D = $ParticleSystems/SuccessParticles

@onready var rocket_body: MeshInstance3D = $Body

var isTransitioning: bool = false


func _process(delta: float) -> void:
	if Input.is_action_pressed("thrust"):
		apply_central_force(basis.y * thrust_speed * delta)
		booster_particles.emitting = true
		if !rocket_audio_player.playing:
			rocket_audio_player.play()
	else:
		booster_particles.emitting = false
		rocket_audio_player.stop()
	
	if Input.is_action_pressed("rotate_left"):
		apply_torque(Vector3(0, 0, rotate_speed * delta))
		booster_particles_right.emitting = true
	else:
		booster_particles_right.emitting = false
	
	if Input.is_action_pressed("rotate_right"):
		apply_torque(Vector3(0, 0, -rotate_speed * delta))
		booster_particles_left.emitting = true
	else:
		booster_particles_left.emitting = false


func _on_body_entered(body: Node) -> void:
	if !isTransitioning:
		if "goal" in body.get_groups():
			complete_level(body.file_path)
		elif "hazard" in body.get_groups():
			crash_sequence()


func crash_sequence() -> void:
	explosion_particles.emitting = true
	explosion_audio_player.play()
	set_process(false) #stops _process() from running, thereby disabling player controls
	isTransitioning = true
	rocket_body.visible = false
	#code block below essentially adds a one second delay before reloading the scene
	var tween = create_tween()
	tween.tween_interval(1.0)
	tween.tween_callback(get_tree().reload_current_scene)


func complete_level(next_level_file: String) -> void:
	success_particles.emitting = true
	victory_audio_player.play()
	set_process(false) #stops _process() from running, thereby disabling player controls
	isTransitioning = true
	#code block below essentially adds a one second delay before loading the next scene
	var tween = create_tween()
	tween.tween_interval(1.0)
	tween.tween_callback(
		get_tree().change_scene_to_file.bind(next_level_file))
