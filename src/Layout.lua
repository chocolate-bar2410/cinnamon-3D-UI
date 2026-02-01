local module = {}

local Package = script.Parent
local Lookup = require(Package.Lookup)



module.ApplyLayout = function(Elements : {Lookup.Element},Layout : {CFrame})
	for i,Element in Elements do
		if not Layout[i] then continue end
		Element.Instance.CFrame = Layout[i]
	end
end

module.Radial = function(Elements : {Lookup.Element},Props : {
	Origin : CFrame,
	Distance: number,
	StartAngle : number,
	Padding : number,
	Axis : Vector3
	})
	local CurrentAngle = (Props.StartAngle or 0) - Props.Padding
	local Padding = Props.Padding or 0
	local Axis = Props.Axis or Vector3.yAxis
	local Basis = math.abs(Axis.Y) < 0.9 and Vector3.yAxis or Vector3.xAxis
	
	local result = {}
	
	for i,Element in ipairs(Elements) do
		local HalfWidth = (Element.UI.AbsoluteSize.X / Element.Instance.SurfaceGui.PixelsPerStud) / 2
		local D_angle = math.atan(HalfWidth / Props.Distance)
		
		if CurrentAngle + 2 * D_angle + Padding > 2 * math.pi then
			warn("overfill: Added too many elements to radial layout")
			return result
		end

		CurrentAngle += D_angle
		
		local Rotation = CFrame.fromAxisAngle(Axis,CurrentAngle)
		local Offset = Rotation * (Axis:Cross(Basis).Unit * Props.Distance)
		
		local WorldPosition = Props.Origin.Position + Offset
		
		local Tangent = Axis:Cross(Offset).Unit
		local Binormal = Axis
		
		result[i] = CFrame.fromMatrix(WorldPosition,Tangent,Binormal)

		CurrentAngle += D_angle + Padding
		
	end
	
	return result
end

module.List = function(Elements : {Lookup.Element},Props : {
	Origin : CFrame,
	FillDirection : Vector3,
	UpDirection : Vector3,
	ItemsUntilWrap : number,
	Padding : number,
	})
	local result = {}
	local FillDirection = Props.FillDirection.Unit
	local UpDirection = Props.UpDirection.Unit
	local Padding = Props.Padding or 0

	if math.abs(UpDirection:Dot(FillDirection)) > 0.99 then
		warn("Fill direction and Up direction are on the same axis")
		return result
	end

	local Start = CFrame.lookAt(Props.Origin.Position, Props.Origin.Position + FillDirection,-UpDirection)

	local Right = Start.RightVector
	local Down = -Start.UpVector

	local row = 0

	local RowOffset = 0
	local ColumnOffset = 0

	local Tallest = 0

	for i, Element in ipairs(Elements) do
		row += 1
		Tallest = math.max(Tallest,Element.Instance.Size.Y)

		RowOffset += Element.Instance.Size.X / 2
		local Offset = Right * RowOffset + Down * ColumnOffset

		result[i] = Start + Offset

		RowOffset += Element.Instance.Size.X / 2 + Padding

		if Props.ItemsUntilWrap > 0 and row > Props.ItemsUntilWrap then
			row = 0
			RowOffset = 0

			ColumnOffset += Tallest + Padding
			Tallest = 0
		end

	end
	
	return result
end

module.Grid = function(Elements : {Lookup.Element}, Props : {
	Origin : CFrame, 
	LookDirection : Vector3, 
	RowSize : number,
	ColumnSize : number, 
	Padding : Vector2})
	local result = {}
	
	local Padding = Props.Padding or Vector2.zero

	if #Elements > Props.RowSize * Props.ColumnSize then 
		warn(`overfill: Tried to more than {Props.RowSize * Props.ColumnSize} Elements to a {Props.RowSize} x {Props.ColumnSize} grid`) 
		return 
	end

	local Start = CFrame.new(Props.Origin.Position, Props.LookDirection)
	local LookDirection = Props.LookDirection.Unit

	local Reference = math.abs(LookDirection:Dot(Vector3.yAxis)) < 0.99 and Vector3.yAxis or Vector3.xAxis	

	local Right = LookDirection.Unit:Cross(Reference).Unit
	local Up = Right:Cross(LookDirection.Unit).Unit

	for i, Element in ipairs(Elements) do
		local row = math.floor((i - 1) / Props.RowSize)
		local column = (i - 1) % Props.ColumnSize
		
		local offset = Up * (row * (Element.Instance.Size.Y + Padding.Y)) + Right * (column * (Element.Instance.Size.X + Padding.X))

		local WorldPos = Start.Position + offset
		result[i] = CFrame.new(WorldPos, WorldPos + LookDirection)
	end
	
	return result
end

local CubicBezier_CFrame = function(Origin : CFrame,P1 : CFrame,P2 : CFrame,Goal : CFrame,t)
	local A = Origin:Lerp(P1,t)
	local B = P1:Lerp(P2,t)
	local C = P2:Lerp(Goal,t)

	local D = A:Lerp(B,t)
	local E = B:Lerp(C,t)

	return D:Lerp(E,t)
end

local QuadraticBezier = function(Origin : Vector3,P1 : Vector3,Goal : Vector3,t)
	local Position = (1 - t) ^2 * Origin + 2 * (1 - t) * t * P1 + t^2 * Goal
	local tangent = 2 * (1 - t) * (P1 - Origin) + 2 * t * (Goal - P1)

	return Position,tangent.Unit
end

local QuadraticBezierArcLength = function(Origin, P1, Goal, t)
    local A = 2 * (Goal - 2*P1 + Origin)
    local B = 2 * (P1 - Origin)
    
    local a = A:Dot(A)
    local b = A:Dot(B)
    local c = B:Dot(B)
    
    if a == 0 then
        return math.sqrt(c) * t
    end

    local sqrtQuadratic = function(u)
        return math.sqrt(a*(u^2) + 2*b*u + c)
    end

    local length = ((b + a*t) * sqrtQuadratic(t) - b * sqrtQuadratic(0)) / a
	length = length + ((c*a - b*b)/(a^(3/2))) * math.log( (math.sqrt(a) * sqrtQuadratic(t) + a*t + b) / (math.sqrt(a) * sqrtQuadratic(0) + b) )

    return length
end

module.QuadBezier = function(Elements : {Lookup.Element}, Props : {
	Origin : CFrame,
	P1 : CFrame,
	Goal : CFrame, 
	Padding : number
})
	local Padding = Props.Padding or 0
	local result = {}
	local TotalLength = QuadraticBezierArcLength(Props.Origin.Position, Props.P1.Position, Props.Goal.Position, 1)

	local CurrentTimePosition = 0
	local D_length = 0

	for i,Element in Elements do
		CurrentTimePosition += D_length
		D_length = (Element.Instance.Size.X * 2 + Padding) / TotalLength
		
		local Position,Tangent = QuadraticBezier(Props.Origin.Position, Props.P1.Position, Props.Goal.Position, CurrentTimePosition)
		local WorldUp = Vector3.yAxis

		if math.abs(Tangent:Dot(WorldUp)) > 0.99 then
			WorldUp = Vector3.xAxis
		end

		local right = Tangent:Cross(WorldUp).Unit
		local up = right:Cross(Tangent).Unit


		result[i] = CFrame.fromMatrix(Position,Tangent,up,right)
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
