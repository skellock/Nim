discard """
  output: '''[127, 127, 0, 255]
[127, 127, 0, 255]
'''

  nimout: '''caught Exception'''
"""

import os, osproc

# template getScriptDir(): string =
#   parentDir(instantiationInfo(-1, true).filename)

# block gorge:
#   const
#     execName = when defined(windows): "tgorge.bat" else: "./tgorge.sh"
#     relOutput = gorge(execName)
#     absOutput = gorge(getScriptDir() / execName)

#   doAssert relOutput == "gorge test"
#   doAssert absOutput == "gorge test"

static:
  var sawProcessError = false
  try:
    discard gorgeEx("./tgorge_404.sh")
  except:
    echo "yay"

  # doAssert sawProcessError == true

# block gorgeEx:
#   const
#     execName = when defined(windows): "tgorgeex.bat" else: "./tgorgeex.sh"
#     res = gorgeEx(execName)
#   doAssert res.output == "gorgeex test"
#   doAssert res.exitCode == 1
