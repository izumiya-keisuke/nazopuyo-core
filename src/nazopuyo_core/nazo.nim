## This module implements the nazo puyo.
##

import deques
import options
import sequtils
import sets
import std/setutils
import strformat
import strutils
import sugar
import tables

import npeg
import npeg/lib/utf8
import puyo_core

type
  RequirementKind* {.pure.} = enum
    ## Kind of the requirement to clear.
    CLEAR = "cぷよ全て消すべし"
    DISAPPEAR_COLOR = "n色消すべし"
    DISAPPEAR_COLOR_MORE = "n色以上消すべし"
    DISAPPEAR_NUM = "cぷよn個消すべし"
    DISAPPEAR_NUM_MORE = "cぷよn個以上消すべし"
    CHAIN = "n連鎖するべし"
    CHAIN_MORE = "n連鎖以上するべし"
    CHAIN_CLEAR = "n連鎖&cぷよ全て消すべし"
    CHAIN_MORE_CLEAR = "n連鎖以上&cぷよ全て消すべし"
    DISAPPEAR_COLOR_SAMETIME = "n色同時に消すべし"
    DISAPPEAR_COLOR_MORE_SAMETIME = "n色以上同時に消すべし"
    DISAPPEAR_NUM_SAMETIME = "cぷよn個同時に消すべし"
    DISAPPEAR_NUM_MORE_SAMETIME = "cぷよn個以上同時に消すべし"
    DISAPPEAR_PLACE = "cぷよn箇所同時に消すべし"
    DISAPPEAR_PLACE_MORE = "cぷよn箇所以上同時に消すべし"
    DISAPPEAR_CONNECT = "cぷよn連結で消すべし"
    DISAPPEAR_CONNECT_MORE = "cぷよn連結以上で消すべし"

  RequirementColor* {.pure.} = enum
    ## 'c' in the :code:`RequirementKind`.
    ALL = ""
    RED = "赤"
    GREEN = "緑"
    BLUE = "青"
    YELLOW = "黄"
    PURPLE = "紫"
    GARBAGE = "おじゃま"
    COLOR = "色"

  RequirementNumber* = range[0 .. 63] ## 'n' in the :code:`RequirementKind`.

  Requirement* = tuple
    ## Nazo Puyo requirement to clear.
    kind: RequirementKind
    color: Option[RequirementColor]
    num: Option[RequirementNumber]

  Nazo* = tuple
    ## Nazo Puyo.
    env: Env
    req: Requirement

const
  RequirementKindsWithoutColor* = {
    DISAPPEAR_COLOR,
    DISAPPEAR_COLOR_MORE,
    CHAIN,
    CHAIN_MORE,
    DISAPPEAR_COLOR_SAMETIME,
    DISAPPEAR_COLOR_MORE_SAMETIME} ## All :code:`RequirementKind` not containing 'c'.
  RequirementKindsWithoutNum* = {CLEAR} ## All :code:`RequirementKind` not containing 'n'.

  RequirementKindsWithColor* = RequirementKindsWithoutColor.complement ## All :code:`RequirementKind` containing 'c'.
  RequirementKindsWithNum* = RequirementKindsWithoutNum.complement ## All :code:`RequirementKind` containing 'n'.

# ------------------------------------------------
# Constructor
# ------------------------------------------------

func makeEmptyNazo*: Nazo {.inline.} =
  ## Returns the empty nazo puyo.
  result.env = makeEnv(useColors = some ColorPuyo.fullSet, setPairs = false)
  result.req = (kind: RequirementKind.low, color: RequirementColor.ALL.some, num: RequirementNumber.none)

# ------------------------------------------------
# Property
# ------------------------------------------------

func moveNum*(nazo: Nazo): int {.inline.} =
  ## Returns the number of moves of the :code:`nazo`.
  nazo.env.pairs.len

# ------------------------------------------------
# Requirement -> string
# ------------------------------------------------

func `$`*(req: Requirement): string {.inline.} =
  ## Converts :code:`req` to the string representation.
  result = $req.kind

  if req.color.isSome:
    result = result.replace("c", $req.color.get)

  if req.num.isSome:
    result = result.replace("n", $req.num.get)

const
  KindUrls = "2abcduvwxEFGHIJQR"
  ColorUrls = "01234567"
  NumUrls = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ.-"

