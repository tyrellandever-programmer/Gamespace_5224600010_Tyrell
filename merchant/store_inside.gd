extends PanelContainer

signal item_buy_pressed(id)

@onready var texture = $HBoxContainer/MarginContainer/TextureRect

@onready var title = $HBoxContainer/MarginContainer2/VBoxContainer/Label
@onready var description = $HBoxContainer/MarginContainer2/VBoxContainer/Label2

var id : int

func setup(data: Dictionary, p_id:int) -> void:
	texture.texture = load(data.get("icon_path"))
	title.text = load(data.get("title",""))
	description.text = load(data.get("description",""))
	id = p_id
	
	if data.get("custom_button_text"):
		button.text = data.get("custom_button_text")
	
func _on_buuton_pressed():
	emit_signal("item_buy_pressed",id)
