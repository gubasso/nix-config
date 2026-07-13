# KDE Plasma session: KDE-specific shared home config. Loaded only on hosts
# whose `hostSettings.desktop == "kde"` (see modules/home/common.nix).
#
# Intentionally lean: Plasma manages its own compositor, notifications, hotkeys,
# and screen locking (the dwm equivalents in ./dwm.nix are deliberately absent
# here), and KWallet/pinentry-qt come from ../keyring.nix. Cross-desktop apps
# come from ./apps.nix. Host-specific KDE tweaks live in the consumer's
# hosts/<host>/home.nix. This module is the seam for future KDE-shared config.
_:

{
}
