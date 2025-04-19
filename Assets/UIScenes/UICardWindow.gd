extends TextureRect

class_name UICardWindow

var currentCardName : String
var hovering : bool = false
var cardObject : Card
var cardDisplay : CardDisplay

func _ready():
	cardDisplay = get_parent().get_parent()

func _process(delta):
	if hovering && currentCardName != null:
		BoardManager.playerUI.ShowNewCard(cardObject)
	if !hovering && currentCardName == null:
		BoardManager.playerUI.ClearTags()
	if hovering && Input.is_action_just_pressed("mouseInteract"):
		cardDisplay.MakeChoice(self)

func SetImage(cardName : String, filePath : String):
	self.texture = load(filePath)
	currentCardName = cardName
	cardObject = load(JSONAndLoadHandler.resourceLocationsDict["Card:" + currentCardName]).instantiate()
	cardObject.addToBoard = false
	get_tree().root.add_child(cardObject)
	cardObject.position -= Vector3(0, 10, 0)


func OnMouseEnter():
	hovering = true


func OnMouseExit():
	hovering = false


func OnDestroy():
	cardObject.queue_free()
	self.queue_free()
