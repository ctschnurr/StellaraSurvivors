@tool
class_name Tool_script extends Resource

var current_properties: Array[Dictionary]

@export var holding_hammer = true:
	set(value):
		holding_hammer = value
		update_properties()
var hammer_type = 0

enum Hammer_modifyer{WEAK, MEDIUM, STRONG, SUPER}
var hammer_mod = Hammer_modifyer.WEAK

func update_properties():
	var current_properties = get_property_list()
	
	if holding_hammer:
		for property in current_properties:
			if property["name"] == "hammer_type" or property["name"] == "hammer_mod":
				property["usage"] = PROPERTY_USAGE_DEFAULT
	
	notify_property_list_changed()
	

func _get_property_list():
	var properties = []
	
	var property_usage = PROPERTY_USAGE_NO_EDITOR

	if holding_hammer:
		property_usage = PROPERTY_USAGE_DEFAULT


	properties.append({
		"name": "hammer_type",
		"type": TYPE_INT,
		"usage": property_usage, # See above assignment.
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": "Wooden,Iron,Golden,Junk"
		})
		
	properties.append({
		"name": "hammer_mod",
		"type": TYPE_INT,
		"usage": property_usage, # See above assignment.
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": "Wooden,Iron,Golden,Junk"
	})

	return properties
