-- A clock on the title bar's right, on Windows only (the taskbar is hidden there).
if kawoosh.os == "windows" then
  kawoosh.opt("status.clock", "%H:%M")
end
