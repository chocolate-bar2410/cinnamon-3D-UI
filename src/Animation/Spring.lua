local module = {}

module.Update = function(self,d_time)
	if not self.Instance then return end
	
	local Property = self.Property
	local scaled_time = d_time * self.Speed

	local k2_stable = math.max(self.k2,1.1 * ((scaled_time ^ 2) / 4 + scaled_time * self.k1 / 2))

	if typeof(self.Goal) == "CFrame" or self.Property == "CFrame" then
		local current = self.Instance[Property]
		
		local d_position = (self.Previous.Position - self.Goal.Position)
		local Position_Accel = (self.Goal.Position + (self.k1 * d_position) - current.Position - (self.k1 * self.Velocity.Position)) / k2_stable

		local d_Look = (self.Previous.LookVector - self.Goal.LookVector)
		local Look_Accel = (self.Goal.LookVector + (self.k1 * d_Look) - current.LookVector - (self.k1 * self.Velocity.LookVector)) / k2_stable

		self.Velocity.Position += Position_Accel * scaled_time
		self.Velocity.LookVector += Look_Accel * scaled_time
		
		self.Instance[Property] = CFrame.new(
			current.Position + self.Velocity.Position * scaled_time,
			current.LookVector + self.Velocity.LookVector * scaled_time
		)

		self.Previous = self.Goal	

		return
	end

	local Displacement = (self.Previous - self.Goal)
	self.Instance[Property] += self.Velocity * scaled_time
	local Acceleration = (self.Goal + (self.k1 * Displacement) - self.Instance[Property] - (self.k1 * self.Velocity)) / k2_stable
	
	self.Velocity += Acceleration * scaled_time
	self.Previous = self.Goal	
end


module.NewSpring = function(_Instance,Property,Goal,Frequency,Damping,Response,Speed)
	local Velocity
	
	if typeof(Goal) == "CFrame" then
		Velocity = {Position = Vector3.zero,LookVector = Vector3.zero}
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