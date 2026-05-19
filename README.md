# RKGameShared

A small collection of utilities to assist with code generation of 3D models for RealityKit.

For a lot of 2025 I was working on a game inspired by the wonderful Apple TV series, [Severence](https://en.wikipedia.org/wiki/Severance_(TV_series).

In this game, I first started work on a SceneKit/SpriteKit implementation and had that working well on iOS/tvOS, and macOS.

Then in WWDC 2026 it was announced that SceneKit would be no more, and RealityKit, the new shiny.  So I pivotted and spent some months reworking the game to run in RealityKit/SpriteKit.

This repository contains the utility code I wrote to get the game to behave similarly to what I had under SceneKit.

That being said, RealityKit is by no means mature from my point of view, and the performance is far from acceptable.  

My intention is to release all of the code for the game eventually, but I am starting with this repo as it doesn't have anything in it that affects my other apps that are in-store.

For the game, the entire model was built by code, using the functions and classes in this repo where RealityKit fell short.  No part of the model was built using models created in tools such as Blender.

## Sidenote

I would also point out that the RealityKit version of the game was iteration 2 of 3.  The first was SceneKit/SpriteKit, the second RealityKit/SpriteKit, and the final was Unity.  For me, the first was the best, though I did achieve some stuff in Unity that was pretty nice.
