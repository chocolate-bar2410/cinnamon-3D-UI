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

local DefaultWaveForm = function(Time,Frequency,Phase)
	return (1 + math.cos(2 * math.pi * Time * Frequency + Phase + math.pi)) / 2
end

module.Update = function(self : Lookup.Oscillator<any>,d_time)
	
	if self.Time >= 1 then 
		self.Time = 0
	else
		self.Time = math.clamp(self.Time + d_time * self.Speed,0,1)
	end
	
	if not self.Instance then return end
	
	local Property = self.Property
	local TypeName = typeof(self.Instance[Property])
	
	local EasedTime = GetEasedTime(self.Time,self.EasingDirection,self.EasingStyle)
	
	local Waveform = self.WaveForm or DefaultWaveForm
	
	if TypeName == "CFrame" then
		self.Instance[Property] = self.Origin:Lerp(self.Goal,Waveform(EasedTime,self.Frequency,self.Phase))
		print(Waveform(EasedTime,self.Frequency,self.Phase))
	else
		self.Instance[Property] = LerpFunction(self.Origin,self.Goal,Waveform(EasedTime,self.Frequency,self.Phase))
		
		
	end
end

module.NewOscilator = function(_Instance,Property,Goal,Frequency,Phase,EasingDirection,EasingStyle,WaveForm,Speed)
	local Tween = {
		EasingDirection = EasingDirection,
		EasingStyle = EasingStyle,
		Goal = Goal,
		Origin = _Instance[Property],
		Time = 0,
		
		Frequency = Frequency,
		Phase = Phase,
		WaveForm = WaveForm,
		Speed = Speed or 1,
		
		Instance = _Instance,
		Property = Property,
		Type = "Oscillator",
		Enabled = false
	}
	return Tween
end

return module