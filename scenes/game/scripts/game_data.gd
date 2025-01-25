## Game data is resource used by the Game scene for loading the given track
## The idea is to share this resource between menu and the game scene for setting the wanted track
## It can also be used for having separated Game scene for testing and allows skipping the menu
class_name GameData extends Resource

## Current track selected for GameData
@export var track : Track
