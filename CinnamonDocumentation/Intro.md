(note: its recommended to view this doc using obsidian)
Cinnamon is a open source 3d UI framework to give developers a versatile and richer UI framework that goes beyond other 3d ui libraries.

The aim of this framework is to give developers more creative control when making user interfaces in 3d, with support for things like animations, layouts, and reusable components.

For more information check out the API
# Main Features

 1. Declarative hierarchy
	Cinnamon introduces Elements, which represents the individual UIs that are being displayed.
	Each Element is stored in a Container.

```lua
-- this creates a container
local Container = Cinnamon.NewContainer(ScreenGui,CFrame.new(0,2,0))
-- this creates a element for a UI frame
local Element = Container:Element({
	UI = ScreenGui.Frame,
	Offset = CFrame.new(5,0,5),
	Resolution = Vector2.new(100,100),
})
```
	
containers can be nested inside other containers, creating a tree like hierarchy.
```lua
-- this acts like a reusable component
local CreateExample = function(Container,Origin)
	local InnerContainer = Container:NewContainer(Container.UI,Origin)
	InnerContainer:Element({
		UI = ScreenGui.TextButton,
		Offset = CFrame.new(0,0,5),
		Resolution = Vector2.new(200,100)
	})
	
	return InnerContainer
end)

local Container = Cinnamon.NewContainer(ScreenGui,CFrame.new(0,2,0))

local Example = CreateExample(Container,CFrame.new(0,5,0))
```

2. Layouts
	Cinnamon grants developers a easy way to layout their components in space, Allowing for quicker workflows and quick testing for ideas.
	```lua
	local Container = Cinnamon.NewContainer(ScreenGui,CFrame.new(0,2,0))
	for _,v in ScreenGui:GetChildren() do
		Container:Element({
			UI = v,
			Resolution = Vector2.new(200,100)
		})
	end
	local Layout = Cinnamon.Layout.Radial(Container.Elements,{
		Origin = CFrame.new(0,5,0),
		Distance = 10,
		StartAngle = 0,
		Padding = math.rad(5),
		Axis = Vector3.new(0,1,0)
	})
	Cinnamon.Layout.ApplyLayout(Container.Elements,Layout)
	
	```
Since layouts are just a Array of CFrames, you can also make your own custom layouts
```lua
local Custom = function(Elements)
	local result = {}
	for i,Element in ipairs(Elements) do
		result[i] = CFrame.new(i,math.random(1,5),0)
	end
	
	return result
end

Cinnamon.Layout.ApplyLayout(Container.Elements,Custom(Container.Elements))
```
3. Animations
Using the many animation options, Cinnamon allows developers to animate elements how ever they want.
Cinnamon allows you to either animate using Tweens, Bezier curves, Springs or Oscillators

```lua
local Tween = Cinnamon.Animation.Tween(Element.Instance,"CFrame",CFrame.new(0,5,0),"Sine","OutIn",1)

Tween.Enabled = true
```
Animations are considered objects as well, That means you only have to declare a Animation once to play it.
This lets you dynamically change how the animation plays
```lua
local Frequency = 1
local Damping = 0.5
local Response = 0.2
local Spring = Cinnamon.Animation.Spring(Element.Instance,"CFrame",CFrame.new(0,5,0),Frequency,Damping,Response,1)

Spring.Enabled = true
task.wait()

Cinnamon.Animation.SetGoal(Spring,CFrame.new(2,0,2))

``` 
We can also animate multiple elements, giving more creative options for our components
```lua
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

	local A = Cinnamon.Layout.Radial(Carousel.Elements,{
		Origin = Center,
		Distance = Radius,
		StartAngle = 0,
		Padding = math.rad(5),
		Axis = Vector3.new(0,1,0)
	})
	
	local B = Cinnamon.Layout.Radial(Carousel.Elements,{
		Origin = Center,
		Distance = Radius,
		StartAngle = 30,
		Padding = math.rad(5),
		Axis = Vector3.new(0,1,0)
	})
	
	local C = Cinnamon.Layout.Radial(Carousel.Elements,{
		Origin = Center,
		Distance = Radius,
		StartAngle = 30,
		Padding = math.rad(5),
		Axis = Vector3.new(0,1,0)
	})
	
	Cinnamon.Layout.ApplyLayout(Carousel.Elements,A)

	return Carousel,{A,B,C}
end

local Container = Cinnamon.NewContainer(ScreenGui,CFrame.new(0,5,0))
local Carousel,KeyframeTable = BuildCarousel(Container,11,10.75,Container.Origin:ToWorldPosition(CFrame.new(0,0,-10)))

local Forwards = Cinnamon.Animation.BatchAnimation("Tween",Carousel.Elements,{
	Property = "CFrame",
	EasingStyle = "Quad",
	EasingDirection = "InOut"
},{
	Goal = KeyframeTable[2]
})

local Backwards = Cinnamon.Animation.BatchAnimation("Tween",Carousel.Elements,{
	Property = "CFrame",
	EasingStyle = "Quad",
	EasingDirection = "InOut"
},{
	Goal = KeyframeTable[3]
})

Forwards:SetEnabled(true)
task.wait(1)
Cinnamon.Layout.ApplyLayout(Carousel.Elements,KeyframeTable[1])
Backwards:SetEnabled(true)

```