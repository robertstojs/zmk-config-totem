# ZMK Config for TOTEM Keyboard

This is a ZMK firmware configuration for the TOTEM split keyboard by GEIGEIGEIST. The TOTEM is a 38-key column-staggered split keyboard designed for the Seeeduino XIAO BLE controller.

## Important

The layer diagrams, combo table, and activation descriptions in this file must always be checked against `config/totem.keymap` before relying on them. If they differ, the keymap is the source of truth — update this file to match.

## Git Commits

Use semantic commits with a brief summary only. No description body, no signatures.

```
feat: add inertia mouse module
fix: correct BLE pairing issue
refactor: simplify NAV layer bindings
docs: update layer documentation
```

## Project Structure

```
zmk-config-robert/
├── .github/workflows/build.yml    # GitHub Actions build workflow
├── build.yaml                     # Defines which board/shield combos to build
├── config/
│   ├── west.yml                   # West manifest (pulls ZMK firmware)
│   ├── totem.conf                 # Global keyboard configuration
│   ├── totem.keymap               # YOUR KEYMAP - edit this file
│   └── boards/shields/totem/      # Shield definition files
│       ├── Kconfig.defconfig      # Default Kconfig values
│       ├── Kconfig.shield         # Shield detection logic
│       ├── totem.dtsi             # Base device tree (matrix, pins)
│       ├── totem.zmk.yml          # ZMK hardware metadata
│       ├── totem_left.overlay     # Left half GPIO column pins
│       └── totem_right.overlay    # Right half GPIO column pins
```

## Building Firmware

### Via GitHub Actions (Recommended)

1. Push changes to GitHub
2. Go to Actions tab → latest workflow run
3. Download the `firmware` artifact (contains .uf2 files)

### Local Build

```bash
# Build left half (pristine)
west build -p -s zmk/app -b xiao_ble//zmk -- -DSHIELD=totem_left -DZMK_CONFIG="$(pwd)/config"

# Build right half (pristine)
west build -p -s zmk/app -b xiao_ble//zmk -- -DSHIELD=totem_right -DZMK_CONFIG="$(pwd)/config"

# Output: build/zephyr/zmk.uf2
# Copy to firmware/ folder after each build
```

## Flashing Firmware

1. Connect the XIAO BLE via USB
2. Double-tap the reset button (enters bootloader, appears as USB drive)
3. Copy the `.uf2` file to the drive
4. The board will automatically reboot

Flash `totem_left-xiao_ble-zmk.uf2` to the left half and `totem_right-xiao_ble-zmk.uf2` to the right half.

## Keymap Editing

Edit `config/totem.keymap` to customize your layout.

### Physical Layout Reference (38 keys)

```
╭──────────────────────────────────╮ ╭──────────────────────────────────╮
│       0    1    2    3    4      │ │      5    6    7    8    9       │
│      10   11   12   13   14      │ │     15   16   17   18   19       │
│ 20   21   22   23   24   25      │ │     26   27   28   29   30   31  │
╰───────────────╮ 32   33   34     │ │     35   36   37 ╭───────────────╯
                ╰──────────────────╯ ╰──────────────────╯
```

- Keys 20 and 31 are the outer pinky keys on the bottom row
- Keys 32-34 (left thumb) and 35-37 (right thumb) are the thumb cluster

### Layer Definition

```dts
layer_name {
    bindings = <
                &kp Q  &kp W  &kp F  &kp P  &kp B      &kp J  &kp L  &kp U  &kp Y  &kp SEMI
                &mt LGUI A &mt LALT R &mt LCTRL S &mt LSHFT T &kp G   &kp M  &mt RSHFT N &mt RCTRL E &mt RALT I &mt RGUI O
        &none   &kp Z  &kp X  &kp C  &kp D  &kp V      &kp K  &kp H  &kp COMMA &kp DOT &kp FSLH &none
                              &lt MEDIA ESC &lt FUN TAB &ltr NAV SPACE   &lt SYM RET &ltr NUM BSPC &kp DEL
    >;
};
```

Note: Row 3 (bottom alpha row) has 12 keys (6 per side, including outer pinky keys).

### Common Keycodes

| Category | Examples |
|----------|----------|
| Letters | `&kp A` through `&kp Z` |
| Numbers | `&kp N0` through `&kp N9` |
| Modifiers | `&kp LSHFT`, `&kp LCTRL`, `&kp LALT`, `&kp LGUI` |
| Navigation | `&kp LEFT`, `&kp RIGHT`, `&kp UP`, `&kp DOWN` |
| Functions | `&kp F1` through `&kp F12` |
| Media | `&kp C_VOL_UP`, `&kp C_VOL_DN`, `&kp C_PP`, `&kp C_NEXT` |
| Symbols | `&kp EXCL`, `&kp AT`, `&kp HASH`, `&kp AMPS` |
| Brackets | `&kp LPAR`, `&kp RPAR`, `&kp LBKT`, `&kp RBKT`, `&kp LBRC`, `&kp RBRC` |
| Special | `&kp SPACE`, `&kp RET`, `&kp TAB`, `&kp BSPC`, `&kp DEL`, `&kp ESC` |
| Transparent | `&trans` (passes through to lower layer) |
| None | `&none` (does nothing) |

