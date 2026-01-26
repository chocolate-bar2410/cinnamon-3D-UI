local ContainerIndex = {}

local Container = require(script.Container)
local Animation = require(script.Animation)
local Lookup = require(script.Lookup)


game["Run Service"]:BindToRenderStep("AnimationUpdate",Enum.RenderPriority.Last.Value + 2,Animation.Update)

export type Element = Lookup.Element
export type UIContainer = Lookup.UIContainer
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
	Animation = Animation.Interface :: Lookup.AnimationMethods,
	Destroy = function(UI3D_Object)
		if UI3D_Object.UI and ContainerIndex[UI3D_Object.UI] then
			ContainerIndex[UI3D_Object.UI] = nil
		end
		
		if not UI3D_Object.Destroy then return end
		UI3D_Object:Destroy()
	end,
	Layout = require(script.Layout)
}


