from kittens.tui.handler import result_handler
from kitty.boss import Boss


def main(args: list[str]) -> None:
    # no UI: we only want handle_result()
    pass


@result_handler(no_ui=True)
def handle_result(
    args: list[str], answer: str, target_window_id: int, boss: Boss
) -> None:
    tab = boss.active_tab
    if tab is None:
        return

    # Toggle "zoom" by switching to stack and back (equivalent to toggle_layout stack)
    if tab.current_layout.name == "stack":
        tab.last_used_layout()
    else:
        tab.goto_layout("stack")

    # Make border/layout state deterministic after toggling
    try:
        tab.current_layout.must_draw_borders = True
    except Exception:
        pass

    # Critical: force a relayout so borders/focus cues re-apply immediately
    tab.relayout()
