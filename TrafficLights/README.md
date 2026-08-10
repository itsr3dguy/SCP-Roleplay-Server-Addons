### Difficulty to set up: Medium [🟡]

# Setup - Traffic Light

A smart traffic light for SCP: Roleplay. Cars get one green at a time, waiting cars are detected and given a turn, and pedestrians press a button to make the crosswalks go green.
INFO: SCP: Roleplay does not have an in-built compass system, you must create your own.

---

## 1. Add the Script

Open the **Server Addons** menu and create a new addon.

Make sure it is a **saved** addon, not "Run Once", or it will stop after ten seconds.

Copy everything from [script.lua](script.lua), paste it in, and save.

---

## 2. Build the Roads

Build the roads and the intersection **bigger than you first think you need**.

Humvees accelerate very fast, have bad speed control, and steer poorly, so a tight intersection turns into chaos almost instantly. Give yourself plenty of extra space.

---

## 3. Build the Parts

The script finds parts by name, so every name must match **exactly**. Capital letters matter.

### Traffic Lights

Four normal Parts, one per direction. Name them:
```
TrafficLightOneSouth
```
```
TrafficLightOneNorth
```
```
TrafficLightOneEast
```
```
TrafficLightOneWest
```

INFO: Cars coming from example East will see the West one. 
(Just place it in the direction as it's called)

### Road Pads

Four flat Parts on the road where cars wait. Name them:
```
TrafficPadOneNorth
```
```
TrafficPadOneSouth
```
```
TrafficPadOneEast
```
```
TrafficPadOneWest
```

### Crosswalk Lights

Eight normal Parts, two per side (an A and a B). Every name must be unique:
```
CrosswalkLightOneSouthA
```
```
CrosswalkLightOneSouthB
```
```
CrosswalkLightOneNorthA
```
```
CrosswalkLightOneNorthB
```
```
CrosswalkLightOneEastA
```
```
CrosswalkLightOneEastB
```
```
CrosswalkLightOneWestA
```
```
CrosswalkLightOneWestB
```

### Crosswalk Buttons

Eight interaction parts, two per side. Name them:
```
CrosswalkButtonOneSouthA
```
```
CrosswalkButtonOneSouthB
```
```
CrosswalkButtonOneNorthA
```
```
CrosswalkButtonOneNorthB
```
```
CrosswalkButtonOneEastA
```
```
CrosswalkButtonOneEastB
```
```
CrosswalkButtonOneWestA
```
```
CrosswalkButtonOneWestB
```

---

## 4. Check It Worked

Reload the addon and look at the console.

If everything matched you will see:
```
[TL] All parts found. :D
```

If a name is wrong you will see:
```
[TL] Missing: SomeName, AnotherName
```
Fix the spelling on those parts (capitals count) and reload.

---

## 5. Change the Timing

The timings are at the top of the script, in seconds. Change them to taste:
```
MIN_GREEN  = 4
AMBER_TIME = 2
PED_GREEN  = 7
ALL_RED    = 1.5
```

---

## Common Problems

- The console says `Missing`. Those names do not match your parts. Check spelling and capital letters.
- One crosswalk light stays off. Two parts share a name. Rename one so every name is unique.
- Lights never change color. The light is not a normal Part. Rebuild it as a Part.
- A button does nothing. It is not set as an interaction part.
- Nothing runs, or it stops after ten seconds. The addon is set to "Run Once". Make it saved.

---

## Adding a Second Intersection?

Use a separate copy of the script and rename everything from `One` to `Two`, both in the map and in the lists at the top of the script.

---

## Need Help?

If something is broken, incorrect, or unclear, please report it. :]

Email:
r3d@itsr3dguy.dev

Discord:
ItsR3dGuy
