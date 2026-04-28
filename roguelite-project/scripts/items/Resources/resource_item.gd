extends Resource
#This file is for the resource file that will be displayed in the inventory menu
class_name ResourceItem

#This will be the display name for the resource/item
@export var display_name : String
#This will be the texture that shows in the inventory menu of the resource/item
@export var texture : Texture2D
 #This will make the items that are pick ups seperate from the items that are passive
@export var group : String
