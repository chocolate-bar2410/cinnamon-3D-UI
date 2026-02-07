Members:

[Animation](API/Interfaces/Animation.md) - Methods for creating and handling animation
[Layout](API/Interfaces/Layout.md) - Handles layouts and provides template layouts

Methods:

GetUI_3D -> UIContainer
```lua
function Cinnamon.GetUI_3D(ScreenGui) : UIContainer
```
- Clears out and destroys child objects without destroying the container

NewContainer -> UIContainer
```lua
function Cinnamon.NewContainer(
	ScreenGui,
	Origin : CFrame
) : UIContainer
```
- Creates a new UI container

NewScreenContainer -> ScreenContainer
```lua
function Cinnamon.NewScreenContainer(
	ScreenGui,
	DisplayDistance : number
) : ScreenContainer
```
- Creates a new ScreenContainer

Destroy -> nil
```lua
function Cinnamon.Destroy(
	UI3D_Object : {Destroy : (T) -> nil},
) : nil
```
- Deletes anything with a internal destroy method