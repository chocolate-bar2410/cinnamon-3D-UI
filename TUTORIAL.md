# how to use
first create a `Container` object, and use that to create `Element` objects which hold your UI

```luau
local Container : Cinnamon.UIContainer = Cinnamon.NewContainer(ScreenGui,CFrameValue)
local Element : Cinnamon.Element = Container:NewElement(GuiObject,CFrame,Resolution,Face)
```
Your Elements will be positioned relative to its container, so you dont have to worry about its exact position.

To destroy an object, simply call `Destroy` and the framework will handle deletion logic for you.

```luau
Cinnamon.Destroy(Element)
```

you can otherwise use `Container:Clear()` to Cleanup a Container's children

```luau
Container:Clear() -- this will destroy any child object created by this container
```
Containers can also be nested inside eachother, this allows you create reusable components

```luau
local function BuildCarousel(Container : Cinnamon.UIContainer,ItemCount : number,Radius : number,Center : CFrame)
    local Carousel = Container:NewContainer(Container.UI,Center)
    for i = 1,ItemCount do
        local NewFrame = Instance.new("Frame",ScreenGui)
        NewFrame.Name = string.char(64 + i)
        NewFrame.Size = UDim2.fromScale(1,1)
        NewFrame.BackgroundColor3 = Color3.new(1,1,1)
        Carousel:NewElement(NewFrame,CFrame.new(0,0,0),Vector2.new(800,600))
    end
    
    local Layout = Cinnamon.Layout.Radial(Carousel.Elements,Center,Radius,0,math.rad(5),Vector3.new(0,1,0))
    Cinnamon.Layout.ApplyLayout(InnerContainer.Elements,Layout)

    return Carousel
end

local Carousel = BuildCarousel(Container,9,10.75,Container.Origin:ToWorldPosition(CFrame.new(0,0,-10)))
```

more features like animations and layouts are also available for use, but will not be covered by this tutorial
