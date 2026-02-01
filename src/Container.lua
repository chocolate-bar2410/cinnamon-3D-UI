
local Package = script.Parent

local Element = require(Package.Element)
local Lookup = require(Package.Lookup)

local DebugRenderer = require(Package.DebugRenderer)

local Schema = {}

Schema.NewElement = function(self : Lookup.UIContainer,UI : GuiObject,Offset : CFrame,Resolution : Vector2,Face : Enum.NormalId)
	-- remove warn if you plan to use this over Container:Element()
	warn("This implementation is for backwards compatabilty and memory optimisations, use Container:Element() for regular use")

	return Element(self,UI,Offset,Resolution,Face)
end	
Schema.Element = function(self : Lookup.UIContainer,Props : {
	UI : GuiObject,
    Offset : CFrame,
    Resolution : Vector2,
    Face : Enum.NormalId})

	return Element(self, Props.UI, Props.Offset, Props.Resolution, Props.Face)
end


local NewContainer = function(ScreenGui :ScreenGui,Origin)
	local Container = {}
	Container.UI = ScreenGui
	Container.Elements = {}
	Container.Children = {}
	Container.Destroyed = false
	Container.Type = "Container"
	Container._Data = {
		Enabled = true,
		Origin = Origin or CFrame.new(0,0,0),
		Debug = false,
	}
	
	local meta = {__index = function(_,key)
		return Schema[key] or Container._Data[key]
	end,
	__newindex = function(Container : Lookup.UIContainer,index,value)
		if Schema[`_Set{index}`] then
            Schema[`_Set{index}`](Container,value)
        end
		
		Container._Data[index] = value
	end
	}
	
	return setmetatable(Container,meta) :: Lookup.UIContainer
end

Schema.NewContainer = function(self : Lookup.UIContainer,ScreenGui : ScreenGui, Origin : CFrame)
	local Container = NewContainer(ScreenGui,self.Origin * Origin)
	
	table.insert(self.Children,Container)
	
	return Container
end

--// visibility

Schema._SetEnabled = function(self : Lookup.UIContainer,Enabled)
	for _,Element in self.Elements do
		Element.Enabled = Enabled
	end

	for _,Container in self.Children do
		Container.Enabled = Enabled
	end
end

Schema._SetDebug = function(self : Lookup.UIContainer,Enabled)
    if Enabled then
        DebugRenderer.DebugContainer(self)
    else
        DebugRenderer.Remove(self)
    end
end

--// memory management

Schema.Clear = function(self : Lookup.UIContainer)
	
	for _,Element in self.Elements do
		Element:Destroy()
	end
	
	for _,Container in self.Children do
		Container:Destroy()
	end
	
	table.clear(self.Elements)
end

Schema.Destroy = function(self : Lookup.UIContainer)
	if self.Destroyed then return end
	self.Destroyed = true
	self:Clear()
	
	setmetatable(self,nil)
end

--// projection

Schema.UDim2ToCFrame = function(self : Lookup.UIContainer,Position : UDim2,ViewPortSize : Vector2,DisplayDistance : number)
	
	local ScaleX,ScaleY = Position.X.Scale,Position.Y.Scale
	local OffsetX,OffsetY = Position.X.Offset,Position.Y.Offset
	
	local TrueScaleX = ScaleX + OffsetX / ViewPortSize.X
	local TrueScaleY = ScaleY + OffsetY / ViewPortSize.Y
	
	local TrueSize = workspace.CurrentCamera.ViewportSize
	local FOV = workspace.CurrentCamera.FieldOfView
	
	local PartSize = Vector3.new(
		(TrueSize.X / TrueSize.Y) * math.tan(math.rad(FOV)/2) * (ViewPortSize.X/ViewPortSize.Y),
		math.tan(math.rad(FOV)/2) * (ViewPortSize.X/ViewPortSize.Y),
		0
	) * DisplayDistance
	
	return self.Origin * CFrame.new(
		(PartSize.X) * (TrueScaleX - 0.5),
		-(PartSize.Y) * (TrueScaleY -0.5 ),
		-DisplayDistance		
	)
end

Schema._SetOrigin = function(self : Lookup.UIContainer,Origin : CFrame)
	for _,Element in self.Elements do
		local ObjectCFrame = self.Origin:ToObjectSpace(Element.Instance.CFrame)
		Element.Instance.CFrame = Origin:ToWorldSpace(ObjectCFrame)
	end
	
	for _,Container in self.Children do
		local ObjectCFrame = self.Origin:ToObjectSpace(Container.Origin)
		Container.Origin = Origin:ToWorldSpace(ObjectCFrame)
	end
end



return NewContainer
