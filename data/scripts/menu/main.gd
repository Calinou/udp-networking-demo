extends Control

onready var address

func _on_JoinServer_pressed():
	Client.start()

func _on_HostServer_pressed():
	Server.start()

func _on_ServerAddress_text_changed(text):
	address = text