### Behaviors

**Mod-Tap** - Modifier when held, key when tapped:
```dts
&mt LSHFT A    // Shift when held, 'A' when tapped
```

**Layer-Tap** - Layer when held, key when tapped:
```dts
&lt NAV SPACE  // NAV layer when held, Space when tapped
```

**Momentary Layer** - Activate layer while held:
```dts
&mo NAV        // Hold for NAV layer
```

**Toggle Layer** - Toggle layer on/off:
```dts
&tog NAV       // Tap to toggle NAV layer
```

**Layer-Tap with Repeat** - Layer when held, key when tapped, auto-repeat on quick tap-then-hold:
```dts
&ltr NAV SPACE // NAV layer when held, Space when tapped, repeat Space on tap-then-hold
```

**Sticky Key** - One-shot modifier:
```dts
&sk LSHFT      // Next keypress will be shifted
```

### Combos

Trigger a binding when multiple keys are pressed simultaneously:

```dts
combos {
    compatible = "zmk,combos";
    combo_esc {
        timeout-ms = <50>;
        key-positions = <0 1>;      // Key indices from layout
        bindings = <&kp ESC>;
    };
};
```

### Macros

Send a sequence of keypresses:

```dts
macros {
    my_macro: my_macro {
        compatible = "zmk,behavior-macro";
        #binding-cells = <0>;
        bindings = <&kp H &kp E &kp L &kp L &kp O>;
    };
};
```

Use in keymap: `&my_macro`

## Configuration Options

Edit `config/totem.conf` for global settings:

```ini
# Enable USB logging for debugging
CONFIG_ZMK_USB_LOGGING=y

# Increase Bluetooth TX power
CONFIG_BT_CTLR_TX_PWR_PLUS_8=y

# Deep sleep timeout (ms) - saves battery
CONFIG_ZMK_IDLE_SLEEP_TIMEOUT=900000

# Debounce settings
CONFIG_ZMK_KSCAN_DEBOUNCE_PRESS_MS=5
CONFIG_ZMK_KSCAN_DEBOUNCE_RELEASE_MS=5
```

## Bluetooth

### Split Keyboard Pairing

The left half is the "central" and communicates with the host computer. The right half is the "peripheral" and only communicates with the left half.

1. Flash both halves
2. Power on both halves near each other
3. They will automatically pair with each other
4. Pair the left half with your computer

### Managing Bluetooth Profiles

The keyboard supports multiple Bluetooth profiles (devices):

```dts
&bt BT_SEL 0   // Select profile 0
&bt BT_SEL 1   // Select profile 1
&bt BT_CLR     // Clear current profile pairing
```

### Troubleshooting Bluetooth

If halves won't connect to each other:
1. Flash the settings reset firmware to both halves (if available)
2. Or clear Bluetooth by holding the BT_CLR key for 5+ seconds on both halves
3. Re-flash the regular firmware

## Current Keymap Layers

| Layer | Index | Activation | Purpose |
|-------|-------|------------|---------|
| BASE | 0 | Default | Colemak DH-M with GACS home row mods |
| FUN | 1 | Hold Tab (left middle thumb) | Text editing (Mac shortcuts) + F-keys |
| NAV | 2 | Hold Space (left inner thumb) | Aerospace tiling WM (focus, layout, workspaces) |
| SYM | 3 | Hold Enter (right inner thumb) | Symbols and punctuation |
| NUM | 4 | Hold Bksp (right middle thumb) | Numpad (right), cursor nav (left) |
| MEDIA | 5 | Hold Esc (left outer thumb) | Mouse, media, volume, Bluetooth |

### BASE Layer (Colemak DH-M)

```
         Q     W     F     P     B          J     L     U     Y     ;
        A/GUI R/ALT S/CTL T/SHF  G          M    N/SHF E/CTL I/ALT O/GUI
  ___    Z     X     C     D     V          K     H     ,     .     /    ___
                   ESC/M TAB/F SPC/N      ENT/S BSP/N  DEL

- Home row mods: GACS (GUI, ALT, CTL, SHF) mirrored on both sides
- ESC/M = Esc tap, MEDIA hold
- TAB/F = Tab tap, FUN hold
- SPC/N = Space tap, NAV hold (auto-repeat on quick tap-then-hold)
- ENT/S = Enter tap, SYM hold
- BSP/N = Bksp tap, NUM hold (auto-repeat on quick tap-then-hold)
- DEL = plain Delete
```

### FUN Layer (Text Editing + F-keys)

Hold Tab (left middle thumb). Mac shortcuts left, F-keys right. Left home = GACST.

