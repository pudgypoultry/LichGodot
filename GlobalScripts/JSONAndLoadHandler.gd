extends Node

var jsonCardFilePath = "res://Assets/json/Cards.json"
var jsonBoxFilePath = "res://Assets/json/Boxes.json"
var cardPrimeDict : Dictionary = {}
var cardDescriptionDict : Dictionary = {}
var cardNameDict : Dictionary = {}
var cardTagsDict : Dictionary = {}
var boxDescriptionDict : Dictionary = {}
var boxResultsDict : Dictionary = {}
var boxValidCombosDict : Dictionary = {}
var boxCooldownDict : Dictionary = {}
var boxValidTagsDict : Dictionary = {}
var resourceLocationsDict : Dictionary = {}


func _ready():
	LoadCardJSON(jsonCardFilePath)
	LoadBoxJSON(jsonBoxFilePath)


func GetCardInfo(card : Card):
	var cardStats : Dictionary = {}
	cardStats = {
		"NAME" : card.cardName, 
		"DESCRIPTION" : cardDescriptionDict[card.cardName], 
		"PRIMEID" : cardPrimeDict[card.cardName], 
		"TAGS" : cardTagsDict[card.cardName],
		"RESOURCE_LOCATION" : resourceLocationsDict["Card:" + card.cardName]
	}
	return cardStats


func GetBoxInfo(boxGroup : BoxGroup):
	var boxStats : Dictionary = {}
	boxStats = {
		"NAME" : boxGroup.boxGroupName,
		"DESCRIPTION" : boxDescriptionDict[boxGroup.boxGroupName],
		"VALID_COMBOS" : boxValidCombosDict[boxGroup.boxGroupName],
		"RESULTS" : boxResultsDict[boxGroup.boxGroupName],
		"COOLDOWNS" : boxCooldownDict[boxGroup.boxGroupName],
		"VALID_TAGS" : boxValidTagsDict[boxGroup.boxGroupName],
		"RESOURCE_LOCATION" : resourceLocationsDict["Box:" + boxGroup.boxGroupName]
	}
	return boxStats


func LoadCardJSON(path : String):
	var file = FileAccess.open(path, FileAccess.READ)
	
	if file:
		var json_text = file.get_as_text().strip_edges(true, true)
		var json = JSON.new()
		var parse_result = json.parse(json_text)
		
		if parse_result == OK:
			var data = json.data
			if data is Dictionary:
				for key in data.keys():
					if "NAME" in data[key]:
						if "DESCRIPTION" in data[key]:
							cardDescriptionDict[data[key]["NAME"]] = data[key]["DESCRIPTION"]
						if "PrimeID" in data[key]:
							cardPrimeDict[data[key]["NAME"]] = data[key]["PrimeID"]
						if "TAGS" in data[key]:
							cardTagsDict[data[key]["NAME"]] = data[key]["TAGS"]
						if "RESOURCE_LOCATION" in data[key]:
							resourceLocationsDict["Card:" + data[key]["NAME"]] = data[key]["RESOURCE_LOCATION"]
				print("Extracted dictionary:", cardPrimeDict)  # Debugging output
			else:
				print("Error: JSON data is not a dictionary")
		else:
			print("Error parsing JSON")
	else:
		print("Error opening file")


func LoadBoxJSON(path : String):
	var file = FileAccess.open(path, FileAccess.READ)
	
	if file:
		var json_text = file.get_as_text().strip_edges(true, true)
		var json = JSON.new()
		var parse_result = json.parse(json_text)
		
		if parse_result == OK:
			var data = json.data
			if data is Dictionary:
				for key in data.keys():
					if "NAME" in data[key]:
						if "DESCRIPTION" in data[key]:
							boxDescriptionDict[data[key]["NAME"]] = data[key]["DESCRIPTION"]
						if "VALID_COMBOS" in data[key]:
							boxValidCombosDict[data[key]["NAME"]] = data[key]["VALID_COMBOS"]
						if "RESULT_ARRAY" in data[key]:
							boxResultsDict[data[key]["NAME"]] = data[key]["RESULT_ARRAY"]
						if "COOLDOWN_ARRAY" in data[key]:
							boxCooldownDict[data[key]["NAME"]] = data[key]["COOLDOWN_ARRAY"]
						if "VALID_TAGS" in data[key]:
							boxValidTagsDict[data[key]["NAME"]] = data[key]["VALID_TAGS"]
						if "RESOURCE_LOCATION" in data[key]:
							resourceLocationsDict["Box:" + data[key]["NAME"]] = data[key]["RESOURCE_LOCATION"]
				# print("Extracted dictionary:", cardPrimeDict)  # Debugging output
			else:
				print("Error: JSON data is not a dictionary")
		else:
			print("Error parsing JSON")
	else:
		print("Error opening file")
