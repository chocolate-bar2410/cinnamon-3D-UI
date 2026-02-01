
local Package = script.Parent

local Element = require(Package.Element)
local Lookup = require(Package.Lookup)

local DebugRenderer = require(Package.DebugRenderer)

local ScreenContainers : {Lookup.ScreenContainer} = {}
local Schema = {}

local Update = function()
	for _,Container in ScreenContainers do
		local Original = Container.WorldCFrame
		Container.WorldCFrame = workspace.CurrentCamera.CFrame:toWorldSpace(CFrame.new(0,0,-Container.DisplayDistance))

		for _,Element in Container.Elements do
			local AbsoluteSize = Element.UI.AbsoluteSize
			local ObjectCFrame = Original:ToObjectSpace(Element.Instance.CFrame)

			local Rotation = ObjectCFrame - ObjectCFrame.Position
			Element.Instance.CFrame = Container:UDim2ToCFrame(Element.UI.Position, AbsoluteSize) * Rotation

			Element.Instance.Size = Container:GetPartSize(AbsoluteSize)
		end

	end
end	

local NewContainer = function(ScreenGui :ScreenGui,DisplayDistance : number)
	local Container = {}
	Container.UI = ScreenGui
	Container.Elements = {}
	Container.Destroyed = false
	Container.Type = "ScreenContainer"
	Container.WorldCFrame = workspace.CurrentCamera.CFrame:toWorldSpace(CFrame.new(0,0,-DisplayDistance))
	Container._Data = {
		Enabled = true,
		Debug = false,
        DisplayDistance = DisplayDistance,
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
	
	Container = setmetatable(Container,meta) 

	table.insert(ScreenContainers,Container)

	return Container :: Lookup.ScreenContainer
end

Schema.NewElement = function(self : Lookup.ScreenContainer,UI : GuiObject,Offset : CFrame,Resolution : Vector2,Face : Enum.NormalId)
	-- remove warn if you plan to use this over Container:Element()
	warn("This implementation is for backwards compatabilty and memory optimisations, use Container:Element() for regular use")

	return Element(self,UI,Offset,Resolution,Face)
end	
Schema.Element = function(self : Lookup.ScreenContainer,Props : {
	UI : GuiObject,
    Offset : CFrame,
    Resolution : Vector2,
    Face : Enum.NormalId})

	return Element(self, Props.UI, Props.Offset, Props.Resolution, Props.Face)
end

--// visibility

Schema._SetEnabled = function(self : Lookup.ScreenContainer,Enabled)
	for _,Element in self.Elements do
		Element.Enabled = Enabled
	end
end

Schema._SetDebug = function(self : Lookup.ScreenContainer,Enabled)
    if Enabled then
        DebugRenderer.DebugScreenContainer(self)
    else
        DebugRenderer.Remove(self)
    end
end

--// memory management

Schema.Clear = function(self : Lookup.ScreenContainer)
	
	for _,Element in self.Elements do
		Element:Destroy()
	end

	table.clear(self.Elements)
end

Schema.Destroy = function(self : Lookup.ScreenContainer)
	if self.Destroyed then return end
	self.Destroyed = true
	self:Clear()
	
	setmetatable(self,nil)
end

--// projection
Schema.GetPartSize = function(self : Lookup.ScreenContainer,ViewPortSize : Vector2)
	local TrueSize = workspace.CurrentCamera.ViewportSize
	local FOV = workspace.CurrentCamera.FieldOfView
	
	local AspectRato = TrueSize.X / TrueSize.Y

	local y = math.tan(math.rad(FOV)/2) * self.DisplayDistance
	local x = y * AspectRato

	local PartSize = Vector3.new(x,y,0)

	--[[local PartSize = Vector3.new(
		(TrueSize.X / TrueSize.Y) * math.tan(math.rad(FOV)/2) * (ViewPortSize.X/ViewPortSize.Y),
		math.tan(math.rad(FOV)/2) * (ViewPortSize.X/ViewPortSize.Y),
		0
	) * self.DisplayDistance]]

	return PartSize
end

Schema.UDim2ToCFrame = function(self : Lookup.ScreenContainer,Position : UDim2,ViewPortSize : Vector2)
	
	local ScaleX,ScaleY = Position.X.Scale,Position.Y.Scale
	local OffsetX,OffsetY = Position.X.Offset,Position.Y.Offset
	
	local TrueScaleX = ScaleX + OffsetX / ViewPortSize.X
	local TrueScaleY = ScaleY + OffsetY / ViewPortSize.Y
	
	local PartSize = self:GetPartSize(ViewPortSize)
	
	return self.WorldCFrame * CFrame.new(
		(PartSize.X) * (TrueScaleX - 0.5),
		-(PartSize.Y) * (TrueScaleY -0.5 ),
		0		
	)
end

return {NewContainer,Update}
