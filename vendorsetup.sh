#!/bin/bash

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to display success message
success() {
    echo -e "${GREEN}$1${NC}"
}

# Function to display warning message
warning() {
    echo -e "${YELLOW}$1${NC}"
}

# Function to display error message
error() {
    echo -e "${RED}$1${NC}"
}

# Cleanup
rm -rf device/mediatek/sepolicy_vndr

# Clone repository function
clone_repo() {
    repo_url="$1"
    target_dir="$2"
    args="${@:3}"  # Capture additional arguments

    if [ -d "$target_dir" ]; then
        warning "Directory $target_dir already exists. Skipping clone."
    else
        echo -e "\n${GREEN}Cloning: $repo_url${NC}"
        git clone $args "$repo_url" "$target_dir" || { error "Failed to clone $repo_url"; }
        
        # After cloning, set branch if applicable
        if [[ "$args" == *"-b "* ]]; then
            branch=$(echo "$args" | grep -oP -- "-b \K[^ ]*")
            cd "$target_dir" || return
            git checkout "$branch"
            cd - || return
        fi
    fi
}

# Sepolicy
clone_repo "https://github.com/hannahmontanadeving/android_device_mediatek_sepolicy_vndr" "device/mediatek/sepolicy_vndr"
# Hardware
clone_repo "https://github.com/rosemary-devs/android_hardware_mediatek.git" "hardware/mediatek"
cline_repo "https://github.com/xiaomi-mediatek-devs/android_hardware_xiaomi" "hardware/xiaomi" "--depth=1 -b lineage-21"
clone_repo "https://github.com/rosemary-devs/android_vendor_xiaomi_rosemary.git" "vendor/xiaomi/rosemary"
clone_repo "https://github.com/hannahmontanadeving/android_kernel_xiaomi_mt6785" "kernel/xiaomi/rosemary" "--depth=1 --single-branch -b lineage-21"

# Set up builder username and hostname
export BUILD_USERNAME=Precommit
export BUILD_HOSTNAME=$(hostname)

# Display success message
success "Script execution completed successfully."
