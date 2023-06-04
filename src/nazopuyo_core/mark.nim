## This module implements marking nazo puyo.
##

import math
import options
import sequtils
import std/setutils
import tables

import puyo_core
import puyo_core/env as envLib

import ./nazo

type MarkResult* = enum
  ## Marking result.
  ACCEPT
  WRONG_ANSWER
  DEAD
  IMPOSSIBLE_MOVE
  SKIP_MOVE
  URL_ERROR

const RequirementColorToCell = {
  RequirementColor.GARBAGE: Cell.GARBAGE,
  RequirementColor.RED: Cell.RED,
  RequirementColor.GREEN: Cell.GREEN,
  RequirementColor.BLUE: Cell.BLUE,
  RequirementColor.YELLOW: Cell.YELLOW,
  RequirementColor.PURPLE: Cell.PURPLE}.toTable

# ------------------------------------------------
# Mark
# ------------------------------------------------

func accept(
  req: Requirement,
  moveResult: MoveResult,
  field: Field,
  disappearColors: Option[set[ColorPuyo]],
  disappearNum: Option[Natural],
): bool {.inline.} =
  ## Returns :code:`true` if :code:`req` is satisfied.
  # unsolvable requirement
  if req.kind in {DISAPPEAR_PLACE, DISAPPEAR_PLACE_MORE, DISAPPEAR_CONNECT, DISAPPEAR_CONNECT_MORE}:
    if req.color.get == RequirementColor.GARBAGE:
      return false

  # check clear
  if req.kind in {CLEAR, CHAIN_CLEAR, CHAIN_MORE_CLEAR}:
    let fieldNum = case req.color.get
    of RequirementColor.ALL:
      field.puyoNum
    of RequirementColor.GARBAGE:
      field.garbageNum
    of RequirementColor.COLOR:
      field.colorNum
    else:
      field.colorNum RequirementColorToCell[req.color.get]

    if fieldNum > 0:
      return false

  # check number
  if req.num.isSome:
    var hasMultipleCandidates = false

    var nowNum: Natural
    case req.kind
    of DISAPPEAR_COLOR, DISAPPEAR_COLOR_MORE:
      nowNum = disappearColors.get.card
    of DISAPPEAR_NUM, DISAPPEAR_NUM_MORE:
      nowNum = disappearNum.get
    of CHAIN, CHAIN_MORE, CHAIN_CLEAR, CHAIN_MORE_CLEAR:
      nowNum = moveResult.chainNum
    else:
      hasMultipleCandidates = true

    var nowNums: seq[int]
    case req.kind
    of DISAPPEAR_COLOR_SAMETIME, DISAPPEAR_COLOR_MORE_SAMETIME:
      for nums in moveResult.disappearNums.get:
        nowNums.add nums[ColorPuyo.low .. ColorPuyo.high].countIt it > 0
    of DISAPPEAR_NUM_SAMETIME, DISAPPEAR_NUM_MORE_SAMETIME:
      case req.color.get
      of RequirementColor.ALL:
        nowNums = moveResult.puyoNums
      of RequirementColor.COLOR:
        nowNums = moveResult.colorNums
      else:
        nowNums = moveResult.disappearNums.get.mapIt it[RequirementColorToCell[req.color.get]].int
    of DISAPPEAR_PLACE, DISAPPEAR_PLACE_MORE:
      case req.color.get
      of RequirementColor.ALL, RequirementColor.COLOR:
        for numsArray in moveResult.detailDisappearNums.get:
          nowNums.add sum numsArray[ColorPuyo.low .. ColorPuyo.high].mapIt it.len
      of RequirementColor.GARBAGE:
        assert false
      else:
        nowNums = moveResult.detailDisappearNums.get.mapIt it[RequirementColorToCell[req.color.get]].len
    of DISAPPEAR_CONNECT, DISAPPEAR_CONNECT_MORE:
      case req.color.get
      of RequirementColor.ALL, RequirementColor.COLOR:
        for numsArray in moveResult.detailDisappearNums.get:
          for nums in numsArray[ColorPuyo.low .. ColorPuyo.high]:
            nowNums &= nums.mapIt it.int
      of RequirementColor.GARBAGE:
        assert false
      else:
        for numsArray in moveResult.detailDisappearNums.get:
          nowNums &= numsArray[RequirementColorToCell[req.color.get]].mapIt it.int
    else:
      assert not hasMultipleCandidates

    if req.kind in {
      DISAPPEAR_COLOR,
      DISAPPEAR_NUM,
      CHAIN,
      CHAIN_CLEAR,
      DISAPPEAR_COLOR_SAMETIME,
      DISAPPEAR_NUM_SAMETIME,
      DISAPPEAR_PLACE,
      DISAPPEAR_CONNECT,
    }:
      if hasMultipleCandidates:
        if req.num.get notin nowNums:
          return false
      else:
        if req.num.get != nowNum:
          return false
    else:
      if hasMultipleCandidates:
        if nowNums.allIt it < req.num.get:
          return false
      else:
        if nowNum < req.num.get:
          return false

  return true

