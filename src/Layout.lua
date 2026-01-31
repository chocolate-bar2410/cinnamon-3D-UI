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
		
		if CurrentAngle + 2 * D_angle + Padding > 2 * math.pi then
			warn("overfill: Added too many elements to radial layout")
			return result
		end

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

module.List = function(Elements : {Lookup.Element},Origin,LookDirection,Direction : Vector3,ItemsUntilWrap,Padding)
	local result = {}
	local Start = CFrame.new(Origin.Position,Origin.Position + LookDirection)

	LookDirection = LookDirection.Unit
	Direction = Direction.Unit
	Padding = Padding or 0

	local Up = Direction:Cross(LookDirection).Unit

	local row = 0

	local RowOffset = 0
	local ColumnOffset = 0

	local Tallest = 0

	for i, Element in ipairs(Elements) do
		row += 1
		Tallest = math.max(Tallest,Element.Instance.Size.Y)

		RowOffset += Element.Instance.Size.X / 2
		local Offset = Up * RowOffset + Direction * ColumnOffset

		local WorldPos = Start.Position + Offset
		result[i] = CFrame.new(WorldPos, WorldPos + LookDirection)

		RowOffset += Element.Instance.Size.X / 2 + Padding

		if ItemsUntilWrap > 0 and row > ItemsUntilWrap then
			row = 0
			RowOffset = 0

			ColumnOffset += Tallest + Padding
			Tallest = 0
		end

	end
	
	return result
end

module.Grid = function(Elements : {Lookup.Element}, Origin : CFrame, LookDirection : Vector3, RowSize, ColumnSize, Padding : Vector2)
	local result = {}
	
	if #Elements > RowSize * ColumnSize then 
		warn(`overfill: Tried to more than {RowSize * ColumnSize} Elements to a {RowSize} x {ColumnSize} grid`) 
		return 
	end

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
