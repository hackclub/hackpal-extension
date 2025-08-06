@tool
extends Control

const threedENV = preload("res://addons/hackpal/hackpad_3d_env.tscn")
var slack_id = "U041FQB8VK2"
var postcards = []


func _ready() -> void:
	$HackyViewport.add_child(threedENV.instantiate())
	$HackyTextureReck.texture = $HackyViewport.get_texture()
	$HTTPRequest.request_completed.connect(_on_request_completed)
	fetch_postcards()

func _on_texture_rect_resized() -> void:
	$HackyViewport.size = $HackyTextureReck.size

func _process(delta: float) -> void:
	$HackyTextureReck.texture = $HackyViewport.get_texture()


func fetch_postcards():
	var url = "https://kosskwc8gk4ckkcg4csg484c.a.selfhosted.hackclub.com/api/getPostcards?slackId=%s" % slack_id
	var err = $HTTPRequest.request(url)
	if err != OK:
		push_error("Failed to make HTTP request: %s" % err)


func _on_request_completed(result, response_code, headers, body):
	if response_code != 200:
		push_error("Failed to fetch postcards, response code: %s" % response_code)
		return

	var json = JSON.parse_string(body.get_string_from_utf8())

	postcards.clear()
	for i in json:
		postcards.append({
			"from": i.get("from", "unknown"),
			"content": i.get("content", "")
		})

	updates_postcards_ui()


func updates_postcards_ui():
	for i in $VBoxContainer/HBoxContainer/Receive/Receive/ScrollContainer/PostcardBox.get_children():
		i.queue_free()

	for i in postcards:
		var new_postcard = load("res://addons/hackpal/assets/postcard.tscn").instantiate()
		new_postcard.content = i["content"]
		new_postcard.from = i["from"]
		$VBoxContainer/HBoxContainer/Receive/Receive/ScrollContainer/PostcardBox.add_child(new_postcard)


func _on_timer_timeout() -> void:
	fetch_postcards()


func send_postcard(senderID: String, recipientID: String, content: String) -> void:
	var url = "https://kosskwc8gk4ckkcg4csg484c.a.selfhosted.hackclub.com/api/sendPostcards"
	var headers = ["Content-Type: application/json"]
	var body = {
		"senderSlackId": senderID,
		"recipientSlackId": recipientID,
		"content": content
	}
	var json_body = JSON.stringify(body)
	var http_node = HTTPRequest.new()
	get_parent().add_child(http_node)
	http_node.connect("request_completed", Callable(self, "_on_postcard_request_completed").bind(http_node))

	http_node.request(url, headers, HTTPClient.METHOD_POST, json_body)

func _on_postcard_request_completed(result, response_code, headers, body, http_node):
	print("Postcard sent with response code:", response_code)
	http_node.queue_free()
	
func _on_send_pressed() -> void:
	if slack_id.length() == 11 and $VBoxContainer/HBoxContainer/Send/Send/to_edit.text.length() == 11:
		if $VBoxContainer/HBoxContainer/Send/Send/content_edit.text != "":
			send_postcard(slack_id, $VBoxContainer/HBoxContainer/Send/Send/to_edit.text, $VBoxContainer/HBoxContainer/Send/Send/content_edit.text)
			$VBoxContainer/HBoxContainer/Send/Send/content_edit.text = ""
			$VBoxContainer/HBoxContainer/Send/Send/to_edit.text = ""
		else:
			return 
	else:
		return


func _on_texture_button_pressed() -> void:
	fetch_postcards()


func _on_button_pressed() -> void:
	slack_id = $VBoxContainer/original_name/VBoxContainer/HBoxContainer/slackid.text
