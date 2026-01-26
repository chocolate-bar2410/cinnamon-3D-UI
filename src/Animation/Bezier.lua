local module = {}

local QuadraticBezier_CFrame = function(Origin : CFrame,P1 : CFrame,Goal : CFrame,t)
	local A = Origin:Lerp(P1,t)
	local B = P1:Lerp(Goal,t)

	return A:Lerp(B,t)
end

local CubicBezier_CFrame = function(Origin : CFrame,P1 : CFrame,P2 : CFrame,Goal : CFrame,t)
	local A = Origin:Lerp(P1,t)
	local B = P1:Lerp(P2,t)
	local C = P2:Lerp(Goal,t)

	local D = A:Lerp(B,t)
	local E = B:Lerp(C,t)

	return D:Lerp(E,t)
end

local QuadraticBezier = function(Origin,P1,Goal,t)
	if typeof(Origin) == "CFrame" then return QuadraticBezier_CFrame(Origin,P1,Goal,t) end
	
	return (1 - t) ^2 * Origin + 2 * (1 - t) * t * P1 + t^2 * Goal
end

local CubicBezier = function(Origin,P1,P2,Goal,t)
	if typeof(Origin) == "CFrame" then return CubicBezier_CFrame(Origin,P1,P2,Goal,t) end
	
	local a = (1 - t)^3 * Origin
	local b = 3 * (1 - t)^2 * t * P1
	local c = 3 * (1 - t) * t ^ 2 * P2
	local d = t^3 * Goal
	
	return a + b + c + d
end



local Lookup = require(script.Parent.Parent.Lookup)

local GetEasedTime = function(Time,EasingDirection,EasingStyle)
	
	if EasingStyle == "Linear" then return Time end
	if EasingStyle == "Constant" then
		return Time >= 0.5 and 1 or 0
	end
	
	return Lookup.EasingFunctions[EasingDirection][EasingStyle](Time)
end

module.Update = function(self,d_time)
	
	if self.Time >= 1 then return end
	self.Time = math.clamp(self.Time + d_time * self.Speed,0,1)
	
	if not self.Instance then return end
	
	local Property = self.Property
	local TypeName = typeof(self.Instance[Property])
	
	local EasedTime = GetEasedTime(self.Time,self.EasingDirection,self.EasingStyle)
	
	if self.P2 then
		self.Instance[Property] = CubicBezier(self.Origin,self.P1,self.P2,self.Goal,EasedTime)
	else
		self.Instance[Property] = QuadraticBezier(self.Origin,self.P1,self.Goal,EasedTime)
	end

end

module.NewBezier = function(_Instance,Property,Goal,EasingDirection,EasingStyle,P1,P2,Speed)
	local Tween = {
		EasingDirection = EasingDirection,
		EasingStyle = EasingStyle,
		Goal = Goal,
		Origin = _Instance[Property],
		P1 = P1,
		P2 = P2,
		Time = 0,
		
		Instance = _Instance,
		Property = Property,
		Type = "Bezier",
		Enabled = false,
		
		Speed = Speed or 1,
	}

	return Tween
end

return module