local Package = script.Parent.Parent
local ParseHelper = require(script.Parent.ParseHelper)
local Lookup = require(Package.Lookup)

local BuildHelper = require(Package.Compilation.BuildHelper)

local Container = require(Package.Container)
local ScreenContainer = require(Package.ScreenContainer)[1]
local Animation = require(Package.Animation)
local ErrorHandling = require(Package.Errors)

local BuildMethods = {}

--// Cinnamon object construction

BuildMethods.UIContainer = function(Builder : Lookup.BuildHelper,Node)
    local Properties = Node.Properties

    ErrorHandling.LogAssert(Properties.UI ~= nil, "Compile", `Containers must have a UI property`,Node.Line)
    ErrorHandling.LogAssert(Properties.ID ~= nil, "Compile", `Containers must have a ID property`,Node.Line)

    Builder:TraverseTable(Properties)

    if Properties.Origin and typeof(Properties.Origin) ~= "CFrame"  then
        ErrorHandling.LogError("Compile", `Container origin must be a CFrame`,Node.Line) 
        return
    end

    local NewContainer

    if Properties.Parent then
        ErrorHandling.LogAssert(Properties.Parent.Type, "Compile", `Parent must be a cinnamon object`,Node.Line) 
        ErrorHandling.LogAssert(Properties.Parent.Type == "Container", "Compile", `Parent must be a Container`,Node.Line)  

        NewContainer = Properties.Parent:NewContainer(Properties.UI, Properties.Origin)
    else
        NewContainer = Container(Properties.UI, Properties.Origin)
    end

    Builder:TraverseTable(Node.Elements,NewContainer)

    return NewContainer, Properties.ID
end

BuildMethods.element = function(Builder : Lookup.BuildHelper,Node,ContainerObj : Lookup.BaseContainer)
    local Properties = Node.Properties

    ErrorHandling.LogAssert(Properties.UI ~= nil, "Compile", `Elements must have a UI property`,Node.Line)
    ErrorHandling.LogAssert(Properties.ID ~= nil, "Compile", `Elements must have a ID property`,Node.Line)

    Builder:TraverseTable(Properties)

    if Properties.Offset and typeof(Properties.Offset) ~= "CFrame" then
        ErrorHandling.LogError("Compile", "Element offset must be CFrame",Node.Line)
    end

    if Properties.Resolution and typeof(Properties.Resolution) ~= "Vector2" then
        ErrorHandling.LogError("Compile", "Element offset must be Vector2",Node.Line)
    end

    Properties.Face = Properties.Face and Enum.NormalId[Properties.Face] or nil

    return ContainerObj:Element(Properties), Properties.ID
end

BuildMethods.layout = function(Builder : Lookup.BuildHelper,Node)
    local Properties = Node.Properties

    ErrorHandling.LogAssert(Properties.ID ~= nil, "Compile", `Layouts must have a ID property`,Node.Line)

    ErrorHandling.LogAssert(Properties.Callback ~= nil, "Compile", `Callback is missing from layout`)

    local Elements = Builder:TraverseNode(Properties.Elements)
    local Callback = Builder:TraverseNode(Properties.Callback)
    local Props = Builder:TraverseNode(Properties.Props)

    local LayoutTable = Callback(Elements,Props)

    return LayoutTable, Builder:TraverseNode(Properties.ID)
end

BuildMethods.animation = function(Builder : Lookup.BuildHelper,Node)
    local Properties = Node.Properties
    ErrorHandling.LogAssert(Properties.ID ~= nil, "Compile", `Animations must have a ID property`,Node.Line)
    
    local _Instance = Builder:TraverseNode(Properties.Instance)
    local Props = Builder:TraverseNode(Properties.Props)
    local AnimationType = Builder:TraverseNode(Properties.Type)

    Props["Type"] = AnimationType

    return Animation.Interface.Animate(_Instance, Props), Builder:TraverseNode(Properties.ID)
end

BuildMethods.batchanimation = function(Builder : Lookup.BuildHelper,Node)
    local Properties = Node.Properties
    ErrorHandling.LogAssert(Properties.ID ~= nil, "Compile", `Animations must have a ID property`,Node.Line)
    
    local _Instances = Builder:TraverseNode(Properties.Instances)
    local Props = Builder:TraverseNode(Properties.Props)
    local GroupData = Builder:TraverseNode(Properties.GroupData)
    local AnimationType = Builder:TraverseNode(Properties.Type)

    return Animation.Interface.BatchAnimation(AnimationType, _Instances, Props, GroupData), Builder:TraverseNode(Properties.ID)
