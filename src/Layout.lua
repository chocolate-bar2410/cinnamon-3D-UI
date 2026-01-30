local module = {}

local Package = script.Parent
local Lookup = require(Package.Lookup)

module.ApplyLayout = function(Elements : {Lookup.Element},Layout : {CFrame})
	for i,Element in Elements do
		if not Layout[i] then continue end
		Element.Instance.CFrame = Layout[i]
	end
end

module.Radial = function(Elements : {Lookup.Element},Origin : CFrame,Distance: number,StartAngle : number,Padding : number,Axis : Vector3)
	local CurrentAngle = (StartAngle or 0) - Padding
	Padding = Padding or 0
	Axis = Axis or Vector3.yAxis
	local Basis = math.abs(Axis.Y) < 0.9 and Vector3.yAxis or Vector3.xAxis
	
	local result = {}
	
	for i,Element in ipairs(Elements) do
		local HalfWidth = (Element.UI.AbsoluteSize.X / Element.Instance.SurfaceGui.PixelsPerStud) / 2
		local D_angle = math.atan(HalfWidth / Distance)
		
		CurrentAngle += D_angle
		
		local Rotation = CFrame.fromAxisAngle(Axis,CurrentAngle)
		local Offset = Rotation * (Axis:Cross(Basis).Unit * Distance)
		
		local WorldPosition = Origin.Position + Offset
		
		local Tangent = Axis:Cross(Offset).Unit
		local Binormal = Axis
		
		result[i] = CFrame.fromMatrix(WorldPosition,Tangent,Binormal)

		CurrentAngle += D_angle + Padding
		
	end
	
	return result
end

module.List = function(Elements : {Lookup.Element},Origin,Direction : Vector3,Padding)
	
	local result : {CFrame} = {}
	
	for i,Element in ipairs(Elements) do
		local Width = (Element.UI.AbsoluteSize.X / Element.Instance.SurfaceGui.PixelsPerStud)
		result[i] = Origin * Direction * ((i - 1) * (Width + Padding))
		
		result[i] = CFrame.new(result[i].Position,result[i].Position + Direction)
	end
	
	
	return result
end

module.Grid = function(Elements : {Lookup.Element}, Origin : CFrame, LookDirection, RowSize, ColumnSize, Padding : Vector2)
	local result = {}
	local Start = CFrame.new(Origin.Position, LookDirection)

	LookDirection = LookDirection.Unit

	local Reference = math.abs(LookDirection:Dot(Vector3.yAxis)) < 0.99 and Vector3.yAxis or Vector3.xAxis	

	local Right = LookDirection.Unit:Cross(Reference).Unit
	local Up = Right:Cross(LookDirection.Unit).Unit

	for i, Element in ipairs(Elements) do
		local row = math.floor((i - 1) / RowSize)
		local column = (i - 1) % ColumnSize
		
		local offset = Up * (row * (Element.Instance.Size.Y + Padding.Y)) + Right * (column * (Element.Instance.Size.X + Padding.X))

		local WorldPos = Start.Position + offset
		result[i] = CFrame.new(WorldPos, WorldPos + LookDirection)
	end
	
	return result
end


module.PlaceFromUDim2 = function(Elements : {Lookup.Element},DisplayDistance)
	local result = {}
	
	for i,Element in ipairs(Elements) do
		local Container : Lookup.UIContainer = Element.Container
		local AbsoluteSize = Element.UI.AbsoluteSize
		
		local Value = Container:UDim2ToCFrame(Element.UI.Position,AbsoluteSize,DisplayDistance)
		result[i] = Value
	end
	
	return result
end

return module
