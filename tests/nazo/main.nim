import options
import std/setutils
import unittest

import puyo_core

import ../../src/nazopuyo_core/nazo

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
    check makeEmptyNazo().moveNum == 0
    check "https://ishikawapuyo.net/simu/pn.html?109e9_01__200".toNazo(true).get.moveNum == 1
    check "https://ishikawapuyo.net/simu/pn.html?5004ABA_S1S1__u03".toNazo(true).get.moveNum == 2
    check "https://ishikawapuyo.net/simu/pn.html?3ww3so4zM_s1G1u1__u04".toNazo(true).get.moveNum == 3
    check "https://ishikawapuyo.net/simu/pn.html?z00R00Jw0Qw_G1s1G1Q1__u04".toNazo(true).get.moveNum == 4
    check toNazo(
      "https://ishikawapuyo.net/simu/pn.html?6SM6SM1Og1eg6SM2N82m86SM1Og1eg6SM_01c1e1c1e101c1c1__x06",
      true).get.moveNum == 8
    check toNazo(
      "https://ishikawapuyo.net/simu/pn.html?231331123122312231212113133321322_41g1c1o1q1o1c1c1g1__x0a",
      true).get.moveNum == 9
    check toNazo(
      "https://ishikawapuyo.net/simu/pn.html?E05_0101e1e10101e1e10101e1e10101e1e10101e1e10101e1e101U1U101__w0e",
      true).get.moveNum == 28
    check toNazo(
      "https://ishikawapuyo.net/simu/pn.html?_0101s1s10101s1s1s1s101010101o1o1o1o1s101s101o1o1o1o1o1o1o1o10101__u0g",
      true).get.moveNum == 32

  # ------------------------------------------------
  # Requirement <-> string
  # ------------------------------------------------

  # `$`, toUrl, toRequirement
  block:
    # requirement w/ color
    block:
      let
        req = (kind: CLEAR, color: some RequirementColor.GARBAGE, num: none RequirementNumber)
        str = "おじゃまぷよ全て消すべし"
        url = "260"

      check $req == str
      check req.toUrl == url
      check str.toRequirement(false) == some req
      check url.toRequirement(true) == some req

    # requirement w/ num
    block:
      let
        req = (kind: CHAIN, color: none RequirementColor, num: some 5.RequirementNumber)
        str = "5連鎖するべし"
        url = "u05"

      check $req == str
      check req.toUrl == url
      check str.toRequirement(false) == some req
      check url.toRequirement(true) == some req

    # requirement w/ color and number
    block:
      let
        req = (kind: CHAIN_MORE_CLEAR, color: some RequirementColor.RED, num: some 3.RequirementNumber)
        str = "3連鎖以上&赤ぷよ全て消すべし"
        url = "x13"

      check $req == str
      check req.toUrl == url
      check str.toRequirement(false) == some req
      check url.toRequirement(true) == some req

    # invalid arguments
    block:
      # invalid :code:`str`
      check "cぷよ全て消すべし".toRequirement(false).isNone
      check "290".toRequirement(true).isNone

      # invalid :code:`url`
      check "5連鎖するべし".toRequirement(true).isNone
      check "u05".toRequirement(false).isNone

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
      pairsPosStr = "yb\nyb|2>"
      nazoStr = str & pairsStr
      nazoPosStr = str & pairsPosStr

      url = "https://ishikawapuyo.net/simu/pn.html?S03r06S03rAACQ_u1u1__u04"
      urlWithPos = "https://ishikawapuyo.net/simu/pn.html?S03r06S03rAACQ_u1ue__u04"
      positions = @[none Position, some POS_2R]

      envUrl = "https://ishikawapuyo.net/simu/pn.html?S03r06S03rAACQ_u1u1"
      nazo = (
        env: envUrl.toEnv(true, useColors = some ColorPuyo.fullSet).get,
        req: "u04".toRequirement(true).get)

    # Nazo -> string
    block:
      check $nazo == nazoStr
      check nazo.toStr == nazoStr
      check nazo.toStr(some positions) == nazoPosStr
      check nazo.toUrl == url
      check nazo.toUrl(some positions) == urlWithPos

    # string -> Nazo
    block:
      check nazoPosStr.toNazoPositions(false) == some (nazo: nazo, positions: positions)
      check urlWithPos.toNazoPositions(true) == some (nazo: nazo, positions: positions)
      check nazoPosStr.toNazo(false) == some nazo
      check urlWithPos.toNazo(true) == some nazo

    # invalid arguments
    block:
      # invalid :code:`str`
      check ($nazo.env).toNazo(false).isNone
      check ($nazo.env).toNazoPositions(false).isNone
      check envUrl.toNazo(true).isNone
      check envUrl.toNazoPositions(true).isNone

      # invalid :code:`url`
      check nazoPosStr.toNazoPositions(true).isNone
      check nazoPosStr.toNazo(true).isNone
      check urlWithPos.toNazoPositions(false).isNone
      check urlWithPos.toNazo(false).isNone