func toUrl*(req: Requirement): string {.inline.} =
  ## Converts :code:`req` to the URL.
  let
    kind = KindUrls[req.kind.ord - RequirementKind.low.ord]
    color = if req.kind in RequirementKindsWithColor: ColorUrls[req.color.get.ord - RequirementColor.low.ord] else: '0'
    num = if req.kind in RequirementKindsWithNum: NumUrls[req.num.get - RequirementNumber.low] else: '0'

  return &"{kind}{color}{num}"

# ------------------------------------------------
# string -> Requirement
# ------------------------------------------------

func toRequirement(kind: RequirementKind, color = string.none, num = string.none): Option[Requirement] {.inline.} =
  ## Converts the arguments to the requirement.
  const
    StrToColor = collect:
      for color in RequirementColor:
        {$color: color}
    StrToNum = collect:
      for num in RequirementNumber.low .. RequirementNumber.high:
        {$num: num}

  var reqColor = none RequirementColor
  if kind in RequirementKindsWithColor:
    if color.isNone or color.get notin StrToColor:
      return

    reqColor = StrToColor[color.get].some

  var reqNum = none RequirementNumber
  if kind in RequirementKindsWithNum:
    if num.isNone or num.get notin StrToNum:
      return

    reqNum = StrToNum[num.get].some

  return some (kind, reqColor, reqNum).Requirement

## Requirement parser.
const Parser =
  peg("requirement", req: Option[Requirement]):
    color <- utf8.any[0 .. 4]
    num <- Digit[1 .. 2]

    reqClear <- >color * "ぷよ全て消すべし" * !1:
      req = CLEAR.toRequirement(color = some $1)
    reqDisappearColor <- >num * "色消すべし" * !1:
      req = DISAPPEAR_COLOR.toRequirement(num = some $1)
    reqDisappearColorMore <- >num * "色以上消すべし" * !1:
      req = DISAPPEAR_COLOR_MORE.toRequirement(num = some $1)
    reqDisappearNum <- >color * "ぷよ" * >num * "個消すべし" * !1:
      req = DISAPPEAR_NUM.toRequirement(color = some $1, num = some $1)
    reqDisappearNumMore <- >color * "ぷよ" * >num * "個以上消すべし" * !1:
      req = DISAPPEAR_NUM_MORE.toRequirement(color = some $1, num = some $1)
    reqChain <- >num * "連鎖するべし" * !1:
      req = CHAIN.toRequirement(num = some $1)
    reqChainMore <- >num * "連鎖以上するべし" * !1:
      req = CHAIN_MORE.toRequirement(num = some $1)
    reqChainClear <- >num * "連鎖&" * >color * "ぷよ全て消すべし" * !1:
      req = CHAIN_CLEAR.toRequirement(num = some $1, color = some $2)
    reqChainMoreClear <- >num * "連鎖以上&" * >color * "ぷよ全て消すべし" * !1:
      req = CHAIN_MORE_CLEAR.toRequirement(num = some $1, color = some $2)
    reqDisappearColorSametime <- >num * "色同時に消すべし" * !1:
      req = DISAPPEAR_COLOR_SAMETIME.toRequirement(num = some $1)
    reqDisappearColorMoreSametime <- >num * "色以上同時に消すべし" * !1:
      req = DISAPPEAR_COLOR_MORE_SAMETIME.toRequirement(num = some $1)
    reqDisappearNumSametime <- >color * "ぷよ" * >num * "個同時に消すべし" * !1:
      req = DISAPPEAR_NUM_SAMETIME.toRequirement(color = some $1, num = some $2)
    reqDisappearNumMoreSametime <- >color * "ぷよ" * >num * "個以上同時に消すべし" * !1:
      req = DISAPPEAR_NUM_MORE_SAMETIME.toRequirement(color = some $1, num = some $2)
    reqDisappearPlace <- >color * "ぷよ" * >num * "箇所同時に消すべし" * !1:
      req = DISAPPEAR_PLACE.toRequirement(color = some $1, num = some $2)
    reqDisappearPlaceMore <- >color * "ぷよ" * >num * "箇所以上同時に消すべし" * !1:
      req = DISAPPEAR_PLACE_MORE.toRequirement(color = some $1, num = some $2)
    reqDisappearConnect <- >color * "ぷよ" * >num * "連結で消すべし" * !1:
      req = DISAPPEAR_CONNECT.toRequirement(color = some $1, num = some $2)
    reqDisappearConnectMore <- >color * "ぷよ" * >num * "連結以上で消すべし" * !1:
      req = DISAPPEAR_CONNECT_MORE.toRequirement(color = some $1, num = some $2)

    requirement <-
      reqClear |
      reqDisappearColor |
      reqDisappearColorMore |
      reqDisappearNum |
      reqDisappearNumMore |
      reqChain |
      reqChainMore |
      reqChainClear |
      reqChainMoreClear |
      reqDisappearColorSametime |
      reqDisappearColorMoreSametime |
      reqDisappearNumSametime |
      reqDisappearNumMoreSametime |
      reqDisappearPlace |
      reqDisappearPlaceMore |
      reqDisappearConnect |
      reqDisappearConnectMore

