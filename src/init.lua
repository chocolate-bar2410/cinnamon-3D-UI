local Container = require(script.Container)
local Animation = require(script.Animation) 
local Lookup = require(script.Lookup)
local DebugRenderer = require(script.DebugRenderer)
local Compilation = require(script.Compilation)
local ScreenContainer = require(script.ScreenContainer)

local RunService = game:GetService("RunService")

local ContainerIndex : {[ScreenGui] : Lookup.BaseContainer} = {}

local Player : Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

local RenderDistance = 200

local CullChecks = function()
	local Params = RaycastParams.new()
	local Filter = {}

	for _,v in game.Players:GetPlayers() do
		table.insert(Filter,v)
	end

	Params.FilterDescendantsInstances = Filter
	Params.FilterType = Enum.RaycastFilterType.Exclude

	for _,Container in ContainerIndex do
		if Container.Type ~= "Container" then continue end

		for _,Element in Container.Elements do

			if Element._RevertToEnabled == false and Element.Enabled == false then continue end
			local WorldPosition = Container.Origin:ToWorldSpace(Element.Offset).Position
			local PlayerPosition = Character.HumanoidRootPart.Position
			local _,OnScreen = workspace.CurrentCamera:WorldToViewportPoint(WorldPosition)

			local Visible = true

			if (WorldPosition - PlayerPosition).Magnitude > RenderDistance then Visible = false end	

			if not OnScreen then Visible = false end

			if not Visible then
				Element:_SetEnabled(false)
				Element._Data.Enabled = false
			else
				Element.Enabled = Element._RevertToEnabled
			end
				


		end

	end
end

RunService:BindToRenderStep("Cinnamon_AnimationUpdate",Enum.RenderPriority.Last.Value + 2,function(d_time)
	Animation.Update(d_time) -- [1] Animations
	DebugRenderer.Update() -- [2] Debug renderer
	ScreenContainer[2]() -- [3] Screen Space Containers
	CullChecks() --[4] Element optimisations
end)

export type Element = Lookup.Element
export type UIContainer = Lookup.UIContainer
export type ScreenContainer = Lookup.ScreenContainer
export type Spring<T> = Lookup.Spring<T>
export type Tween<T> = Lookup.Tween<T>
export type Bezier<T> = Lookup.Bezier<T>
export type Oscillator<T> = Lookup.Oscillator<T>
export type BatchAnimation<T> = Lookup.BatchAnimation<T>

return {
	GetUI_3D = function(ScreenGui)
		return ContainerIndex[ScreenGui]
	end,
	NewContainer = function(ScreenGui,Origin)
		ContainerIndex[ScreenGui] = Container(ScreenGui,Origin)
		
		return ContainerIndex[ScreenGui]
	end,
	NewScreenContainer = function(ScreenGui,DisplayDistance)
		ContainerIndex[ScreenGui] = ScreenContainer[1](ScreenGui,DisplayDistance)
		
		return ContainerIndex[ScreenGui]
	end,

	Animation = Animation.Interface :: Lookup.AnimationMethods,
	Destroy = function(UI3D_Object)
		if UI3D_Object.UI and ContainerIndex[UI3D_Object.UI] then
			ContainerIndex[UI3D_Object.UI] = nil
		end
		
		if not UI3D_Object.Destroy then return end
		UI3D_Object:Destroy()
	end,
	Layout = require(script.Layout),
	Compile = function(Source,Reference)
		local Objects = Compilation(Source, Reference)

		for _,v : Lookup.BaseContainer in Objects do
			if not v.Type then continue end
			if v.Type ~= "Container" and v.Type ~= "ScreenContainer" then continue end

			ContainerIndex[v.UI] = v
		end

		return Objects
	end
}


