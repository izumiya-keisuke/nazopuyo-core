## The :code:`nazopuyo_core` module implements Nazo Puyo.
## With :code:`import nazopuyo_core`, you can use all features provided by this module.
## Documentations:
## * `Mark <./nazopuyo_core/mark.html>`_
## * `Nazo <./nazopuyo_core/nazo.html>`_
## 
## This module uses `puyo-core <https://github.com/izumiya-keisuke/puyo-core>`_, so please refer to it for details.
##

import ./nazopuyo_core/mark
export mark.MarkResult, mark.mark

import ./nazopuyo_core/nazo
export
  nazo.RequirementKind,
  nazo.RequirementColor,
  nazo.RequirementNumber,
  nazo.Requirement,
  nazo.Nazo,
  nazo.RequirementKindsWithoutColor,
  nazo.RequirementKindsWithoutNum,
  nazo.RequirementKindsWithColor,
  nazo.RequirementKindsWithNum,
  nazo.makeEmptyNazo,
  nazo.moveNum,
  nazo.`$`,
  nazo.toUrl,
  nazo.toRequirement,
  nazo.toStr,
  nazo.toNazoPositions,
  nazo.toNazo
