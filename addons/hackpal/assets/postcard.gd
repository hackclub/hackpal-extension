@tool

extends PanelContainer

var from : String
var content : String

func _ready() -> void:
	$VBoxContainer/Label.text = "From : "+from 
	$VBoxContainer/Label2.text = "Content : "+content
