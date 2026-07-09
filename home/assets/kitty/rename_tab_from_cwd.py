from pathlib import PurePosixPath

from kittens.tui.handler import result_handler
from kitty.boss import Boss


def main(args: list[str]) -> None:
    pass


@result_handler(no_ui=True)
def handle_result(
    args: list[str], answer: str, target_window_id: int, boss: Boss
) -> None:
    tab = boss.active_tab
    if tab is None:
        return

    cwd = tab.get_cwd_of_active_window()
    if not cwd:
        return

    segments = PurePosixPath(cwd).parts[1:]  # strip leading "/"
    if len(segments) >= 2:
        title = f"{segments[-2]}/{segments[-1]}"
    elif segments:
        title = segments[0]
    else:
        title = "/"

    tab.set_title(title)
