local schema = {}

local Package = script.Parent
local Lookup = require(Package.Lookup)

local DebugRenderer = require(Package.DebugRenderer)

local PixelsPerStud = 150

schema._SetEnabled = function(self : Lookup.Element,Enabled : boolean)
	self.Instance.SurfaceGui.Enabled = Enabled
	if Enabled then
		self.UI.Parent = self.Instance.SurfaceGui
	else
		self.UI.Parent = self.Parent2D
	end
end

schema._SetDebug = function(self : Lookup.Element,Enabled : boolean)
    if Enabled then
		DebugRenderer.DebugElement(self)
	else
		DebugRenderer.Remove(self)
	end
end

schema._SetResolution = function(self : Lookup.Element,Resolution : Vector2)
	self.Instance.Size = Vector3.new(
		((Resolution.X * self.UI.Size.X.Scale) + self.UI.Size.X.Offset) / PixelsPerStud,
		((Resolution.Y * self.UI.Size.Y.Scale) + self.UI.Size.Y.Offset) / PixelsPerStud,
		1
	)
end

schema._SetOffset = function(self : Lookup.Element,Offset : CFrame)
	if self.Container.Type == "Container" then
		self.Instance.CFrame = self.Container.Origin * Offset
	elseif self.Container.Type == "ScreenContainer" then
		self.Instance.CFrame = self.Container.WorldCFrame * Offset
	end
end

schema.Destroy = function(self : Lookup.Element)
	if self.Destroyed then return end
	self.Destroyed = true
	self.UI.Parent = self.Parent2D
	self.Instance:Destroy()
	
	for _,v in self.Connections do
		v:Disconnect()
	end
	
	
	local index = table.find(self.Container.Elements,self)
	table.remove(self.Container.Elements,index)

	setmetatable(self,nil)
end

local Init = function(self : Lookup.Element,Face : Enum.NormalId)
	self.Instance.CanCollide = false
	self.Instance.CanTouch = false
	self.Instance.CanQuery = false
	self.Instance.Anchored = true
	self.Instance.CastShadow = false
	self.Instance.Transparency = 1
	
	self.Instance.SurfaceGui.Adornee = self.Instance
	self.Instance.SurfaceGui.AlwaysOnTop = true
	self.Instance.SurfaceGui.Face = Face
	self.Instance.SurfaceGui.LightInfluence = 0
	
	self.Instance.SurfaceGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	self.Instance.SurfaceGui.PixelsPerStud = PixelsPerStud
	
	self.Instance.SurfaceGui.Active = true
	
	--[[local PreviousAbsoluteSize = self.UI.AbsoluteSize
	
	local throttle = os.clock()
	
	table.insert(self.Connections,{self.UI:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		local RatioX = self.UI.AbsoluteSize.X / PreviousAbsoluteSize.X
		local RatioY = self.UI.AbsoluteSize.Y / PreviousAbsoluteSize.Y
		
		self.Instance.Size = Vector3.new(
			self.Instance.Size.X * RatioX,
			self.Instance.Size.Y * RatioY,
			1
		)
		PreviousAbsoluteSize = self.UI.AbsoluteSize
		
	end)})]]
end

return function(Container : Lookup.UIContainer | Lookup.ScreenContainer,UI : GuiObject,Offset : CFrame,Resolution : Vector2,Face : Enum.NormalId)
	Face = Face or Enum.NormalId.Back
	Offset = Offset or CFrame.new(0,0,0)
	local Element = {}
	Element.Parent2D = UI.Parent
	Element.UI = UI
	Element.Connections = {}
	Element.Type = "Element"
	Element._RevertToEnabled = true

	Element._Data = {	
		Enabled = true,
		Debug = false,
		Resolution = Resolution,
		Offset = Offset
	}
	
	local Display = Instance.new("Part",Container.UI)
	local SurfaceGUI = Instance.new("SurfaceGui",Display)
	
	Display.Name = UI.Name
	Display.Size = Vector3.new(
		((Resolution.X * UI.Size.X.Scale) + UI.Size.X.Offset) / PixelsPerStud,
		((Resolution.Y * UI.Size.Y.Scale) + UI.Size.Y.Offset) / PixelsPerStud,
		1
	)

	Element.UI.Parent = SurfaceGUI

	if Container.Type == "Container" then
		Display.CFrame = Container.Origin * Offset
	elseif Container.Type == "ScreenContainer" then
		Display.CFrame = Container.WorldCFrame * Offset
	end

	Element.Instance = Display
	Element.Container = Container
	Element.Destroyed = false

	Init(Element,Face)
	
	local meta = {__index = function(_,key)
		return schema[key] or Element._Data[key]
	end,
	__newindex = function(Element : Lookup.Element,index,value)
		if schema[`_Set{index}`] then
            schema[`_Set{index}`](Element,value)
        end

		if index == "Enabled" then
			Element._RevertToEnabled = value
		end
		
		Element._Data[index] = value
	end
	}
	
	table.insert(Container.Elements,Element)
	return setmetatable(Element,meta) :: Lookup.Element
end
