local module = {}
module.Interface = {}

local Tweens = {}
local Springs = {}
local Beziers = {}
local Oscillators = {}

local Package = script.Parent

local Tween = require(script.Tween)
local Spring = require(script.Spring)
local Bezier = require(script.Bezier)
local Oscillator = require(script.Oscillator)
local Lookup = require(Package.Lookup)

module.Update = function(d_time)
	for _,TweenObject in Tweens do
		if not TweenObject.Enabled then continue end
		
		Tween.Update(TweenObject,d_time)
	end
	
	for _,SpringObject in Springs do

		if not SpringObject.Enabled then continue end

		Spring.Update(SpringObject,d_time)
	end
	
	for _,BezierObject in Beziers do
		if not BezierObject.Enabled then continue end
		
		Bezier.Update(BezierObject,d_time)
	end

	for _,OscillatorObject in Oscillators do
		if not OscillatorObject.Enabled then continue end

		Oscillator.Update(OscillatorObject,d_time)
	end
	
end

local DestroyMethod = function(Animatable : Lookup.Animatable<any>)
	if Animatable.Type == "Tween" then
		local Index = table.find(Tweens,Animatable)
		table.remove(Tweens,Index)
		
	elseif Animatable.Type == "Spring" then
		local Index = table.find(Springs,Animatable)
		table.remove(Springs,Index)
		
		
	elseif Animatable.Type == "Bezier" then
		local Index = table.find(Beziers,Animatable)
		table.remove(Beziers,Index)
		
	elseif Animatable.Type == "Oscillator" then
		local Index = table.find(Oscillators,Animatable)
		table.remove(Oscillators,Index)
	
	end
	
end

--// animation options

module.Interface.Tween = function(_Instance,Property,Goal,EasingDirection,EasingStyle,Speed)
	local TweenObject = Tween.NewTween(_Instance,Property,Goal,EasingDirection,EasingStyle,Speed)
	
	table.insert(Tweens,TweenObject)
	TweenObject.Destroy = DestroyMethod
	return TweenObject
end

module.Interface.Spring = function(_Instance,Property,Goal,Frequency,Damping,Response,Speed)
	local SpringObject = Spring.NewSpring(_Instance,Property,Goal,Frequency,Damping,Response,Speed)

	table.insert(Springs,SpringObject)
	SpringObject.Destroy = DestroyMethod
	return SpringObject
end

module.Interface.Bezier = function(_Instance,Property,Goal,EasingDirection,EasingStyle,P1,P2,Speed)
	local BezierObject = Bezier.NewBezier(_Instance,Property,Goal,EasingDirection,EasingStyle,P1,P2,Speed)
	
	table.insert(Beziers,BezierObject)
	BezierObject.Destroy = DestroyMethod
	return BezierObject
end

module.Interface.Oscillator = function(_Instance,Property,Goal,Frequency,Phase,EasingDirection,EasingStyle,WaveForm : Lookup.WaveForm,Speed)
	
	local OscillatorObject = Oscillator.NewOscilator(_Instance,Property,Goal,Frequency,Phase,EasingDirection,EasingStyle,WaveForm,Speed)

	table.insert(Oscillators,OscillatorObject)
	OscillatorObject.Destroy = DestroyMethod
	return OscillatorObject
	
end

module.Interface.BatchAnimation = function(AnimationType : string,
	_Instances : {Instance | Lookup.Element},
	Props : Lookup.BatchAnimationPropertyTable,
	GroupData : {Goal : {},P1 : {},P2 : {},Phase : {}})

	if not module.Interface[AnimationType] or (AnimationType == "SetGoal" or AnimationType == "Reset" or AnimationType == "BatchAnimation") then
		return
	end

	local result = {}

	result["SetEnabled"] = function(Enabled)
		for _,v in ipairs(result) do
			v.Enabled = Enabled
		end
	end	

	result["SetGoals"] = function(Goals)
		for i,v in ipairs(result) do
			module.Interface.SetGoal(v,Goals[i])
		end
	end

	for i,v in ipairs(_Instances) do
		if typeof(v) == "table" and not v.Instance then continue end

		local _Instance = typeof(v) == "table" and v.Instance or v
		local Animatable
		local Goal = GroupData.Goal[i]

		if AnimationType == "Tween" then
			Animatable = module.Interface.Tween(_Instance,Props.Property,Goal,Props.EasingDirection,Props.EasingStyle,Props.Speed)
		elseif AnimationType == "Spring" then
			Animatable = module.Interface.Spring(_Instance,Props.Property,Goal,Props.Frequency,Props.Damping,Props.Response,Props.Speed)
		elseif AnimationType == "Bezier" then
			local P1 = GroupData.P1 and GroupData.P1[i] or nil
			local P2 = GroupData.P2 and GroupData.P2[i] or nil

			Animatable = module.Interface.Bezier(_Instance,Props.Property,Goal,Props.EasingDirection,Props.EasingStyle,P1,P2,Props.Speed)
		elseif AnimationType == "Oscillator" then
			Animatable = module.Interface.Oscillator(_Instance,Props.Property,Goal,Props.Frequency,GroupData.Phase[i],Props.EasingDirection,Props.EasingStyle,Props.WaveForm,Props.Speed)
		end

		table.insert(result,Animatable)
	end

	return result
end

--// animation management

module.Interface.SetGoal = function(Animatable : Lookup.Animatable<any>,Goal)
	Animatable.Goal = Goal
	
	if Animatable.Type == "Tween" or Animatable.Type == "Bezier" then
		Animatable.Time = 0
		Animatable.Origin = Animatable.Instance[Animatable.Property]
	end	
end

module.Interface.Reset = function(Animatable : Lookup.Animatable<any>) 
	if Animatable.Type == "Tween" or Animatable.Type == "Bezier" then
		Animatable.Instance[Animatable.Property] = Animatable.Origin
		Animatable.Time = 0
		
	end
end


return module
