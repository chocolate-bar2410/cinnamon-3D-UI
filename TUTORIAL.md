# how to use
for this tutorial we'll be going over world anchored UI though Cinnamon also support Screen anchored UIs

To first display our UI we must create an `Element` for it.
Every Element is Created, Stored and Deleted using a `Container` object.

```luau
local ScreenGui = PlayerGui.ScreenGui

local Container : Cinnamon.UIContainer = Cinnamon.NewContainer(ScreenGui,CFrame.new(0,2,0))
local Element : Cinnamon.Element = Container:Element({
    UI = ScreenGui.Frame,
    Offset = CFrame.new(5,0,5),
    Resolution = Vector2.new(100,100),
})
```
<img width="542" height="327" alt="image" src="https://github.com/user-attachments/assets/68cf3af8-138a-4560-a942-8d058364ba77" />

To destroy an object, simply call `Destroy` and the framework will handle deletion logic for you.

```luau
Cinnamon.Destroy(Element)
Cinnamon.Destroy(Container)
```
you can otherwise use `Container:Clear()` to Cleanup a Container's children

```luau
Container:Clear() -- this will destroy any child object created by this container
```

To enable/disable a Element set `Element.Enabled` to either true/false. 
For debugging purposes you can help visualise it using `Element.Debug`

Containers also have `.Enabled` and `.Debug` properties that work the same way
<img width="435" height="317" alt="image" src="https://github.com/user-attachments/assets/3580c4b5-2df5-4c6b-9ee0-463c26fd0b7f" />


Containers can also be nested inside eachother, this allows you create reusable components

```luau
local ScreenGui = PlayerGui:WaitForChild("ScreenGui")

local function BuildCarousel(Container : Cinnamon.UIContainer,ItemCount : number,Radius : number,Center : CFrame)
	local Carousel = Container:NewContainer(Container.UI,Center)
	for i = 1,ItemCount do
		local NewFrame = Instance.new("Frame",ScreenGui)
		NewFrame.Name = string.char(64 + i)
		NewFrame.Size = UDim2.fromScale(1,1)
		NewFrame.BackgroundColor3 = Color3.new(1,1,1)
		Carousel:Element({
			UI = NewFrame,
			Offset = CFrame.new(0,0,0),
			Resolution = Vector2.new(800,600)
		})
	end

	local Layout = Cinnamon.Layout.Radial(Carousel.Elements,{
		Origin = Center,
		Distance = Radius,
		StartAngle = 0,
		Padding = math.rad(5),
		Axis = Vector3.new(0,1,0)
	})
	Cinnamon.Layout.ApplyLayout(Carousel.Elements,Layout)

	return Carousel
end

local Container = Cinnamon.NewContainer(ScreenGui,CFrame.new(0,5,0))
local Carousel = BuildCarousel(Container,11,10.75,Container.Origin:ToWorldPosition(CFrame.new(0,0,-10)))
Carousel.Debug = true
```
<img width="473" height="317" alt="image" src="https://github.com/user-attachments/assets/7d4a9e7a-5856-4364-8441-a24947327de9" />


more features like Animations, Layouts and Screen Containers are also available for use, but will not be covered by this tutorial
