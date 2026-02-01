export type UI3D_Object = {
	Destroyed : boolean,
	Destroy : (UI3D_Object) -> nil,
	Enabled : boolean,
	Debug : boolean,
	Type : "Container" | "Element" | "ScreenContainer"
}

type BaseContainer = UI3D_Object & {
	Type : "Container" | "ScreenContainer",
	UI : ScreenGui,
	Elements : {Element},
	Clear : (BaseContainer) -> nil,
	NewElement : (BaseContainer,UI : GuiObject,Offset : CFrame,Resolution : Vector2,Face : Enum.NormalId) -> Element,
}

export type Element = UI3D_Object & {
	Instance : Part & {
		SurfaceGui : SurfaceGui
	},
	Type : "Element",

	UI : GuiObject,
	Container : UIContainer,
	Connections : {RBXScriptConnection},
	Parent2D : GuiObject,
}

export type UIContainer = BaseContainer & {
	Origin : CFrame,
	Children : {UIContainer},
	Type : "Container",

	UDim2ToCFrame : (UIContainer,Position : UDim2,ViewPortSize : Vector2,DisplayDistance : number) -> CFrame,
	NewContainer : (UIContainer,ScreenGui : ScreenGui, Origin : CFrame) -> UIContainer
}

export type ScreenContainer = BaseContainer & {
	UI : ScreenGui,
	Type : "ScreenContainer",
	DisplayDistance : number,
	WorldCFrame : CFrame,

	UDim2ToCFrame : (ScreenContainer,Position : UDim2,ViewPortSize : Vector2) -> CFrame,
	GetPartSize : (ScreenContainer,ViewPortSize : Vector2) -> Vector3,
}


export type Animatable<T> = {
	Goal : T,
	Type : "Tween" | "Spring" | "Bezier" | "Oscillator",
	Instance : Instance,
	Property : string,
	Enabled : boolean,
	Speed : number,
	
	Destroy : (Animatable<T>),

	Time : number,
	Origin : T,
	
}

export type Tween<T> = Animatable<T> & {
	EasingDirection : string,
	EasingStyle : string,
	Time : number,
	Origin : T,
	
	Type : "Tween"
}

export type Spring<T> = Animatable<T> & {
	k1 : number,
	k2 : number,
	k3 : number,
	Previous : T,
	Velocity : T,
	
	Type : "Spring"
}

export type Bezier<T> = Tween<T> & {
	P1 : T,
	P2 : T,
	Type : "Bezier"
}

export type Oscillator<T> = Tween<T> & {
	Type : "Oscillator",
	Frequency : number,
	Phase : number,
	WaveForm : WaveForm
}

export type WaveForm = (Time : number,Frequency : number,Phase : number) -> number

export type AnimationMethods = {
	Tween : <T>(
		_Instance : Instance,
		Property : string,
		Goal : T,
		EasingDirection : string,
		EasingStyle : string,
		Speed : number
	) -> Tween<T>,
	Spring : <T>(
		_Instance : Instance,
		Property : string,
		Goal : T,
		Frequency : number,
		Damping : number,
		Response : number,
		Speed : number
	) -> Spring<T>,
	Bezier : <T>(
		_Instance : Instance,
		Property : string,
		Goal : T,
		EasingDirection : string,
		EasingStyle : string,
		P1 : T,
		P2 : T,
		Speed : number
	) -> Bezier<T>,
	Oscillator : <T>(
		_Instance : Instance,
		Property : string,
		Goal : T,
		Frequency : number,
		Phase : number,
		EasingDirection : string,
		EasingStyle : string,
		WaveForm : WaveForm,
		Speed : number
	) -> Oscillator<T>,
	BatchAnimation : <T>(
		AnimationType : "Tween" | "Spring" | "Bezier" | "Oscillator",
		_Instances : {Instance | Element},
		Props : {Property : string},
		GroupData : {Goal : {T},P1 : {T},P2 : {T},Phase : {number}}
		
	) -> {Animatable<T>} & {
		SetEnabled : (Enabled : boolean) -> nil,
		SetGoals : (Goal : {T}) -> nil,
	},
	
	
	
	SetGoal : <T>(Animated : Animatable<T>,Goal : T) -> nil,
	Reset : <T>(Animated : Animatable<T>) -> nil,

}

export type BatchAnimationPropertyTable = {
	Property : string,
	EasingDirection : string,
	EasingStyle : string,
	Speed : number,
	Frequency : number,
	Damping : number,
	Response : number,
	WaveForm : WaveForm
}

