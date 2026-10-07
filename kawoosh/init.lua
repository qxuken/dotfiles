-- On Windows only: a clock on the title bar's right (the taskbar is hidden
-- there), and nu for the terminal's shell.
if kawoosh.os == "windows" then
  kawoosh.opt("status.clock", "%H:%M")
  kawoosh.opt("terminal.shell", "nu")
end
