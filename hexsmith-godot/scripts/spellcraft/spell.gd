class_name Spell extends Node

var prefix: SpellPrefix
var suffix: SpellSuffix
var spell_name

func _init():
	# Class Constructor:
	# Needs to pass in a _prefix and _suffix as parameters,
	# then assign them and determine the spell name.
	pass #TODO remove after adding functionality here


func determine_spell_name():
	# Most cases, this is just prefix.name + suffix.name with a space in the middle
	# 2 edge cases with Withdraw and Summon Familiar
	pass #TODO remove after adding functionality here

func cast_spell():
	# pretty much just call suffix.cast and pass in prefix mana values as parameters
	pass #TODO remove after adding functionality here
