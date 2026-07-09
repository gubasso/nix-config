"""Custom tab bar: clean tab names left, Neovim/shell status (from user vars) right."""

import os
import sys

from kitty.fast_data_types import Screen, get_boss
from kitty.tab_bar import (
    DrawData,
    ExtraData,
    TabBarData,
    as_rgb,
    draw_tab_with_separator,
)
from kitty.utils import color_as_int, log_error

_DEBUG = os.environ.get("KITTY_TABBAR_DEBUG") == "1"

# Shell producer (bash/.config/bash/rc.d/92-kitty-titlebar.bash) user vars.
_SHELL_CWD_VAR = "KITTY_SHELL_CWD"
_SHELL_BRANCH_VAR = "KITTY_SHELL_BRANCH"
_SHELL_DIRTY_VAR = "KITTY_SHELL_DIRTY"
_SHELL_EXIT_VAR = "KITTY_SHELL_EXIT_CODE"

# Neovim producer (nvim/.config/nvim/lua/core/kitty-titlebar.lua) user vars.
_NVIM_MARKER_VAR = "KITTY_NVIM"
_NVIM_MODE_VAR = "KITTY_NVIM_MODE"
_NVIM_BRANCH_VAR = "KITTY_NVIM_BRANCH"
_NVIM_DIFF_VAR = "KITTY_NVIM_DIFF"
_NVIM_STATUS_VAR = "KITTY_NVIM_STATUS"
_NVIM_FILE_VAR = "KITTY_NVIM_FILE"
_NVIM_MODIFIED_VAR = "KITTY_NVIM_MODIFIED"
_NVIM_PCT_VAR = "KITTY_NVIM_PCT"


def _nvim_from_user_vars(aw: object) -> dict[str, str] | None:
    user_vars = getattr(aw, "user_vars", None)
    if not isinstance(user_vars, dict):
        return None

    if not user_vars.get(_NVIM_MARKER_VAR):
        return None

    return {
        "mode": user_vars.get(_NVIM_MODE_VAR, ""),
        "branch": user_vars.get(_NVIM_BRANCH_VAR, ""),
        "diff": user_vars.get(_NVIM_DIFF_VAR, ""),
        "git_status": user_vars.get(_NVIM_STATUS_VAR, ""),
        "file": user_vars.get(_NVIM_FILE_VAR, ""),
        "modified": user_vars.get(_NVIM_MODIFIED_VAR, ""),
        "pct": user_vars.get(_NVIM_PCT_VAR, ""),
    }


def _shell_from_user_vars(aw: object) -> dict[str, str] | None:
    user_vars = getattr(aw, "user_vars", None)
    if not isinstance(user_vars, dict):
        return None

    cwd = user_vars.get(_SHELL_CWD_VAR, "")
    if not cwd:
        return None

    return {
        "cwd": cwd,
        "branch": user_vars.get(_SHELL_BRANCH_VAR, ""),
        "dirty": user_vars.get(_SHELL_DIRTY_VAR, ""),
        "exit_code": user_vars.get(_SHELL_EXIT_VAR, ""),
    }


def _text_width(text: str) -> int:
    try:
        from kitty.fast_data_types import wcswidth

        return wcswidth(text)
    except ImportError:
        return len(text)


def _render_right_segments(
    screen: Screen, draw_data: DrawData, segments: list[str]
) -> None:
    segments = [segment for segment in segments if segment]
    if not segments:
        return

    right_text = " " + " | ".join(segments) + " "
    width = _text_width(right_text)
    if width <= 0:
        return

    gap = screen.columns - screen.cursor.x - width
    if gap < 0:
        return

    bar_bg = as_rgb(color_as_int(draw_data.default_bg))

    # Blend inactive_fg 30% toward background for a more discrete status
    fg_int = color_as_int(draw_data.inactive_fg)
    bg_int = color_as_int(draw_data.default_bg)
    blend = 0.50
    status_fg = as_rgb(
        (int((fg_int >> 16 & 0xFF) * (1 - blend) + (bg_int >> 16 & 0xFF) * blend) << 16)
        | (int((fg_int >> 8 & 0xFF) * (1 - blend) + (bg_int >> 8 & 0xFF) * blend) << 8)
        | int((fg_int & 0xFF) * (1 - blend) + (bg_int & 0xFF) * blend)
    )

    # Reset cursor attributes before custom right-side render.
    screen.cursor.bold = False
    screen.cursor.italic = False

    # Fill gap between last tab and right status
    screen.cursor.bg = bar_bg
    screen.cursor.fg = bar_bg
    if gap > 0:
        screen.draw(" " * gap)

    # Draw right-aligned status
    screen.cursor.fg = status_fg
    screen.draw(right_text)


def _nvim_segments(nvim: dict[str, str]) -> list[str]:
    segments: list[str] = []

    if nvim["mode"]:
        segments.append(nvim["mode"])

    # Git segment: branch + buffer diff + repo status
    git_parts: list[str] = []
    if nvim["branch"]:
        git_parts.append(nvim["branch"])
    if nvim["diff"]:
        git_parts.append(nvim["diff"])
    if nvim["git_status"]:
        git_parts.append(nvim["git_status"])
    if git_parts:
        segments.append(" ".join(git_parts))

    file_status = nvim["file"]
    if nvim["modified"]:
        file_status += " " + nvim["modified"]
    segments.append(file_status)
    segments.append(nvim["pct"])
    return segments


def _shell_segments(shell: dict[str, str]) -> list[str]:
    segments: list[str] = []

    if shell["branch"]:
        git_part = shell["branch"]
        if shell["dirty"]:
            git_part += " " + shell["dirty"]
        segments.append(git_part)

    segments.append(shell["cwd"])

    if shell["exit_code"]:
        segments.append("E:" + shell["exit_code"])

    return segments


def draw_tab(
    draw_data: DrawData,
    screen: Screen,
    tab: TabBarData,
    before: int,
    max_title_length: int,
    index: int,
    is_last: bool,
    extra_data: ExtraData,
) -> int:
    # Tab name is the window title verbatim: producers now set a clean project label
    # (nvim) / cwd (shell), so no protocol stripping is needed here.
    end = draw_tab_with_separator(
        draw_data,
        screen,
        tab,
        before,
        max_title_length,
        index,
        is_last,
        extra_data,
    )

    # Right-side: render nvim/shell status from the active window's kitty user vars.
    if is_last and not extra_data.for_layout:
        try:
            boss = get_boss()
            at = boss.active_tab if boss else None
            aw = at.active_window if at else None
            if aw:
                nvim = _nvim_from_user_vars(aw)
                if nvim:
                    _render_right_segments(screen, draw_data, _nvim_segments(nvim))
                else:
                    shell = _shell_from_user_vars(aw)
                    if shell:
                        _render_right_segments(
                            screen, draw_data, _shell_segments(shell)
                        )
                    elif _DEBUG:
                        print(
                            f"[tab_bar] no user-var status: {aw.title!r}",
                            file=sys.stderr,
                        )
            elif _DEBUG:
                print("[tab_bar] no active window", file=sys.stderr)
        except Exception as exc:
            log_error(f"[tab_bar] right-status failed: {exc}")
            if _DEBUG:
                import traceback

                traceback.print_exc(file=sys.stderr)

    return end