return {
	
	EasingFunctions = {
		["In"] = {
			Back = function(Time : number)
				local c1 = 1.70158;
				local c3 = c1 + 1;

				return c3 * (Time ^ 3) - c1 * Time ^ 2;
			end,
			Quad = function(Time : number)
				return Time ^ 2
			end,
			Cubic = function(Time: number)
				return Time ^ 3
			end,
			Sine = function(Time : number)
				return 1 - math.cos((Time * math.pi )/ 2)
			end,
			Circ = function(Time : number)
				return 1 - math.sqrt(1 - Time * Time)
			end,
			Expo = function(Time : number)
				return Time == 0 and 0 or math.pow(2, 10 * (Time - 1))
			end,
			Quart = function(Time : number)
				return Time^4
			end
		},
		["Out"] = {
			Back = function(Time: number)
				local c1 = 1.70158;
				local c3 = c1 + 1;

				return 1 + c3 * (Time - 1) ^ 3 + c1 * (Time - 1) ^ 2
			end,

			Quad = function(Time: number)
				return 1 - (1 - Time) * (1 - Time);
			end,

			Cubic = function(Time: number)
				return 1 - (1 - Time) ^ 3
			end,

			Quart = function(t)
				return 1 - (1 - t)^4
			end,

			Sine = function(Time : number)
				return math.sin((Time * math.pi )/ 2)
			end,

			Circ = function(t)
				return math.sqrt(1 - (t - 1) * (t - 1))
			end,
			Expo = function(t)
				return t == 1 and 1 or 1 - math.pow(2, -10 * t)
			end,
		},
		["InOut"] = {
			Back = function(Time: number)
				local c1 = 1.70158;
				local c2 = c1 * 1.525;

				return Time < 0.5
					and ((2 * Time)^2 * ((c2 + 1) * 2 * Time - c2)) / 2
					or ((2 * Time - 2) ^ 2 * ((c2 + 1) * (Time * 2 - 2) + c2) + 2) / 2;
			end,
			Quad = function(Time: number)
				return Time < 0.5 and 2 * Time ^ 2 or 1 - math.pow(-2 * Time + 2, 2) / 2
			end,

			Cubic = function(Time: number)
				return Time < 0.5 and 4 * Time ^ 3 or 1 - math.pow(-2 * Time + 2, 3) / 2
			end,

			Quart = function(Time : number)
				return Time < 0.5 and 8 * Time ^ 4 or 1 - math.pow(-2 * Time + 2, 4) / 2

			end,
			Sine = function(Time: number)
				return -(math.cos(math.pi * Time) - 1) / 2;
			end,
			Circ = function(Time : number)
				return Time < 0.5 and (1 - math.sqrt(1 - (2 * Time)^2)) / 2 or (math.sqrt(1 - (-2 * Time + 2)^2) + 1) / 2
			end,
			Expo = function(Time : number)

				if Time == 0 then return 0 end
				if Time == 1 then return 1 end

				return Time < 0.5 and math.pow(2, 20 * Time - 10) / 2 or (2 - math.pow(2, -20 * Time + 10)) / 2
			end,

		},
		["OutIn"] = {
			Sine = function(Time: number)
				return Time < 0.5
					and math.sin((Time * 2 * math.pi) / 2) / 2
					or (1 - math.cos(((Time - 0.5) * 2 * math.pi) / 2)) / 2 + 0.5
			end,

			Quad = function(Time: number): number
				if Time < 0.5 then
					return 0.5 * (1 - (1 - 2 * Time)^2)
				else
					return 0.5 + 0.5 * ((2 * Time - 1)^2)
				end
			end,

			Cubic = function(Time: number): number
				if Time < 0.5 then
					return 0.5 * (1 - (1 - 2 * Time)^3)
				else
					return 0.5 + 0.5 * ((2 * Time - 1)^3)
				end
			end,

			Quart = function(Time: number): number
				if Time < 0.5 then
					return 0.5 * (1 - (1 - 2 * Time)^4)
				else
					return 0.5 + 0.5 * ((2 * Time - 1)^4)
				end
			end,

			Expo = function(Time: number)
				return Time == 0 and 0
					or Time == 1 and 1
					or Time < 0.5
					and (1 - math.pow(2, -10 * Time * 2)) / 2
					or math.pow(2, 10 * ((Time - 0.5) * 2 - 1)) / 2 + 0.5
			end,

			Circ = function(Time: number)
				return Time < 0.5
					and math.sqrt(1 - math.pow(Time * 2 - 1, 2)) / 2
					or (1 - math.sqrt(1 - math.pow((Time - 0.5) * 2, 2))) / 2 + 0.5
			end,

			Back = function(Time: number)
				local c1 = 1.70158
				local c3 = c1 + 1
				return Time < 0.5
					and ((Time * 2 - 1)^2 * ((c3) * (Time * 2 - 1) + c1) + 1) / 2
					or (((Time - 0.5) * 2)^2 * ((c3) * ((Time - 0.5) * 2) - c1)) / 2 + 0.5
			end,
		}
	}
}
