extends Interactable

class_name BoxGroup

signal cooldownStarted(boxGroup : BoxGroup, howLong : float)
enum ExecutionState {READY, EXECUTING, COMPLETE}

@export_category("Game Rules")
@export var boxGroupName : String
var boxGroupDescription : String
var validTypes : Array[Card.CardType]
var validCombos : Array

@export_category("Optional Setup")
@export var slottedCards : Dictionary

@export_category("Handling Results")
var cooldownArray : Array
var resultArray
@export var cardPlaceOffset : float = 0.151

@export_category("Plugging In Nodes")
@export var boxes : Array[Box]
@export var executeButton : Area3D
@export var progressBar : RadialProgressBar
@export var progressBarMesh : MeshInstance3D
@export var rewardSpawner : RewardSpawner

var isHoveringExecute : bool = false
var currentExecutionState : ExecutionState = ExecutionState.READY
var currentlyAccepting : bool = true
var currentlyPresenting : bool = false


static func MakeCopy(newBoxGroupName : String, newParent : Node3D) -> BoxGroup:
	var instance = BoxGroup.new()
	instance.cardName = newBoxGroupName
	newParent.add_child(instance)
	return instance


#func _ready():
	#BoardManager.AddCardToTable(self)
	#placeHeightOffset = position.y
	#currentRank = baseRank
	#var cardStats = CardComboHandler.GetCardInfo(self)
	#cardDescription = cardStats["DESCRIPTION"]
	#cardPrimeID = cardStats["PRIMEID"]
	#TransferArrayBecauseWTF(cardStats["TAGS"])


func _ready():
	BoardManager.AddBoxGroupToTable(self)
	progressBarMesh.set_visible(false)
	placeHeightOffset = position.y
	var boxStats = JSONAndLoadHandler.GetBoxInfo(self)
	boxGroupDescription = boxStats["DESCRIPTION"]
	validCombos = boxStats["VALID_COMBOS"]
	resultArray = boxStats["RESULTS"]
	cooldownArray = boxStats["COOLDOWNS"]
	var typeStrings = boxStats["VALID_TAGS"]
	for item in typeStrings:
		# {NONE, COMPONENT, SPELL, MINION, LOCATION, DEATH}
		match item:
			"NONE":
				validTypes.append(Card.CardType.NONE)
			"COMPONENT":
				validTypes.append(Card.CardType.COMPONENT)
			"SPELL":
				validTypes.append(Card.CardType.SPELL)
			"MINION":
				validTypes.append(Card.CardType.MINION)
			"LOCATION":
				validTypes.append(Card.CardType.LOCATION)
			"DEATH":
				validTypes.append(Card.CardType.DEATH)
	print("===========================")
	print(boxGroupDescription)
	print("===========================")
	print(resultArray)
	print("===========================")
	print(cooldownArray)
	print("===========================")
	print(validTypes)
	print("===========================")
	for box in boxes:
		box.validTypes = validTypes
		box.currentGroup = self
		box.boxName = boxGroupName
		box.boxDescription = boxGroupDescription
		if box.hasCard:
			slottedCards[box] = box.currentCard
		else:
			slottedCards[box] = null


func _process(delta):
	super(delta)
	if Input.is_action_just_pressed("mouseInteract") && isHoveringExecute:
		var currentCards : Array[Card] = []
		for card in slottedCards.values():
			currentCards.append(card)
		HandleResult(FindPrimeResult(currentCards))
	if currentExecutionState == ExecutionState.COMPLETE && rewardSpawner.AllClear():
		print("		All clear")
		ManageExecutionState(ExecutionState.READY)


"""=====================================================
Handle Game Actions
====================================================="""

func NewCardSlotted(box : Box):
	slottedCards[box] = box.currentCard
	if IsValidCombo(boxes):
		print("Valid combo after new card added!")


