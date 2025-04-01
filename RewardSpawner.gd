extends Node3D

class_name RewardSpawner

@export var spawnPoints : Array[Node3D]
var spawnPointFilled : Array[bool]
var parentGroup : BoxGroup

func _ready():
	parentGroup = get_parent()
	for point in range(len(spawnPoints)):
		spawnPointFilled.append(false)


func SpawnReward(reward : String, whichSlot : int):
	if !spawnPointFilled[whichSlot]:
		spawnPointFilled[whichSlot] = true
		var rewardLocation : String = JSONAndLoadHandler.resourceLocationsDict[reward]
		var newObject = load(rewardLocation).instantiate()
		get_parent().get_parent().add_child(newObject)
		print("New Object Parent: ", newObject.get_parent())
		newObject.placeHeightOffset = parentGroup.cardPlaceOffset
		newObject.pickupHeightOffset = parentGroup.pickupHeightOffset
		newObject.global_position = spawnPoints[whichSlot].global_position
		newObject.currentlyOfferedAsReward = true
		newObject.currentRewardSpawner = self
		newObject.currentRewardNumber = whichSlot
		print("	Position of reward", whichSlot, ":", newObject.position)
	else:
		print("PROBLEM")


func AllClear():
	if !spawnPointFilled.has(true):
		return true
	else:
		return false