func toRequirement*(str: string, url: bool): Option[Requirement] {.inline.} =
  ## Converts :code:`str` to the requirement.
  ## The string representation or URL is acceptable as :code:`str`,
  ## and which type of input is specified by :code:`url`.
  ## If the conversion fails, returns :code:`none`.
  const
    UrlCharToKind = collect:
      for i, url in KindUrls:
        {url: RequirementKind.low.succ i}
    UrlCharToColor = collect:
      for i, url in ColorUrls:
        {url: RequirementColor.low.succ i}
    UrlCharToNum = collect:
      for i, url in NumUrls:
        {url: RequirementNumber.low.succ i}

  if url:
    if str.len != 3:
      return

    var req: Requirement
    if str[0] notin UrlCharToKind:
      return
    req.kind = UrlCharToKind[str[0]]

    if req.kind in RequirementKindsWithColor:
      if str[1] notin UrlCharToColor:
        return
      req.color = some UrlCharToColor[str[1]]

    if req.kind in RequirementKindsWithNum:
      if str[2] notin UrlCharToNum:
        return
      req.num = some UrlCharToNum[str[2]]

    return some req

  {.noSideEffect.}:
    discard Parser.match(str, result)

# ------------------------------------------------
# Nazo -> string
# ------------------------------------------------

const NazoSep = "\n------\n"

func `$`*(nazo: Nazo): string {.inline.} =
  ## Converts :code:`nazo` to the string representation.
  &"{nazo.req}{NazoSep}{nazo.env}"

func toStr*(nazo: Nazo, positions = Positions.none): string {.inline.} =
  ## Converts :code:`nazo` and :code:`positions` to the string representation.
  &"{nazo.req}{NazoSep}{nazo.env.toStr positions}"

func toUrl*(nazo: Nazo, positions = Positions.none, domain = ISHIKAWAPUYO): string {.inline.} =
  ## Converts :code:`nazo` and :code:`positions` to the URL.
  &"{nazo.env.toUrl(positions, mode = UrlMode.NAZO, domain = domain)}__{nazo.req.toUrl}"

# ------------------------------------------------
# string -> Nazo
# ------------------------------------------------

func toNazoPositions*(str: string, url: bool): Option[tuple[nazo: Nazo, positions: Positions]] {.inline.} =
  ## Converts :code:`str` to the nazo puyo and positions.
  ## The string representation or URL is acceptable as :code:`str`,
  ## and which type of input is specified by :code:`url`.
  ## If the conversion fails, returns :code:`none`.
  let strings = str.split(if url: "__" else: NazoSep)
  if strings.len != 2:
    return

  let
    envStr = if url: strings[0] else: strings[1]
    reqStr = if url: strings[1] else: strings[0]

  let envPositions = envStr.toEnvPositions(url, ColorPuyo.fullSet.some)
  if envPositions.isNone:
    return

  let req = reqStr.toRequirement url
  if req.isNone:
    return

  return some (nazo: (env: envPositions.get.env, req: req.get).Nazo, positions: envPositions.get.positions)

func toNazo*(str: string, url: bool): Option[Nazo] {.inline.} =
  ## Converts :code:`str` to the nazo puyo.
  ## The string representation or URL is acceptable as :code:`str`,
  ## and which type of input is specified by :code:`url`.
  ## If the conversion fails, returns :code:`none`.
  let nazoPositions = str.toNazoPositions url
  return if nazoPositions.isSome: some nazoPositions.get.nazo else: none Nazo