func CardUnslotted(box : Box):
	slottedCards[box] = null
	if IsValidCombo(boxes):
		print("Valid combo after old card left!")


"""=====================================================
Card Combination Validation
====================================================="""

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


func FindPrimeResult(cards : Array[Card]):
	print("Finding current prime result of: ", cards)
	var result = 1
	
	for card in cards:
		if card != null:
			result = result * card.cardPrimeID
	
	return result


func HandleResult(currentProduct : int):
	if currentProduct == 1:
		print("BoxGroup is empty, but button has been pressed!")
		return
	if currentProduct == 2:
		print("Beginning execution of product 2")
		BeginExecution(cooldownArray[0], resultArray[0])
		return



"""=====================================================
Interactable Movement Management
====================================================="""

func PickMeUp():
	if currentlyOfferedAsReward:
		currentRewardSpawner.spawnPointFilled[currentRewardNumber] = false
		currentlyOfferedAsReward = false
		currentRewardSpawner = null
	print("Picking up")
	ManageState(State.PICKEDUP)
	print("Moving to: ", position + Vector3(0, pickupHeightOffset, 0))
	position.y += pickupHeightOffset
	print("Current Position: ", position)


func IsValidDrop():
	if currentlyAbove == null:
		return true
	return false


func DropMe():
	canDrag = true
	if isFaceUp:
		ManageState(State.SETFACEUP)
	else:
		ManageState(State.SETFACEDOWN)
	
	if IsValidDrop() && currentlyAbove == null:
		print("Dropping...")
		TweenTools.TweenPosition(self, tweenPosition, Vector3(position.x, placeHeightOffset, position.z), pickupSpeed)
	else:
		TweenTools.TweenPosition(self, tweenPosition, lastKnownPosition, pickupSpeed)
	
	playerController.currentInteractable = null
	print("Currently Above: ", currentlyAbove)
	currentlyAbove = null


"""=====================================================
Handle Execute Button Actions
====================================================="""

func ExecuteReady():
	print("Ready to click")
	isHoveringExecute = true


func ExecuteUnready():
	print("No longer ready to click")
	isHoveringExecute = false


"""=====================================================
State Machine Logic and Transition Handling
====================================================="""

func BeginExecution(howLong : float, whatRewards : Array):
	ManageExecutionState(ExecutionState.EXECUTING)
	# Disable boxes from being slotted/grey them out
	for box in boxes:
		box.ConsumeCard()
	DisableBoxGroup()
	# Start timer for howLong seconds
	print("Activating progressBar cooldown of ", howLong, " seconds...")
	progressBarMesh.set_visible(true)
	progressBar.ActivateCooldown(howLong)
	# send signal out that cooldown has started
	cooldownStarted.emit(self, howLong)
	# Wait for timer
	await progressBar.cooldownOver
	print("Done waiting")
	# At end of timer, offer rewards associated
	OfferRewards(whatRewards)


func OfferRewards(whatRewards : Array):
	progressBarMesh.set_visible(false)
	ManageExecutionState(ExecutionState.COMPLETE)
	var i = 0 
	for reward in whatRewards:
		print("	Current Reward: ", reward)
		rewardSpawner.SpawnReward(reward, i)
		i += 1


func DisableBoxGroup():
	for box in boxes:
		box.canBeManipulated = false
	currentlyAccepting = false


func EnableBoxGroup():
	for box in boxes:
		box.canBeManipulated = true
	currentlyAccepting = true


func ManageExecutionState(newState : ExecutionState):
	match newState:
		ExecutionState.READY:
			currentExecutionState = ExecutionState.READY
			EnableBoxGroup()
			currentlyPresenting = false
		ExecutionState.EXECUTING:
			DisableBoxGroup()
			currentExecutionState = ExecutionState.EXECUTING
			currentlyPresenting = false
		ExecutionState.COMPLETE:
			currentExecutionState = ExecutionState.COMPLETE
			currentlyPresenting = true