end

BuildMethods.screencontainer = function(Builder : Lookup.BuildHelper,Node)
    local Properties = Node.Properties

    ErrorHandling.LogAssert(Properties.UI ~= nil, "Compile", `Containers must have a UI property`,Node.Line)
    ErrorHandling.LogAssert(Properties.ID ~= nil, "Compile", `Containers must have a ID property`,Node.Line)

    Builder:TraverseTable(Properties)

    local NewContainer = ScreenContainer(Properties.UI, Properties.DisplayDistance)

    Builder:TraverseTable(Node.Elements,NewContainer)

    return NewContainer, Properties.ID
end

BuildMethods.timeline = function(Builder : Lookup.BuildHelper,Node)
    local Properties = Node.Properties

    ErrorHandling.LogAssert(Properties.ID ~= nil, "Compile", `Timelines must have a ID property`,Node.Line)
    ErrorHandling.LogAssert(Properties.Animation ~= nil, "Compile", `Timeline must have a Animation to attach to`,Node.Line)
    ErrorHandling.LogAssert(Node.TimelineEntries ~= nil, "Compile", `Timeline has no entries`,Node.Line)
    
    Builder:TraverseTable(Properties)

    local Timeline = {}
    for _,v in ipairs(Node.TimelineEntries) do
        local Duration = Builder:TraverseNode(v.Time)
        local Data = Builder:TraverseNode(v.Data)

        ErrorHandling.LogAssert(typeof(Data) == "table", "Compile", `Timeline entry must be a table`,Node.Line)
    
        Data.Time = Duration
        table.insert(Timeline,Data)
    end

    return Animation.Interface.AttachTimeline(Properties.Animation,Timeline), Properties.ID
end

--// Value Primatives

BuildMethods.Call = function(Builder : Lookup.BuildHelper,Node)
    local Name = Node.Name

    if Name == "ref" then
        local Index = Builder:TraverseNode(Node.Arguments[1])

        ErrorHandling.LogAssert(Builder.Reference[Index], "Compile", `the reference {Index} does not exist`,Node.Line)

        return Builder.Reference[Index] or nil
    elseif Name == "rad" then
        local Degrees = Builder:TraverseNode(Node.Arguments[1])
        return math.rad(Degrees)
    elseif Name == "prop" then
        local Object = Builder:TraverseNode(Node.Arguments[1])
        local Property = Builder:TraverseNode(Node.Arguments[2])

        ErrorHandling.LogAssert(Object, "Compile", `Tried to get the property of a object that does not exist`,Node.Line)
        ErrorHandling.LogAssert(Object[Property], "Compile", `{Property} is not a valid Property of {tostring(Object)}`,Node.Line)

        return Object and Object[Property] or nil
    elseif Name == "vec3" then
        local Array = Builder:TraverseNode(Node.Arguments[1])
        local NewVector = Vector3.new(table.unpack(Array))

        ErrorHandling.LogAssert(NewVector ~= nil, "Compile", "Vector3 has invalid arguments",Node.Line)
        return NewVector
    elseif Name == "vec2" then
        local Array = Builder:TraverseNode(Node.Arguments[1])
        local NewVector = Vector2.new(table.unpack(Array))

        ErrorHandling.LogAssert(NewVector ~= nil, "Compile", "Vector2 has invalid arguments",Node.Line)

        return NewVector
    elseif Name == "cframe" then
        local Array = Builder:TraverseNode(Node.Arguments[1])
        local NewCFrame = CFrame.new(table.unpack(Array))

        ErrorHandling.LogAssert(NewCFrame ~= nil, "Compile", "CFrame has invalid arguments",Node.Line)

        return CFrame
    end

    return
end

BuildMethods.Value = function(Builder : Lookup.BuildHelper,Node)
    if Builder.Built[Node.Value] then
        return Builder.Built[Node.Value]
    end

    return tonumber(Node.Value) or Node.Value
end

BuildMethods.Array = function(Builder : Lookup.BuildHelper,Node)
    local Result = {}

    for i,item in Node.Items do
        table.insert(Result,Builder:TraverseNode(item))
    end

    return Result
end

BuildMethods.Map = function(Builder : Lookup.BuildHelper,Node)
    local Result = {}

    for i,item in Node.Items do
        Result[i] = Builder:TraverseNode(item)
    end

    return Result
end

return function(AST : {Body : {Lookup.CompileNode},Header : Lookup.CompileNode},Reference)
    local Builder = BuildHelper(AST, Reference, BuildMethods)
    Builder:TraverseBody()

    return Builder.Built
end