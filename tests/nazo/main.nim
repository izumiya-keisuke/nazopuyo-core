import options
import unittest

import puyo_core

import ../../src/nazopuyo_core/nazo {.all.}

proc main* =
  # ------------------------------------------------
  # Constructor
  # ------------------------------------------------

  # makeEmptyNazo
  block:
    check makeEmptyNazo() == "https://ishikawapuyo.net/simu/pn.html?__200".toNazo(true).get

  # ------------------------------------------------
  # Property
  # ------------------------------------------------
  
  # moveNum
  block:
    check "https://ishikawapuyo.net/simu/pn.html?S03r06S03rAACQ_u1u1__u04".toNazo(true).get.moveNum == 2

  # ------------------------------------------------
  # Nazo <-> string
  # ------------------------------------------------

  # $, toStr, toUrl, toNazoPositions, toNazo
  block:
    let
      str = """
4連鎖するべし
------
......
......
......
......
......
......
......
......
..oo..
.bbb..
.ooo..
.bbbyy
yyyooy
======
"""
      pairsStr = "yb\nyb"
      pairsWithPosStr = "yb\nyb|2>"
      nazoStr = str & pairsStr
      nazoWithPosStr = str & pairsWithPosStr

      nazo = nazoStr.toNazo(false).get
      url = "https://ishikawapuyo.net/simu/pn.html?S03r06S03rAACQ_u1u1__u04"
      urlWithPos = "https://ishikawapuyo.net/simu/pn.html?S03r06S03rAACQ_u1ue__u04"
      positions = @[none Position, some POS_2R]

    check $nazo == nazoStr
    check nazo.toStr == nazoStr
    check nazo.toStr(some positions) == nazoWithPosStr
    check nazo.toUrl == url
    check nazo.toUrl(some positions) == urlWithPos
    check nazoWithPosStr.toNazoPositions(false) == some (nazo: nazo, positions: positions)
    check urlWithPos.toNazoPositions(true) == some (nazo: nazo, positions: positions)
