Methods for creating and managing [animations](API/Objects/Animatables.md).

Methods:
Tween -> Tween
```lua
function Animation.Tween<T>(
	_Instance : Instance,
	Property : string,
	Goal : T,
	EasingDirection : string,
	EasingStyle : string,
	Speed : number
) : Tween<T>
```
- Creates tween animation
  
  Spring -> Spring
```lua
function Spring<T>(
	_Instance : Instance,
	Property : string,
	Goal : T,
	Frequency : number,
	Damping : number,
	Response : number,
	Speed : number

) : Spring<T>
```
- Creates spring animation

Bezier -> Bezier
```lua
function Bezier<T>(

	_Instance : Instance,
	Property : string,
	Goal : T,
	EasingDirection : string,
	EasingStyle : string,
	P1 : T,
	P2 : T,
	Speed : number
) : Bezier<T>
```
- Creates bezier animation

Oscillator -> Oscillator
```lua
function Oscillator<T>(

	_Instance : Instance,
	Property : string,
	Goal : T,
	Frequency : number,
	Phase : number,
	EasingDirection : string,
	EasingStyle : string,
	WaveForm : WaveForm,
	Speed : number
) : Oscillator<T>
```
- Creates oscillation animation

BatchAnimation -> BatchAnimation
```lua
function BatchAnimation<T>(

	AnimationType : "Tween" | "Spring" | "Bezier" | "Oscillator",
	_Instances : {Instance | Element},
	Props : {Property : string},
	GroupData : {Goal : {T},P1 : {T},P2 : {T},Phase : {number}}
) : BatchAnimation

```
- Creates batch animation

SetGoal -> nil
```lua
function SetGoal<T>(Animated : Animatable<T>,Goal : T) -> nil
```
- Sets the goal of a single animation

Reset -> nil
```lua
function Reset<T>(Animated : Animatable<T>) -> nil
```
- Resets an animation