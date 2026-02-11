# ZMK Config for TOTEM Keyboard

This is a ZMK firmware configuration for the TOTEM split keyboard by GEIGEIGEIST. The TOTEM is a 38-key column-staggered split keyboard designed for the Seeeduino XIAO BLE controller.

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
# Clone ZMK
git clone https://github.com/zmkfirmware/zmk.git
cd zmk

# Initialize west workspace
west init -l app/
west update

# Build left half
west build -s app -b seeeduino_xiao_ble -- -DSHIELD=totem_left -DZMK_CONFIG="/path/to/zmk-config-robert/config"

# Build right half
west build -s app -b seeeduino_xiao_ble -- -DSHIELD=totem_right -DZMK_CONFIG="/path/to/zmk-config-robert/config"
```

## Flashing Firmware

1. Connect the XIAO BLE via USB
2. Double-tap the reset button (enters bootloader, appears as USB drive)
3. Copy the `.uf2` file to the drive
4. The board will automatically reboot

Flash `totem_left-seeeduino_xiao_ble-zmk.uf2` to the left half and `totem_right-seeeduino_xiao_ble-zmk.uf2` to the right half.

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
                &kp A  &kp R  &kp S  &kp T  &kp G      &kp M  &kp N  &kp E  &kp I  &kp O
        &kp ESC &kp Z  &kp X  &kp C  &kp D  &kp V      &kp K  &kp H  &kp COMMA &kp DOT &kp FSLH &kp SQT
                              &kp LGUI &mo NAV &kp SPACE   &kp RET &mo SYM &kp BSPC
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
| BASE | 0 | Default | Colemak DH-M |
| FUN | 1 | Hold left thumb outer | Numbers (left), Function keys (right) |
| NAV | 2 | Hold Space (left thumb) or middle right thumb | Mac navigation, window/tab management |
| SYM | 3 | Hold right thumb inner | Symbols and punctuation |
| NUM | 4 | Hold left thumb middle | Numpad (right), arrows (left) |
| MEDIA | 5 | Hold O key | Mouse, media, volume, Bluetooth |
| NAVWIN | 6 | One-shot from NAV (G position) | Alt+key shortcuts for Raycast window switching |
| NAVLH | 7 | Toggle from FUN | Left-hand navigation for one-handed use |

### BASE Layer (Colemak DH-M)

```
        Q    W    F    P    B          J    L    U    Y    ;
        A    R    S    T    G          M    N    E    I    O*
ESC/CTL Z    X    C    D    V          K    H    ,    .    /   ENT
                FUN  NUM  SPC*       SHFT  NAV  SYM

* O = tap for O, hold for MEDIA layer
* SPC = tap for Space, hold for NAV layer
```

### FUN Layer (Numbers + Function Keys)

```
        1    2    3    4    5         NAVLH F7   F8   F9   F12
       GUI  ALT  CTL  SHF   _         PSCR  F4   F5   F6   F11
  _     6    7    8    9    0         PAUS  F1   F2   F3   F10   _
                  _    _    _           _  CAPS   _
```

### NAV Layer (Mac Navigation)

```
       SW_W PV_T CL_W NX_T SW_A        PGUP HOME  UP  END  DWRD
       GUI  ALT  CTL  SHF NAVWN        PGDN LEFT DOWN RGHT  SPC
  _    UNDO CUT  COPY PSTE REDO        ESC  BSPC ENT  TAB  DEL   _
                MKLNK  _  NWTAB        ENT  BSPC  _

Legend:
- SW_W = Switch Window (Cmd+`)
- PV_T/NX_T = Prev/Next Tab (Cmd+Shift+[/])
- CL_W = Close Window (Cmd+W)
- SW_A = Switch App (Cmd+Tab)
- NAVWN = One-shot NAVWIN layer
- DWRD = Delete Word (Alt+Backspace)
- MKLNK = Make Link (Cmd+K)
- NWTAB = New Tab (Cmd+T)
- UNDO/CUT/COPY/PSTE/REDO = Cmd+Z/X/C/V/Shift+Z
```

### SYM Layer (Symbols)

```
        !    @    #    $    %          ;    :    =    +    -
        `    <    {    [    (          )    ]    }    >    '
  _     ~    ^    &    *    _          \    |    /    ?    "    _
                  _    _    _         BSPC DEL   _
```

### NUM Layer (Numpad)

```
       TAB  HOME  UP  END  PGUP        /    7    8    9    *
       GUI  ALT  CTL  SHF  PGDN        -    4    5    6    +
  _     _   LEFT DOWN RGHT  _          0    1    2    3    =    _
                  .    ,    _         ENT  BSPC  .
```

### MEDIA Layer (Mouse + Media + Bluetooth)

```
       BOOT BT0  BT1  BT2  BT3        SCRL↑ PREV MS_U NEXT PSCR
       GUI  ALT  CTL  SHF  BT4        SCRL↓ MS_L MS_D MS_R BRI+
  _   BTCLR  _    _    _    _         MUTE VOL- PLAY VOL+ BRI-  _
                  _    _    _         LCLK RCLK MCLK

- BOOT = Bootloader mode (for flashing)
- BT0-4 = Bluetooth profile select
- BTCLR = Clear current BT profile
- MS_U/D/L/R = Inertia mouse movement (QMK-style momentum)
- SCRL↑/↓ = Mouse scroll
- LCLK/RCLK/MCLK = Mouse buttons
```

### NAVWIN Layer (Window Switching)

One-shot layer for Raycast-style Alt+key window switching. Enter from NAV layer by tapping G position, then press a key to send Alt+that key.

```
       A+Q  A+W  A+F  A+P  A+B        A+J  A+7  A+8  A+9  A+'
       GUI  ALT  CTL  SHF   _         A+M  A+4  A+5  A+6  A+O
  _    A+Z  A+X  A+C  A+D  A+V        A+K  A+1  A+2  A+3  A+/   _
                  _    _    _           _    _    _

A+key = Alt+key (for Raycast window shortcuts)
```

### NAVLH Layer (Left-Hand Navigation)

Toggle layer for one-handed navigation while using mouse with right hand. Toggle on/off from FUN layer (top-right key).

```
       TOG  HOME  UP  END  PGUP         _    _    _    _    _
       SPC  LEFT DOWN RGHT PGDN         _   SHF  CTL  ALT  GUI
  _    DEL  TAB  ENT  BSPC ESC          _    _    _    _    _    _
                TOG  TOG   _          ENT  BSPC  _

TOG = Toggle back to BASE layer
```

## Combos

| Combo | Keys | Output | Notes |
|-------|------|--------|-------|
| Q+W | 0, 1 | Escape | Top left corner |
| N+E+I | 16, 17, 18 | Sticky Cmd | Right home row roll |
| Comma+Dot | 28, 29 | Semicolon | |
| H+Comma | 27, 28 | Hyphen | |
| X+D | 22, 24 | Sticky Ctrl | Left hand |
| D+H | 24, 27 | Sticky Ctrl | Cross-hand |
| Z+D | 21, 24 | Tab | |
| W+P (NAV) | 1, 3 | Select All (Cmd+A) | Only active in NAV layer |

## Resources

- [ZMK Documentation](https://zmk.dev/docs)
- [ZMK Keycodes Reference](https://zmk.dev/docs/codes)
- [ZMK Behaviors](https://zmk.dev/docs/behaviors)
- [TOTEM Keyboard GitHub](https://github.com/GEIGEIGEIST/TOTEM)
- [Seeeduino XIAO BLE](https://wiki.seeedstudio.com/XIAO_BLE/)
