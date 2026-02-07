Holds [Elements](API/Objects/Element.md) and positions them on the screen.

Properties:

Enabled : Boolean
- Enables/Disables child objects
Debug : Boolean
- Adds/Removes itself and its child objects from the debug visualiser
DisplayDistance : number
- How far the elements are from the screen

Members: 

Elements : {Element}
- The Elements being stored
UI : ScreenGui
- The UI that stores your Elements
  
Methods:

Element -> Element
```lua
function Container:Element(Props : {
    UI : GuiObject,
    Offset : CFrame,
    Resolution : Vector2,
    Face : Enum.NormalId
    }
) : Element
```
- creates a new element

Clear -> nil
```lua
function Container:Clear() : nil
```
- Clears out and destroys child objects without destroying the container

UDim2ToCFrame -> CFrame
```lua
function Container:UDim2ToCFrame(
	Position : UDim2,
	ViewPortSize : Vector2,
	DisplayDistance : number
) : CFrame
```
- Projects UDim2 to a position relative to the origin
Partsize -> Vector3
```lua
function Container:UDim2ToCFrame(
	Position : UDim2,
	ViewPortSize : Vector2,
) : CFrame
```
- Calculate how large a element should be using position and viewport size
