local ContainerIndex = {}

local Container = require(script.Container)
local Animation = require(script.Animation)
local Lookup = require(script.Lookup)
local DebugRenderer = require(script.DebugRenderer)

local ScreenContainer = require(script.ScreenContainer)

local RunService = game:GetService("RunService")

RunService:BindToRenderStep("Cinnamon_AnimationUpdate",Enum.RenderPriority.Last.Value + 2,function(d_time)
	Animation.Update(d_time) -- [1] Animations
	DebugRenderer.Update() -- [2] Debug renderer
	ScreenContainer[2]() -- [3] Screen Space Containers
end)

export type Element = Lookup.Element
export type UIContainer = Lookup.UIContainer
export type ScreenContainer = Lookup.ScreenContainer
export type Spring<T> = Lookup.Spring<T>
export type Tween<T> = Lookup.Tween<T>

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
}


