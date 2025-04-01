extends Control

class_name UIManager

@export var nameLabel : Label
@export var descriptionLabel : Label
@export var typeLabels: Array[Label]


func _ready():
	BoardManager.playerUI = self


func SubscribeToInteractable(newObject : Interactable):
	newObject.gainedFocus.connect(UIUpdateText)
	newObject.lostFocus.connect(ClearTags)


func UIUpdateText(newObject : Interactable):
	if newObject is Card:
		ShowNewCard(newObject)
	if newObject is Box:
		ShowNewBox(newObject)
	if newObject is BoxGroup:
		ShowNewBoxGroup(newObject)


func ShowNewBox(newBox : Box):
	ClearTags()
	nameLabel.text = newBox.boxName
	descriptionLabel.text = newBox.boxDescription


func ShowNewBoxGroup(newBoxGroup : BoxGroup):
	ClearTags()
	nameLabel.text = newBoxGroup.boxGroupName
	descriptionLabel.text = newBoxGroup.boxGroupDescription


func ShowNewCard(newCard : Card):
	nameLabel.text = newCard.cardName
	descriptionLabel.text = newCard.cardDescription
	UpdateTags(newCard.cardTags)


func UpdateTags(tags : Array[String]):
	var numTags = len(tags)
	for i in range(len(typeLabels)):
		if i < numTags:
			typeLabels[i].text = tags[i]
		else:
			typeLabels[i].text = ""


func ClearTags():
	nameLabel.text = ""
	descriptionLabel.text = ""
	for tag in typeLabels:
		tag.text = ""
