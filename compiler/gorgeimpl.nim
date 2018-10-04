#
#
#           The Nim Compiler
#        (c) Copyright 2017 Andreas Rumpf
#
#    See the file "copying.txt", included in this
#    distribution, for details about the copyright.
#

## Module that implements ``gorge`` for the compiler.

import msgs, std / sha1, os, osproc, streams, strutils, options,
  lineinfos, pathutils

proc readOutput(p: Process): (string, int) =
  result[0] = ""
  var output = p.outputStream
  while not output.atEnd:
    result[0].add(output.readLine)
    result[0].add("\n")
  if result[0].len > 0:
    result[0].setLen(result[0].len - "\n".len)
  result[1] = p.waitForExit

proc opGorge*(cmd, input, cache: string, info: TLineInfo; conf: ConfigRef): (string, int) =
  ## Runs an external `cmd` feeding `input` into stdin (optional) and returning
  ## the command's output (`stdout` + `stdin`) and exit code.
  ##
  ## If a `cache` key is provided, any existing successful results (exit code
  ## 0) will be returned in lieu of executing the command.
  ##
  ## Expect a raised `ProcessError` should the program exiting with non-zero
  ## exit codes.
  ##
  ## Expect a raised `OSError` should the program not be found/executed or
  ## finish with a non-zero exit code.
  ##
  ## Expect an `IOError` should something horribly go awry while executing that
  ## isn't a process terminating properly.

  # return the cached version (if we want it & we have it)
  var cacheFilename: string
  if cache.len > 0:# and optForceFullMake notin gGlobalOptions:
    let h = secureHash(cmd & "\t" & input & "\t" & cache)
    cacheFilename = toGeneratedFile(conf, AbsoluteFile("gorge_" & $h), "txt").string
    var f: File
    if open(f, cacheFilename):
      result = (f.readAll, 0)
      f.close
      return

  let workingDir = parentDir(toFullPath(conf, info))

  # fire up the process -- intentially bubbling up errors (see #1994)
  var p = startProcess(cmd, workingDir,
                       options={poEvalCommand, poStdErrToStdOut})

  # pass along stdin if we were given it
  if input.len != 0:
    p.inputStream.write(input)
    p.inputStream.close()

  # block until the process ends
  result = p.readOutput

  if result[1] == 0:
    # cache successful runs if we were asked
    if cache.len > 0:
      try:
        writeFile(cacheFilename, result[0])
      except IOError, OSError:
        # ignore corner case of cache writing failures
        discard
  else:
    raiseProcessError(cmd & " ended with exit code " & $result[1], result[1], result[0])
