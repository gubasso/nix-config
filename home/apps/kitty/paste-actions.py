def filter_paste(text: str) -> str:
    """Strip trailing newlines only, preserving internal newlines."""
    return text.rstrip("\n")
