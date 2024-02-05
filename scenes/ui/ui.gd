extends CanvasLayer
class_name UI

@onready var degree_display: NumberDisplay = $SideOptions/DegreeDisplay
@onready var resolution_display: NumberDisplay = $SideOptions/ResolutionDisplay
@onready var eval_min_display: NumberDisplay = $SideOptions/EvalMinDisplay
@onready var eval_max_display: NumberDisplay = $SideOptions/EvalMaxDisplay
@onready var knot_vector: Control = $SideOptions/KnotVectorScroll/KnotVector
@onready var knot_gen_dropdown: OptionButton = $SideOptions/KnotGenDropdown
@onready var knot_gen_button: Button = $SideOptions/KnotGenButton