```
       SW_WN PV_TB CL_WN NX_TB SW_AP      F12  F7   F8   F9   ___
        GUI  ALT   CTL   SHF   TAB        F11  F4   F5   F6   PSCR
  ___  UNDO  CUT  COPY  PASTE REDO        F10  F1   F2   F3   PAUS  ___
                   ___  (hld)  ___         ___  CAPS  ___

Legend:
- SW_WN = Switch Window (Cmd+`)
- PV_TB/NX_TB = Prev/Next Tab (Cmd+Shift+[/])
- CL_WN = Close Window (Cmd+W)
- SW_AP = Switch App (Cmd+Tab)
- UNDO/CUT/COPY/PASTE/REDO = Cmd+Z/X/C/V/Shift+Z
- F-keys in numpad grid matching NUM layer positions
- F10/F11/F12 ascending on index column
```

### NAV Layer (Aerospace Tiling WM)

Hold Space (left inner thumb). Rows organized by theme. No GACST — all bindings are pre-baked Alt combos.

```
       A+TAB A+D  A+RET A+F  A+W        DEL  A+7  A+8  A+9  ___
       A+H←  A+J↓ A+K↑  A+L→ A+E       BSPC A+4  A+5  A+6  ___
 A+SR  A+S   A+V   A+B  A+SC  A+R       ESC  A+1  A+2  A+3  ___  ___
                  A+SF  A+SB (hld)      SHFT BSPC  ENT

Left side rows:
- Top: Launch/switch — workspace toggle, launcher, terminal, fullscreen, ultrawide
- Home: Focus (vim) — H/J/K/L directional + E layout toggle
- Bottom: Arrangement — reload(outer), accordion, join↓, join→, close, resize(inner)

Right side:
- Inner index: DEL/BSPC/ESC
- Numpad grid: A+1–9 workspace switching

Legend:
- A+key = Alt+key (Aerospace shortcut)
- A+SC = Alt+Shift+C (close window, on index for easy reach)
- A+SR = Alt+Shift+R (reload config, on outer pinky for safety)
- A+R = Resize mode (release NAV to use h/j/k/l/esc)
- A+SF = Alt+Shift+Space (float toggle)
- A+SB = Alt+Shift+B (balance sizes)
- SHFT on right thumb enables move: SHFT+A+1–9 = move window to workspace
```

### SYM Layer (Symbols)

Hold Enter (right inner thumb). Two-handed symbol layout.

```
        !    @    #    $    %          ;    :    =    +    -
        `    <    {    [    (          )    ]    }    >    '
  ___   ~    ^    &    *    _          \    |    /    ?    "   ___
                  _    _    _        (hld) DEL   _
```

### NUM Layer (Numpad)

Hold Bksp (right middle thumb). Numpad right, cursor nav left. Left home = GACST.

```
       TAB  HOME  UP   END  PGUP        /    7    8    9    *
       GUI  ALT   CTL  SHF  TAB         -    4    5    6    +
  ___  ___  LEFT  DOWN RGHT ___         0    1    2    3    =   ___
                   .    ,    _         ENT (hld)  .
```

### MEDIA Layer (Mouse + Media + Bluetooth)

Hold Esc (left outer thumb). Mouse + media right, BT + GACST left.

```
       BOOT BT0  BT1  BT2  BT3        SCRL↑ LCLK MS_U RCLK MCLK
       GUI  ALT  CTL  SHF  BT4        SCRL↓ MS_L MS_D MS_R PSCR
  ___ BTCLR ___  ___  ___  ___        MUTE  VOL- VOL+ BRI- BRI+ ___
                (hld) ___  ___        PREV  PLAY NEXT

- BOOT = Bootloader mode (for flashing)
- BT0-4 = Bluetooth profile select
- BTCLR = Clear current BT profile
- MS_U/D/L/R = Inertia mouse movement (momentum-based)
- SCRL↑/↓ = Mouse scroll with acceleration
- LCLK/RCLK flank MS_U for spatial intuitiveness
- MCLK = Middle click
- PREV/PLAY/NEXT on thumb cluster
```

## Combos

| Combo | Keys | Output | Notes |
|-------|------|--------|-------|
| N+E+I | 16, 17, 18 | Sticky Cmd | Right home row roll |
| Comma+Dot | 28, 29 | Semicolon | |
| H+Comma | 27, 28 | Hyphen | |
| Z+D | 21, 24 | Tab | |

## Resources

- [ZMK Documentation](https://zmk.dev/docs)
- [ZMK Keycodes Reference](https://zmk.dev/docs/codes)
- [ZMK Behaviors](https://zmk.dev/docs/behaviors)
- [TOTEM Keyboard GitHub](https://github.com/GEIGEIGEIST/TOTEM)
- [Seeeduino XIAO BLE](https://wiki.seeedstudio.com/XIAO_BLE/)
