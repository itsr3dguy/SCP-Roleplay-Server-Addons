### Difficulty to set up: Easy [🟢]

# Setup - Trash 'n Craft

Players dig through trash bins to find parts, then combine those parts at a crafting table to build a Pistol. Some searches turn up a Stinky Boot instead.

---

## 1. Add the Script

Open the **Server Addons** menu and create a new addon.

Copy everything from [script.lua](script.lua), paste it in, and save.

---

## 2. Build the Parts

The script uses interaction parts. Build them, then rename each one to match exactly. Capital letters matter.

### Crafting Table

One interaction part where players build the Pistol:
```
CraftingTable
```

### Trash Bins

One interaction part for each bin players can search. Number them:
```
TrashBin1
```
```
TrashBin2
```
```
TrashBin3
```
Add as many as you want. Any part whose name starts with `TrashBin` works.

---

## 3. Try It

Search a trash bin to collect parts. When you have all five (Gun Barrel, Magazine, Gunpowder, Spring, and Duct Tape), use the Crafting Table to turn them into a Pistol.

Each bin has a short cooldown per player, so you cannot spam one bin.

---

## 4. Change the Settings

The settings are at the top of the script:
```
SearchCooldown   = 30    how long before a player can search the same bin again (seconds)
StinkyBootChance = 0.05  chance of pulling a Stinky Boot instead of a part (0.05 = 5 percent)
```

You can also edit the recipe and the list of parts that bins can drop, both near the top of the script.

---

## Common Problems

- Nothing happens at a bin or table. The part is not set as an interaction part.
- A bin does nothing. Its name does not start with `TrashBin`. Check the spelling and capitals.
- Crafting does nothing. You do not have all five parts yet, or a part name in the recipe does not match.

---

## Need Help?

If something is broken, incorrect, or unclear, please report it. :]

Email:
r3d@itsr3dguy.dev

Discord:
ItsR3dGuy
