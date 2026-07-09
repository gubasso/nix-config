# Vulkan ICD Disable Directory

This directory disables Vulkan driver discovery for Chromium-family browsers.

## How it works

- VK_DRIVER_FILES points here (directory with no valid ICDs)
- VK_ICD_FILENAMES points to disabled.json (stub manifest)

The stub manifest (disabled.json) is valid ICD JSON that references a nonexistent library. The
Vulkan loader:

1. Parses the manifest successfully
2. Attempts to load /nonexistent/vulkan-disabled-by-dotfiles.so
3. Fails (file not found), logs a warning, continues
4. Finds no working drivers → Vulkan unavailable

## Why

Vulkan compositor is incompatible with NVIDIA+Wayland on Chromium. Disabling Vulkan prevents
Dawn/WebGPU from probing unavailable backends.

## Reference

<https://github.com/KhronosGroup/Vulkan-Loader/blob/main/docs/LoaderDriverInterface.md>
