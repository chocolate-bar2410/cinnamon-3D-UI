local module = {}

local Package = script.Parent
local Lookup = require(Package.Lookup)

local Lines = {}
local Outlines = {}

local DrawnContainers = {}
local DrawnElements = {}

module.DebugFolder = nil

local DisabledColor = Color3.new(1,0.5,0.5)
local EnabledColor = Color3.new(0.5,1,0.5)

local NewDebugFolder = function()
    module.DebugFolder = Instance.new("Folder",workspace)
    module.DebugFolder.Name = "__CINNAMON_DEBUG"
end

local GetCFramePropertyValue = function(Target : BasePart | Lookup.Element | Lookup.UIContainer)
	if typeof(Target) == "BasePart" then return Target.CFrame end
	
	if typeof(Target) ~= "table" then return end
	
	if Target.Type == "Container" then
        return Target.Origin
    elseif Target.Type == "Element" then
        return Target.Instance.CFrame
    else
        warn("Tried to get CFrame of invalid instance")
    end 

end

module.DrawOutline = function(Name,Colour,Target : Lookup.Element)
     if not module.DebugFolder then NewDebugFolder() end
    if Outlines[Name] then return end
    
    local Outline = Instance.new("SelectionBox",Target.Instance)
    Outline.Color3 = Colour
    Outline.Name = tostring(Name)
    Outline.Adornee = Target.Instance
    Outline.LineThickness = 0.01

    Outline.SurfaceColor3 = Colour
    Outline.SurfaceTransparency = 0.75

    Outlines[Name] = Target
end

module.DrawLine = function(
    Name,
    LineColour,
    OriginInstance : Instance? | Lookup.UIContainer?,
    GoalInstance : Instance? | Lookup.UIContainer?
)
    if not module.DebugFolder then NewDebugFolder() end
    local Line

    if not Lines[Name] then
        if not OriginInstance then return end
        if not GoalInstance then return end
        if not LineColour then return end

        Line = Instance.new("Part",module.DebugFolder)
        Line.Anchored = true
        Line.CanCollide = false
        Line.Material = Enum.Material.Neon
        Line.Transparency = 0.5

        Line.Name = tostring(Name)
        Lines[Name] = {Line,GoalInstance,OriginInstance,LineColour}
    else
        Line = Lines[Name][1]
    end  

    if not Lines[Name] then return end

    GoalInstance = Lines[Name][2]
    OriginInstance = Lines[Name][3]

    local Origin = GetCFramePropertyValue(OriginInstance)
    local Goal = GetCFramePropertyValue(GoalInstance)

    local Distance = (Origin.Position - Goal.Position).Magnitude

    Line.Size = Vector3.new(0.05,0.05,Distance)
    Line.CFrame = CFrame.new((Origin.Position + Goal.Position) / 2,Goal.Position)
    Line.Color = Lines[Name][4]

    return Line
end

module.DrawElement = function(Element : Lookup.Element)

    local Colour = Element.Enabled and EnabledColor or DisabledColor

    module.DrawLine(Element,Colour,Element.Container,Element)
    module.DrawOutline(Element, Colour, Element)
end

module.DrawContainer = function(Container : Lookup.UIContainer)
    for _,Element in Container.Elements do
        module.DrawElement(Element)
    end

    for _,ChildContainer in Container.Children do
        local Colour = ChildContainer.Enabled and EnabledColor or DisabledColor
        module.DrawLine(ChildContainer, Colour,Container,ChildContainer)
    end    
end

module.Update = function()
    for i,Line in Lines do
        module.DrawLine(i)
    end    

    for _,Container in DrawnContainers do
        module.DrawContainer(Container)
    end    

    for _,Element in DrawnElements do
        module.DrawElement(Element)
    end


end    

module.Remove = function(Name)
    if Lines[Name] then
        Lines[Name][1]:Destroy()
        Lines[Name] = nil
    end

    if Outlines[Name] then
        Outlines[Name]:Destroy()
    end

    if DrawnElements[Name] then
        DrawnElements[Name] = nil
    end

    if DrawnContainers[Name] then
       DrawnContainers[Name] = nil

       if typeof(Name) ~= "table" or Name.Type ~= "Container" then return end

        for _,Element in Name.Elements do
           module.Remove(Element)
        end

        for _,ChildContainer in Name.Children do
            module.Remove(ChildContainer)
        end 
    end
    
end

module.DebugElement = function(Element : Lookup.Element)
    table.insert(DrawnElements,Element)
end  

module.DebugContainer = function(Container : Lookup.UIContainer)
    table.insert(DrawnContainers,Container)

     for _,Element in Container.Elements do
        table.insert(DrawnElements,Element)
    end

    for _,ChildContainer in Container.Children do
        table.insert(DrawnContainers,ChildContainer)
    end 

end

return module


