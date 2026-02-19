local Package = script.Parent.Parent
local Lookup = require(Package.Lookup)

local BuildHelper = require(Package.Compilation.BuildHelper)

local Container = require(Package.Container)
local ErrorHandling = require(Package.Errors)

local BuildMethods = {}

BuildMethods.UIContainer = function(Builder : Lookup.BuildHelper,Node)
    local Properties = Node.Properties
    local Origin = CFrame.new(0,0,0)

    if not Properties.UI then
        ErrorHandling.LogError("Compile", `Containers must have a UI property`)
        return
    end

    if not Properties.ID then
        ErrorHandling.LogError("Compile", `Containers must have a ID property`)
        return
    end

    if Properties.Origin then
        local OriginArray = Builder:TraverseNode(Properties.Origin)
        Origin = CFrame.new(unpack(OriginArray))
    end
    local UI = Builder:TraverseNode(Properties.UI)

    local NewContainer = Container(UI, Origin)

    for _,v in Node.Elements do
        Builder:TraverseNode(v,NewContainer)
    end

    return NewContainer, Builder:TraverseNode(Properties.ID)
end

BuildMethods.element = function(Builder : Lookup.BuildHelper,Node,ContainerObj : Lookup.BaseContainer)
    local Properties = Node.Properties
    if not Properties.UI then
        ErrorHandling.LogError("Compile", `Elements must have a UI property`)
        return
    end

    if not Properties.ID then
        ErrorHandling.LogError("Compile", `Elements must have a ID property`)
        return
    end

    for i,PropertyNode in Properties do
        Properties[i] = Builder:TraverseNode(PropertyNode)
    end
    Properties.Offset = Properties.Offset and CFrame.new(unpack(Properties.Offset)) or nil

    Properties.Face = Properties.Face and Enum.NormalId[Properties.Face] or nil

    Properties.Resolution = Properties.Resolution and Vector2.new(table.unpack(Properties.Resolution)) or nil

    print(Properties)

    return ContainerObj:Element(Properties), Properties.ID
end

BuildMethods.Call = function(Builder : Lookup.BuildHelper,Node)
    local Name = Node.Name

    if Name == "ref" then
        local Index = Builder:TraverseNode(Node.Arguments[1])
        return Builder.Reference[Index]
    end

    return
end

BuildMethods.Value = function(Builder : Lookup.BuildHelper,Node)
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