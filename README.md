# Cinnamon 3D UI
Cinnamon is a 3D UI framework for more expansive and powerful UI code

This framework aims to give developers more options in how they use 3D user interfaces.
Implementing features that are completely missing from other 3D UI frameworks.

This is achieved with:
- Support for Animations (Tweens/Bezier Curves/Springs/Oscillators)
- Layouts
- Tree based hierarchy
- World anchored UI

UI instances are wrapped around objects called `Elements`
Elements are created and stored in a `Container` object

Containers and Elements are anchored to `world position` instead of the screen by default.
We instead leave screen implementations up to the developers, tools like `Container:UDim2ToCFrame()` and `Cinnamon.Layout.PlaceFromUDim2()` are available for this

This lets Cinnamon be more versatile for more games which might require different use cases

go to [Tutorial](TUTORIAL.md) to learn how to use Cinnamon

# examples
https://www.youtube.com/watch?v=4l6erobTdBM
