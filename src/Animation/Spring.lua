local module = {}

local LerpFunction = function(a,b,t)
	return a + t * (b - a)
end


module.Update = function(self,d_time)
	if not self.Instance then return end
	
	local Property = self.Property
	local TypeName = typeof(self.Instance[Property])
	
	local scaled_time = d_time * self.Speed
	
	local Displacement = (self.Previous - self.Goal)

	self.Instance[Property] += self.Velocity * scaled_time
	
	local k2_stable = math.max(self.k2,1.1 * ((scaled_time ^ 2) / 4 + scaled_time * self.k1 / 2))
	local Acceleration = (self.Goal + (self.k1 * Displacement) - self.Instance[Property] - (self.k1 * self.Velocity)) / k2_stable
	
	self.Velocity += Acceleration * scaled_time
	self.Previous = self.Goal	
end


module.NewSpring = function(_Instance,Property,Goal,Frequency,Damping,Response,Speed)
	local Velocity
	
	if typeof(Goal) == "CFrame" then
		Velocity = CFrame.new(0,0,0)
	elseif typeof(Goal) == "Vector3" then
		Velocity = Vector3.zero
	elseif typeof(Goal) == "Vector2" then
		Velocity = Vector2.zero
	else
		Velocity = 0
	end
	
	local k1 = Damping / (math.pi * Frequency)
	local k2 = 1 / math.pow((2 * math.pi * Frequency),2)
	local k3 = Response * Damping / (2 * math.pi * Frequency)
	
	local Spring = {
		k1 = k1,
		k2 = k2,
		k3 = k3,
		Goal = Goal,
		Previous = _Instance[Property],
		Velocity = Velocity,
		Instance = _Instance,
		Property = Property,
		Type = "Spring",
		Enabled = false,
		
		Speed = Speed or 1,
	}
	return Spring
end

return module