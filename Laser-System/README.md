> By using this you agree to the [OUL License v1.1](../license.md) in the root folder. Please read it.

### Difficulty to set up: Very Easy [🟢👶]

# Setup - Laser System

A laser grid with a button. Press the button to turn the lasers on or off. While active, the lasers kill anyone who touches them. You can also lock the button behind a keycard level.

---

## 1. Add the Script

Open the **Server Addons** menu and create a new addon.

Copy everything from [script.lua](script.lua), paste it in, and save.

---

## 2. Build the Parts

The script finds parts by name, so every name must match **exactly**. Capital letters matter.

### Lasers

One Part for each laser beam. Number them starting from one, with no gaps:
```
Laser1
```
```
Laser2
```
```
Laser3
```
Add as many as you want. The script stops looking at the first missing number, so do not skip any.

### Button

One interaction part to toggle the lasers:
```
LaserButton
```

---

## 3. Try It

Press the button to switch the lasers on. They become more visible and will kill anyone who walks into them. Press again to turn them off.

When it loads you will see `Lasers found: X` so you can confirm it picked up all your laser parts.

---

## 4. (Optional) Require a Keycard

By default anyone can press the button. To lock it, set `RequiredKeycard` at the top of the script to one of these:
```
L1
```
```
L2
```
```
L3
```
```
L4
```
```
O5
```
Leave it empty ("") for no keycard requirement. If someone without the right level presses the button, it flickers red to deny them.

---

## Common Problems

- `Lasers found: 0`. Your laser parts are not named `Laser1`, `Laser2`, and so on. Check spelling and capitals.
- Some lasers do nothing. You skipped a number. The script stops at the first gap, so keep them in order with no missing numbers.
- The button does nothing. It is not set as an interaction part.
- Lasers never kill. They are turned off. Press the button to activate them.

---

## Need Help?

If something is broken, incorrect, or unclear, please report it. :]

Email:
r3d@itsr3dguy.dev

Discord:
ItsR3dGuy
