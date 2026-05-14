extends Node2D


@onready var explosion = $Explosion


func Explode():
	explosion.play()
