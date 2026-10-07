export def --wrapped python  [...args] { uv run -- python ...$args }
export def --wrapped python3 [...args] { uv run -- python ...$args }
export def --wrapped pip     [...args] { uv pip ...$args }
