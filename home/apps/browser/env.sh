# shellcheck shell=bash
# Intel VA-API configuration for hybrid Intel+NVIDIA systems
# Ensures VA-API uses Intel iHD driver for hardware video decode

# Intel default GPU (hybrid-safe)
export DRI_PRIME=0

# VA-API: force Intel iHD backend
export LIBVA_DRIVER_NAME=iHD

# Prevent accidental NVIDIA PRIME-offload mode
unset __NV_PRIME_RENDER_OFFLOAD
unset __GLX_VENDOR_LIBRARY_NAME
unset __VK_LAYER_NV_optimus

# Disable all Vulkan drivers (blocks Dawn/WebGPU Vulkan enumeration)
# Context: Vulkan compositor is incompatible with NVIDIA+Wayland and already errors at startup;
#          disabling drivers prevents Dawn/WebGPU from probing unavailable backends.
#
# Primary: VK_LOADER_DRIVERS_DISABLE (official filter, requires loader 1.3.234+)
#          Glob '*' matches all driver manifest filenames, cleanly disabling all ICDs.
#
# Fallback (older loaders that ignore DRIVERS_DISABLE):
#          VK_DRIVER_FILES  → directory with no valid manifests (modern loaders accept dirs)
#          VK_ICD_FILENAMES → stub manifest pointing to nonexistent .so (older loaders need file paths)
#          The loader parses the stub, fails to dlopen the library, and continues with zero drivers.
#
# Ref: https://github.com/KhronosGroup/Vulkan-Loader/blob/main/docs/LoaderDriverInterface.md
export VK_LOADER_DRIVERS_DISABLE='*'
export VK_DRIVER_FILES="${XDG_CONFIG_HOME:-$HOME/.config}/browser/vulkan/disabled-icd.d"
export VK_ICD_FILENAMES="${XDG_CONFIG_HOME:-$HOME/.config}/browser/vulkan/disabled-icd.d/disabled.json"

# Avoid broken libva overrides
unset LIBVA_DRIVERS_PATH
