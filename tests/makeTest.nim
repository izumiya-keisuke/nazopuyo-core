import os
import strformat
import strutils
import sugar

when isMainModule:
  const
    # file content
    TripleQuote = "\"\"\""
    Matrix = "<MATRIX>"
    FileContentTemplate = &"""
discard {TripleQuote}
  action: "run"
  targets: "c cpp js"
  matrix: "{Matrix}"
{TripleQuote}

import ./main

main()
"""

    # memory management flags
    MmSeq = @["refc", "orc", "arc"]

  let
    matrixSeq = collect:
      for mm in MmSeq:
         &"--mm:{mm}"
    fileContent = FileContentTemplate.replace(Matrix, matrixSeq.join "; ")

  for categoryDir in (currentSourcePath().parentDir / "*").walkDirs:
    let f = (categoryDir / "test.nim").open fmWrite
    defer: f.close

    f.write fileContent
