local module = {}

local LerpFunction = function(a,b,t)
	return a + t * (b - a)
end

local Lookup = require(script.Parent.Parent.Lookup)

local GetEasedTime = function(Time,EasingDirection,EasingStyle)
	
	EasingDirection = typeof(EasingDirection) == "EnumItem" and EasingDirection.Name or EasingDirection
	EasingStyle = typeof(EasingStyle) == "EnumItem" and EasingStyle.Name or EasingStyle

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
	
	if TypeName == "CFrame" or TypeName == "Vector3" or TypeName == "Vector2" then
		self.Instance[Property] = self.Origin:Lerp(self.Goal,EasedTime)
	else
		self.Instance[Property] = LerpFunction(self.Origin,self.Goal,EasedTime)
		print(LerpFunction(self.Origin,self.Goal,EasedTime))
	end
end

module.NewTween = function(_Instance,Property,Goal,EasingDirection,EasingStyle,Speed)
	local Tween = {
		EasingDirection = EasingDirection,
		EasingStyle = EasingStyle,
		Goal = Goal,
		Origin = _Instance[Property],
		Time = 0,
		Instance = _Instance,
		Property = Property,
		Type = "Tween",
		Enabled = false,
		
		Speed = Speed or 1,
	}
	return Tween
end

return module