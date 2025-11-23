export def python  [...args] { uv run -- python ...$args }
export def python3 [...args] { uv run -- python ...$args }
export def pip     [...args] { uv run -- python -m pip ...$args }
