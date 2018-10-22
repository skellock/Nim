discard """
  errormsg: "tgorgeex"
  errormsg: "ended with exit code 1"
  line: 10
  column: 16
"""

const
  execName = when defined(windows): "tgorgeex.bat" else: "./tgorgeex.sh"
  res = gorgeEx(execName)