func mark*(nazo: Nazo, positions: Positions): MarkResult {.inline.} =
  ## Marks :code:`nazo` with :code:`positions`.
  let moveFn = case nazo.req.kind
  of CLEAR, CHAIN, CHAIN_MORE, CHAIN_CLEAR, CHAIN_MORE_CLEAR:
    envLib.move
  of DISAPPEAR_COLOR, DISAPPEAR_COLOR_MORE, DISAPPEAR_NUM, DISAPPEAR_NUM_MORE:
    envLib.moveWithRoughTracking
  of DISAPPEAR_COLOR_SAMETIME, DISAPPEAR_COLOR_MORE_SAMETIME, DISAPPEAR_NUM_SAMETIME, DISAPPEAR_NUM_MORE_SAMETIME:
    envLib.moveWithDetailTracking
  of DISAPPEAR_PLACE, DISAPPEAR_PLACE_MORE, DISAPPEAR_CONNECT, DISAPPEAR_CONNECT_MORE:
    envLib.moveWithFullTracking

  var
    disappearColors =
      if nazo.req.kind in {DISAPPEAR_COLOR, DISAPPEAR_COLOR_MORE}: some set[ColorPuyo]({}) else: none set[ColorPuyo]
    disappearNum = if nazo.req.kind in {DISAPPEAR_NUM, DISAPPEAR_NUM_MORE}: some 0.Natural else: none Natural
    nazo2 = nazo
    skipped = false
  for pos in positions:
    # skip position
    if pos.isNone:
      skipped = true
      continue
    if skipped:
      return SKIP_MOVE

    # impossible move
    if pos.get in nazo2.env.field.invalidPositions:
      return IMPOSSIBLE_MOVE

    let moveResult = nazo2.env.moveFn(pos.get, false)

    # cumulative color
    if disappearColors.isSome:
      disappearColors =
        some disappearColors.get + ColorPuyo.toSeq.filterIt(moveResult.totalDisappearNums.get[it] > 0).toSet

    # cumulative num
    if disappearNum.isSome:
      let newNum = case nazo.req.color.get
      of RequirementColor.ALL:
        moveResult.puyoNum
      of RequirementColor.COLOR:
        moveResult.colorNum
      of RequirementColor.GARBAGE:
        moveResult.totalDisappearNums.get[HARD] + moveResult.totalDisappearNums.get[Cell.GARBAGE]
      else:
        moveResult.totalDisappearNums.get[RequirementColorToCell[nazo.req.color.get]]

      disappearNum = some disappearNum.get.succ newNum

    # check requirement
    if nazo.req.accept(moveResult, nazo2.env.field, disappearColors, disappearNum):
      return ACCEPT

    # dead
    if nazo2.env.field.isDead:
      return DEAD

  return WRONG_ANSWER

func mark*(url: string, positions = Positions.none): MarkResult {.inline.} =
  ## Marks the nazo puyo represented by the :code:`url`.
  ## If :code:`positions` is given, use it (i.e. ignore the positions in the :code:`url`).
  let nazoPositions = url.toNazoPositions true
  if nazoPositions.isNone:
    return URL_ERROR

  return nazoPositions.get.nazo.mark(if positions.isSome: positions.get else: nazoPositions.get.positions)
