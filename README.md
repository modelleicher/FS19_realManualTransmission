# FS19_realManualTransmission
Manual Transmission/Gearbox for FS19


First things first, this is obviously beta. I try not to publish anything gamebraking but don't hate me when your game crashes. :)

# What is this?
This is a manual Gearbox/Transmission mod for FS19. It is not a conversion of GearboxAddon, its an entirely new mod. It has less features than GearboxAddon, its also (for now) just for simulating manual transmissions, not for automatics or CVTs. It also lacks a lot of the physics improvements Gearbox Addon had.
This is basically Giants Physics with the addition of Gears. I don't know physics or scripting enough to create anything more than that, also it seems that FS19 is even more restricted as to what you can actually change or influence.
Doesn't mean this Mod isn't still a lot of fun.. :)
Basic Features (as of right now):
- manual (analog) or automatic clutch (This means you can play it with Keyboard, Controller, Steering Wheel and so on)
- gears (obviously) 
- up to 3 different rangeSets
- reverser/shuttle
- powershiftable ranges and gears
- automatic range matching (like John Deere PowerQuad for example)


# How do I play this? 
Just download the FS19_realManualTransmission.zip into your modfolder. All the bindings are not mapped by default so you have to go into the Key Bindings first and map all the bindings the way you like them. The key bindings related to this Mod all have the prefix RMT.
There is also an ingame Settings Menu (you have to map the key to open it) where you can toggle on automatic clutch and automatic opening of the clutch at minRPM, those are settings for people without a clutch pedal or playing on Keyboard/Controller.

I suggest you get the sample-mods from this repository as well to try out gearbox. Those are basegame vehicles that I have added Transmission Configs and edited the sound of, so they have an actual load-sound.
But RMT also adds transmission configs to some of the basegame vehicles. (As of right now, Fiat 1300dt, Valtra A Series and John Deere 6M)
In order to use the transmission with a vehicle it has to have a transmission config.
There are RMT-ready XML's in the old MR-Database. (There's a RMT category)
https://xmldb.tlg-webservice.de/uploads


# How do I add a transmission Config to a Mod?
Start by looking at the sample mods and the basegameConfigs.xml. The transmission config and all the possible options should be self explanatory if you know your way around XML.
You can find more detailed explanation of what the different XML options are in the basegameConfigs.xml :)
Just add the realManualTransmission part to the XML of your Mod and it will have the Transmission. Basically, its very similar to GearboxAddon, so if you have ever added a config to a vehicle in FS17 GearboxAddon, you won't have any issues.
I will add a Tutorial on how to add transmission at a later date as right now there is still a lot up for change.


# Whats the future for this Mod, what are the plans? 
UPDATE!
The basics are all working. The clutch is still not how I wanted it to be (sorry to all of you that stall their engines a lot.. Thats not how its supposed to be I know).
Currently I'm working on fixing the last few Multiplayer Bugs, overall the script is Multiplayer-Ready now, but it is still a big glitchy sometimes. 

-- original Text
Well.. The initial goal was to get a manual analog clutch and gears working in FS19. That is working, altough I am still not happy with the clutch.
So for right now, the next thing to add is Multiplayer support. After that, we'll see. I was thinking of a "fully automatic" version, e.g. it shifts for you and all, but thats almost an entire script on its own if it should shift like a real driver would shift.
There is also the addition of automatic gearboxes like some of the modern tractors have. Or maybe better simulation of CVT transmissions.. Issue though is, that I never have driven any modern tractor, thus I don't really know how the transmissions feel and operate. So I'm not sure if I have enough knowledge to tackle that.
So for now, its all focussed on manual and powershift transmissions.









