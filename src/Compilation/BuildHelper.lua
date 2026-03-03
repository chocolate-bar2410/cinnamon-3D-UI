local Package = script.Parent.Parent
local Lookup = require(Package.Lookup)

local ErrorHandling = require(Package.Errors)

local Schema = {}

local meta = {__index = Schema}

Schema.TraverseNode = function(self : Lookup.BuildHelper,Node,Argument)
    if not self.BuildMethods[Node.NodeType] then return end

    local result,ID = self.BuildMethods[Node.NodeType](self,Node,Argument)

    if not ID then return result end
    self.Built[ID] = result 

    return result
end

Schema.TraverseTable = function(self : Lookup.BuildHelper,NodeTable : {Lookup.CompileNode},Argument)
    for i,v in NodeTable do
        NodeTable[i] = self:TraverseNode(v,Argument)
    end

    return NodeTable
end

Schema.TraverseBody = function(self : Lookup.BuildHelper)
    for _,Node in self.AST.Body do
        self:TraverseNode(Node)
    end

end

return function(AST,Reference,BuildMethods)
    local Builder = {}
    Builder.AST = AST
    Builder.Reference = Reference
    Builder.BuildMethods = BuildMethods
    Builder.Built = {}

    return setmetatable(Builder, meta)
end