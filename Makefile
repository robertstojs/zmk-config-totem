# ZMK Firmware Build Makefile for Totem Keyboard

# Configuration
BOARD := xiao_ble//zmk
ZMK_DIR := zmk
ZMK_CONFIG := $(shell pwd)/config
FIRMWARE_DIR := firmware

# Build flags
BUILD_FLAGS := -DZMK_CONFIG=$(ZMK_CONFIG)

.PHONY: all ble dongle clean setup help

# Default target
all: ble

# === BLE MODE ===
# Left half connects directly to computer via Bluetooth
ble:
	@echo "Building BLE mode firmware..."
	@mkdir -p $(FIRMWARE_DIR)
	@rm -f $(FIRMWARE_DIR)/totem_dongle.uf2
	@echo "[1/2] Left half (central)..."
	cd $(ZMK_DIR) && west build -p -s app -b $(BOARD) -- -DSHIELD=totem_left $(BUILD_FLAGS)
	@cp $(ZMK_DIR)/build/zephyr/zmk.uf2 $(FIRMWARE_DIR)/totem_left.uf2
	@echo "[2/2] Right half (peripheral)..."
	cd $(ZMK_DIR) && west build -p -s app -b $(BOARD) -- -DSHIELD=totem_right $(BUILD_FLAGS)
	@cp $(ZMK_DIR)/build/zephyr/zmk.uf2 $(FIRMWARE_DIR)/totem_right.uf2
	@echo ""
	@echo "✓ BLE mode ready! Flash these to your keyboard:"
	@ls -lh $(FIRMWARE_DIR)/totem_left.uf2 $(FIRMWARE_DIR)/totem_right.uf2

# === DONGLE MODE ===
# USB dongle connects to computer, both halves connect to dongle
dongle:
	@echo "Building dongle mode firmware..."
	@mkdir -p $(FIRMWARE_DIR)
	@echo "[1/3] Dongle (USB central)..."
	cd $(ZMK_DIR) && west build -p -s app -b $(BOARD) -- -DSHIELD=totem_dongle $(BUILD_FLAGS)
	@cp $(ZMK_DIR)/build/zephyr/zmk.uf2 $(FIRMWARE_DIR)/totem_dongle.uf2
	@echo "[2/3] Left half (peripheral)..."
	cd $(ZMK_DIR) && west build -p -s app -b $(BOARD) -- -DSHIELD=totem_left_peripheral $(BUILD_FLAGS)
	@cp $(ZMK_DIR)/build/zephyr/zmk.uf2 $(FIRMWARE_DIR)/totem_left.uf2
	@echo "[3/3] Right half (peripheral)..."
	cd $(ZMK_DIR) && west build -p -s app -b $(BOARD) -- -DSHIELD=totem_right $(BUILD_FLAGS)
	@cp $(ZMK_DIR)/build/zephyr/zmk.uf2 $(FIRMWARE_DIR)/totem_right.uf2
	@echo ""
	@echo "✓ Dongle mode ready! Flash these:"
	@echo "  Dongle:     totem_dongle.uf2"
	@echo "  Left half:  totem_left.uf2"
	@echo "  Right half: totem_right.uf2"
	@ls -lh $(FIRMWARE_DIR)/*.uf2

# === UTILITIES ===
setup:
	@echo "Setting up ZMK build environment..."
	west init -l config/ 2>/dev/null || true
	west update
	@echo "✓ Setup complete!"

clean:
	@echo "Cleaning build artifacts..."
	@rm -rf $(ZMK_DIR)/build
	@rm -rf $(FIRMWARE_DIR)
	@echo "✓ Clean complete"

help:
	@echo "ZMK Totem Keyboard Build System"
	@echo ""
	@echo "Build modes (choose one):"
	@echo ""
	@echo "  make ble         BLE mode - left half connects to computer via Bluetooth"
	@echo "  make dongle      Dongle mode - USB dongle connects to computer"
	@echo ""
	@echo "Utilities:"
	@echo ""
	@echo "  make setup       Initial setup (clone ZMK)"
	@echo "  make clean       Remove build artifacts"
