extends CenterContainer

class_name RadialProgressBar

signal cooldownOver

@export var progressCircle : TextureProgressBar
@export var stopwatch : Label
@export var timer : Timer

var currentlyActive : bool = false
var currentTimeLeft : float


func _process(delta):
	if currentlyActive:
		currentTimeLeft = timer.get_time_left()
		print(currentTimeLeft)
		stopwatch.text = str(int(currentTimeLeft))
		progressCircle.value = currentTimeLeft
		if currentTimeLeft <= 0:
			FinishCooldown()


func ActivateCooldown(howLong : float):
	currentlyActive = true
	print("Activating Cooldown for ", howLong, " seconds from RadialProgressBar")
	timer.start(howLong)
	progressCircle.max_value = howLong
	progressCircle.value = howLong


func FinishCooldown():
	print("Cooldown finished from RadialProgressBar")
	currentlyActive = false
	cooldownOver.emit()
