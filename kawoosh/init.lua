-- On Windows only: a clock on the title bar's right (the taskbar is hidden
-- there), and nu for the terminal's shell.
if kawoosh.os == "windows" then
  kawoosh.opt("status.clock", "%H:%M")
  kawoosh.opt("terminal.shell", "nu")
end

-- clangd finds Homebrew's headers (raylib) where a project has no
-- compile_commands.json. `brew --prefix` runs in the background, so
-- startup does not wait on it; without brew nothing is set.
pcall(kawoosh.spawn, { "brew", "--prefix" }, {
  on_done = function(text, code)
    local prefix = code == 0 and text and text:match("^%s*(.-)%s*$")
    if prefix and prefix ~= "" and kawoosh.fs.is_dir(prefix .. "/include") then
      kawoosh.opt("lsp.c.init", { fallbackFlags = { "-I" .. prefix .. "/include" } })
    end
  end,
})
