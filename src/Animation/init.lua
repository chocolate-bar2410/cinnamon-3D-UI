local module = {}
module.Interface = {}

local Package = script.Parent

local Tween = require(script.Tween)
local Spring = require(script.Spring)
local Bezier = require(script.Bezier)
local Oscillator = require(script.Oscillator)
local Lookup = require(Package.Lookup)

local Tweens = {}
local Springs = {}
local Beziers = {}
local Oscillators = {}
local TimelineAnims : {Lookup.Animatable<any>} = {}

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
	
	for _,TimelineAnim in TimelineAnims do
		local Timeline = TimelineAnim.Timeline

		if Timeline.IndexPointer >= #Timeline or TimelineAnim.Time < 1 then continue end
		Timeline.IndexPointer += 1
		TimelineAnim.Time -= 1


		local SetOrigin = true

		if Timeline[Timeline.IndexPointer]["Property"] then
			local Property = Timeline[Timeline.IndexPointer]["Property"]
			TimelineAnim.Origin = TimelineAnim.Instance[Property]
			
			SetOrigin = false
		end

		for i,v in Timeline[Timeline.IndexPointer] do
			if i == "Time" then
				TimelineAnim.Speed = 1 / v
				continue
			end
			if i == "Goal" and SetOrigin then
				TimelineAnim.Origin = TimelineAnim.Goal
			end
			TimelineAnim[i] = v
		end
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
	
	if Animatable.Timeline then
		local Index = table.find(TimelineAnims,Animatable)
		table.remove(TimelineAnims,Index)
	end

end

--// animation options

module.Tween = function(_Instance,Property,Goal,EasingDirection,EasingStyle,Speed)
	local TweenObject = Tween.NewTween(_Instance,Property,Goal,EasingDirection,EasingStyle,Speed)
	
	table.insert(Tweens,TweenObject)
	TweenObject.Destroy = DestroyMethod
	return TweenObject
end

module.Spring = function(_Instance,Property,Goal,Frequency,Damping,Response,Speed)
	local SpringObject = Spring.NewSpring(_Instance,Property,Goal,Frequency,Damping,Response,Speed)

	table.insert(Springs,SpringObject)
	SpringObject.Destroy = DestroyMethod
	return SpringObject
end

module.Bezier = function(_Instance,Property,Goal,EasingDirection,EasingStyle,P1,P2,Speed)
	local BezierObject = Bezier.NewBezier(_Instance,Property,Goal,EasingDirection,EasingStyle,P1,P2,Speed)
	
	table.insert(Beziers,BezierObject)
	BezierObject.Destroy = DestroyMethod
	return BezierObject
end

module.Oscillator = function(_Instance,Property,Goal,Frequency,Phase,EasingDirection,EasingStyle,WaveForm : Lookup.WaveForm,Speed)
	
	local OscillatorObject = Oscillator.NewOscilator(_Instance,Property,Goal,Frequency,Phase,EasingDirection,EasingStyle,WaveForm,Speed)

	table.insert(Oscillators,OscillatorObject)
	OscillatorObject.Destroy = DestroyMethod
	return OscillatorObject
	
end

module.Interface.Animate = function<T>(_Instance,
	Props : Lookup.AnimationPropertyTable<T>
)
	local AnimationType = Props.Type

	local Speed = 1 / Props.Time or 1 

	if not AnimationType then 
		warn("Must Add Animation Type")
		return 
	end
	if not module[AnimationType] then 
		warn("Invalid Animation Type :",AnimationType)
		return 
	end
	
	if AnimationType == "Tween" then
		return module.Tween(_Instance,
			Props.Property,
			Props.Goal,
			Props.EasingDirection,
			Props.EasingStyle,
			Speed
		)
	elseif AnimationType == "Spring" then
		return module.Spring(_Instance,
			Props.Property,
			Props.Goal,
			Props.Frequency,
			Props.Damping,
			Props.Response,
			Speed
		)
	elseif AnimationType == "Bezier" then
		return module.Bezier(_Instance,
			Props.Property,
			Props.Goal,
			Props.EasingDirection,
			Props.EasingStyle,
			Props.P1,
			Props.P2,
			Speed
		)
	elseif AnimationType == "Oscillator" then
		return module.Oscillator(_Instance,
			Props.Property,
			Props.Goal,
			Props.Frequency,
			Props.Phase,
			Props.EasingDirection,
			Props.EasingStyle,
			Props.WaveForm,
			Speed
		)
	end

	return
end

module.Interface.AttachTimeline = function<T>(Animatable : Lookup.Animatable<T>,Timeline : Lookup.AnimTimeline)
	Animatable.Timeline = Timeline

	table.insert(TimelineAnims,Animatable)

	table.sort(Timeline,function(a,b)
		return a.Time < b.Time
	end)

	local InitStates = {}

	InitStates.Origin = Animatable.Origin

	for i = 1,#Timeline do
		if Timeline[i].Property then
			InitStates[Timeline[i].Property] = Animatable.Instance[Timeline[i].Property]
		end

		for index,value in Timeline[i] do
			
			if InitStates[index] then continue end
			if index == "Time" then continue end
			InitStates[index] = Animatable[index]
		end
	end

	Timeline.InitStates = InitStates
	Timeline.IndexPointer = 0
end

module.Interface.BatchAnimation = function(AnimationType : string,
	_Instances : {Instance | Lookup.Element},
	Props : Lookup.BaseAnimationPropertyTable,
	GroupData : {Goal : {},P1 : {},P2 : {},Phase : {}})

	if not module[AnimationType] then return end

	local Speed = 1 / Props.Time or 1 

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
			Animatable = module.Tween(_Instance,Props.Property,Goal,Props.EasingDirection,Props.EasingStyle,Speed)
		elseif AnimationType == "Spring" then
			Animatable = module.Spring(_Instance,Props.Property,Goal,Props.Frequency,Props.Damping,Props.Response,Speed)
		elseif AnimationType == "Bezier" then
			local P1 = GroupData.P1 and GroupData.P1[i] or nil
			local P2 = GroupData.P2 and GroupData.P2[i] or nil

			Animatable = module.Bezier(_Instance,Props.Property,Goal,Props.EasingDirection,Props.EasingStyle,P1,P2,Speed)
		elseif AnimationType == "Oscillator" then
			Animatable = module.Oscillator(_Instance,Props.Property,Goal,Props.Frequency,GroupData.Phase[i],Props.EasingDirection,Props.EasingStyle,Props.WaveForm,Speed)
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
	if Animatable.Timeline then
		Animatable.Timeline.IndexPointer = 0
		for i,v in Animatable.Timeline.InitStates do
			if not Animatable[i] then 
				Animatable.Instance[i] = v
				continue 
			end
			Animatable[i] = v
		end
	end

	if Animatable.Type == "Tween" or Animatable.Type == "Bezier" then
		Animatable.Instance[Animatable.Property] = Animatable.Origin
		Animatable.Time = 0
	end
end


return module
