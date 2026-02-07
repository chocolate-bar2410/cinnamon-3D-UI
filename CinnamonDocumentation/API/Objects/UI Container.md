Holds [Elements](API/Objects/Element.md) and positions them in world position.

Properties:

Enabled : Boolean
- Enables/Disables child objects
Debug : Boolean
- Adds/Removes itself and its child objects from the debug visualiser
Origin : CFrame
- The point where its child objects are placed relative to

Members: 

Elements : {Element}
- The Elements being stored
Children : {UIContainer} 
- The containers nested inside this container
UI : ScreenGui
- The UI that stores your Elements
  
Methods:

NewContainer -> Container
```lua
function Container:NewContainer(
	UI : ScreenGui,
	Origin : CFrame
) : UIContainer
```
- creates a new child container

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
