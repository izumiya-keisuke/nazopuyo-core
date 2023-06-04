# Package

version       = "0.1.1"
author        = "Keisuke Izumiya"
description   = "Nazo Puyo Library"
license       = "Apache-2.0 OR MPL-2.0"

srcDir        = "src"
installExt    = @["nim"]


# Dependencies

requires "nim >= 1.6.12"

requires "https://github.com/izumiya-keisuke/puyo-core >= 0.2.1"


# Tasks

import os
import strformat

task test, "Test":
  let mainFile = "./src/nazopuyo_core.nim".unixToNativePath
  exec &"nim doc --project --index {mainFile}"
  rmDir "./src/htmldocs".unixToNativePath

  exec "testament all"