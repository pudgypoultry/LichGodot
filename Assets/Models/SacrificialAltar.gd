extends BoxGroup

@export var consumptionShader : ShaderMaterial
@export var fireParticles : Node3D

func IsValidCombo(boxArray : Array[Box]):
	var currentCards : Array[Card] = []
	
	for box in slottedCards.keys():
		if slottedCards[box] != null:
			currentCards.append(slottedCards[box])
	var currentProduct = FindPrimeResult(currentCards)
	
	if currentProduct in validCombos:
		print("	->Found a valid combo!")
		return true
	else:
		return false


func HandleResult(currentProduct : int):
	var cardMesh : MeshInstance3D = slottedCards[boxes[0]].cardMesh
	cardMesh.get_active_material(0).set_next_pass(consumptionShader)
	cardMesh.get_active_material(0).get_next_pass().set_shader_parameter("enable_dissolve_animation", true)
	fireParticles.StartMe()
	for i in range(500):
		await get_tree().create_timer(0.01).timeout
		cardMesh.get_active_material(0).get_next_pass().set_shader_parameter("animation_intensity", float(i)/300.0)
		cardMesh.get_active_material(0).get_next_pass().set_shader_parameter("dissolveSlider", 1.5 - float(i)/100.0)
		print(cardMesh.get_active_material(0).get_next_pass().get_shader_parameter("animation_intensity"))

	#await get_tree().create_timer(3).timeout
	#slottedCards[boxes[0]].OnUse()
