local Package = script.Parent.Parent
local Lookup = require(Package.Lookup)

local BuildHelper = require(Package.Compilation.BuildHelper)

local Container = require(Package.Container)
local Animation = require(Package.Animation)
local ErrorHandling = require(Package.Errors)

local BuildMethods = {}

BuildMethods.UIContainer = function(Builder : Lookup.BuildHelper,Node)
    local Properties = Node.Properties
    local Origin = CFrame.new(0,0,0)

    if not ErrorHandling.LogAssert(Properties.UI ~= nil, "Compile", `Containers must have a UI property`) then return end
    if not ErrorHandling.LogAssert(Properties.ID ~= nil, "Compile", `Containers must have a ID property`) then return end

    if Properties.Origin then
        local OriginArray = Builder:TraverseNode(Properties.Origin)
        Origin = typeof(OriginArray) ~= "CFrame" and CFrame.new(unpack(OriginArray)) or OriginArray
    end
    local UI = Builder:TraverseNode(Properties.UI)

    local NewContainer = Container(UI, Origin)

    Builder:TraverseTable(Node.Elements,NewContainer)

    return NewContainer, Builder:TraverseNode(Properties.ID)
end

BuildMethods.element = function(Builder : Lookup.BuildHelper,Node,ContainerObj : Lookup.BaseContainer)
    local Properties = Node.Properties

    if not ErrorHandling.LogAssert(Properties.UI ~= nil, "Compile", `Elements must have a UI property`) then return end
    if not ErrorHandling.LogAssert(Properties.ID ~= nil, "Compile", `Elements must have a ID property`) then return end

    Builder:TraverseTable(Properties)

    Properties.Offset = Properties.Offset and CFrame.new(unpack(Properties.Offset)) or nil
    Properties.Face = Properties.Face and Enum.NormalId[Properties.Face] or nil
    Properties.Resolution = Properties.Resolution and Vector2.new(table.unpack(Properties.Resolution)) or nil

    return ContainerObj:Element(Properties), Properties.ID
end

BuildMethods.layout = function(Builder : Lookup.BuildHelper,Node)
    local Properties = Node.Properties

    if not ErrorHandling.LogAssert(Properties.ID ~= nil, "Compile", `Layouts must have a ID property`) then return end

    ErrorHandling.LogAssert(Properties.Callback ~= nil, "Compile", `Callback is missing from layout`)

    local Elements = Builder:TraverseNode(Properties.Elements)
    local Callback = Builder:TraverseNode(Properties.Callback)
    local Props = Builder:TraverseNode(Properties.Props)

    local LayoutTable = Callback(Elements,Props)

    return LayoutTable, Builder:TraverseNode(Properties.ID)
end

BuildMethods.animation = function(Builder : Lookup.BuildHelper,Node)
    local Properties = Node.Properties
    if not ErrorHandling.LogAssert(Properties.ID ~= nil, "Compile", `Animations must have a ID property`) then return end
    
    local _Instance = Builder:TraverseNode(Properties.Instance)
    local Props = Builder:TraverseNode(Properties.Props)
    local AnimationType = Builder:TraverseNode(Properties.Type)

    Props["Type"] = AnimationType

    return Animation.Interface.Animate(_Instance, Props), Builder:TraverseNode(Properties.ID)
end

BuildMethods.Call = function(Builder : Lookup.BuildHelper,Node)
    local Name = Node.Name

    if Name == "ref" then
        local Index = Builder:TraverseNode(Node.Arguments[1])

        ErrorHandling.LogAssert(Builder.Reference[Index], "Compile", `the reference {Index} does not exist`)

        return Builder.Reference[Index] or nil
    elseif Name == "rad" then
        local Degrees = Builder:TraverseNode(Node.Arguments[1])
        return math.rad(Degrees)
    elseif Name == "prop" then
        local Object = Builder:TraverseNode(Node.Arguments[1])
        local Property = Builder:TraverseNode(Node.Arguments[2])

        ErrorHandling.LogAssert(Object, "Compile", `Tried to get the property of a object that does not exist`)
        ErrorHandling.LogAssert(Object[Property], "Compile", `{Property} is not a valid Property of {tostring(Object)}`)

        return Object and Object[Property] or nil
    elseif Name == "vec3" then
        local Array = Builder:TraverseNode(Node.Arguments[1])
        return Vector3.new(table.unpack(Array))
    elseif Name == "vec2" then
        local Array = Builder:TraverseNode(Node.Arguments[1])
        return Vector2.new(table.unpack(Array))
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