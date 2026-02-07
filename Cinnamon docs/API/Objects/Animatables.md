Animatable (Base class, not usable)
```lua
type Animatable<T> = {
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
```

Tweens:
```lua
type Tween<T> = Animatable<T> & {
	EasingDirection : string,
	EasingStyle : string,
	Time : number,
	Origin : T,
	
	Type : "Tween"
}
```
Springs:
```lua
type Spring<T> = Animatable<T> & {
	k1 : number,
	k2 : number,
	k3 : number,
	Previous : T,
	Velocity : T,
	
	Type : "Spring"
}
```
Beziers:
```lua
type Bezier<T> = Tween<T> & {
	P1 : T,
	P2 : T,
	Type : "Bezier"
}
```
Oscillators:
```lua
type Oscillator<T> = Tween<T> & {
	Type : "Oscillator",
	Frequency : number,
	Phase : number,
	WaveForm : (Time : number,Frequency : number,Phase : number) -> number
}
```
Batch Animation:
```lua
type BatchAnimation<T> = {Animatable<T>} & {
	SetEnabled : (BatchAnimation<T>,Enabled : Boolean) -> nil,
	SetGoals : (BatchAnimation<T>,Goal : {T}) -> nil,
}
```