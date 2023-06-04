import options
import unittest

import puyo_core

import ../../src/nazopuyo_core/mark {.all.}

proc main* =
  # ------------------------------------------------
  # Mark
  # ------------------------------------------------

  # CLEAR
  block:
    check "https://ishikawapuyo.net/simu/pn.html?r4AA3r_EGEs__200".mark == ACCEPT
    check "https://ishikawapuyo.net/simu/pn.html?r4AA3r_EGEs__200".mark(some @[some POS_4L, some POS_3D]) == ACCEPT
    check "https://ishikawapuyo.net/simu/pn.html?r4AA3r_E1E1__200".mark(some @[some POS_4L, some POS_3D]) == ACCEPT
    check "https://ishikawapuyo.net/simu/pn.html?r4AA3r_EGE0__200".mark == WRONG_ANSWER
    check "https://ishikawapuyo.net/simu/pn.html?r4AA3r_EGE1__200".mark == WRONG_ANSWER
    check "https://ishikawapuyo.net/simu/pn.html?r4AA3r_E1Es__200".mark == SKIP_MOVE
    check "https://ishikawapuyo.net/simu/pn.html?r4AA3r_EGEs_W_200".mark == URL_ERROR

  # DISAPPEAR_COLOR
  block:
    check "https://ishikawapuyo.net/simu/pn.html?2p3j9_gscK__a03".mark == ACCEPT
    check "https://ishikawapuyo.net/simu/pn.html?2p3j9_gGcK__a03".mark == WRONG_ANSWER

  # DISAPPEAR_COLOR_MORE
  block:
    check "https://ishikawapuyo.net/simu/pn.html?uo9cA_4uEy__b03".mark == ACCEPT
    check "https://ishikawapuyo.net/simu/pn.html?uo9cA_4EEy__b03".mark == WRONG_ANSWER

  # DISAPPEAR_NUM
  block:
    check "https://ishikawapuyo.net/simu/pn.html?o00w0ig0SM0SPr_G0iq__c0i".mark == ACCEPT
    check "https://ishikawapuyo.net/simu/pn.html?o00w0ig0SM0SPr_Giiu__c0i".mark == WRONG_ANSWER

  # DISAPPEAR_NUM_MORE
  block:
    check "https://ishikawapuyo.net/simu/pn.html?1Oo1bo3hg3p81bM2bo_o0oo__d0s".mark == ACCEPT
    check "https://ishikawapuyo.net/simu/pn.html?1Oo1bo3hg3p81bM2bo_o0o0__d0s".mark == WRONG_ANSWER

  # CHAIN
  block:
    check "https://ishikawapuyo.net/simu/pn.html?1081681S84CM_AuA4__u03".mark == ACCEPT
    check "https://ishikawapuyo.net/simu/pn.html?1081681S84CM_AuAE__u03".mark == WRONG_ANSWER
    check "https://ishikawapuyo.net/simu/pn.html?800800800o00900p00r00c00A00a009g0_ec6c__u05".mark == IMPOSSIBLE_MOVE
    check "https://ishikawapuyo.net/simu/pn.html?900A00k00h00c01cw_24C464__u05".mark == DEAD

  # CHAIN_MORE
  block:
    check "https://ishikawapuyo.net/simu/pn.html?Mp6j92mS_oGqc__v03".mark == ACCEPT
    check "https://ishikawapuyo.net/simu/pn.html?Mp6j92mS_ouqi__v03".mark == WRONG_ANSWER

  # CHAIN_CLEAR
  block:
    check "https://ishikawapuyo.net/simu/pn.html?3w03s01c0Sr0SbS_oouw__w04".mark == ACCEPT
    check "https://ishikawapuyo.net/simu/pn.html?3w03s01c0Sr0SbS_ouuE__w04".mark == WRONG_ANSWER

  # CHAIN_MORE_CLEAR
  block:
    check "https://ishikawapuyo.net/simu/pn.html?200i0iJiGGGJiJ_k4kk__x04".mark == ACCEPT
    check "https://ishikawapuyo.net/simu/pn.html?200i0iJiGGGJiJ_k6kC__x04".mark == WRONG_ANSWER

  # DISAPPEAR_COLOR_SAMETIME
  block:
    check "https://ishikawapuyo.net/simu/pn.html?2005M05g05g06g65E2iE_OKOy__E02".mark == ACCEPT
    check "https://ishikawapuyo.net/simu/pn.html?2005M05g05g06g65E2iE_OyO8__E02".mark == WRONG_ANSWER

  # DISAPPEAR_COLOR_MORE_SAMETIME
  block:
    check "https://ishikawapuyo.net/simu/pn.html?600300200100p00pg_qKck__E02".mark == ACCEPT
    check "https://ishikawapuyo.net/simu/pn.html?600300200100p00pg_qKcI__E02".mark == WRONG_ANSWER

  # DISAPPEAR_NUM_SAMETIME
  block:
    check "https://ishikawapuyo.net/simu/pn.html?10090aj09jo_oscE__G0c".mark == ACCEPT
    check "https://ishikawapuyo.net/simu/pn.html?10090aj09jo_oscq__G0c".mark == WRONG_ANSWER
    check "https://ishikawapuyo.net/simu/pn.html?11011M16Me69S6Nc4CA4Ne6N96N_G46g__G0o".mark == ACCEPT
    check "https://ishikawapuyo.net/simu/pn.html?11011M16Me69S6Nc4CA4Ne6N96N_G464__G0o".mark == WRONG_ANSWER

  # DISAPPEAR_NUM_MORE_SAMETIME
  block:
    check "https://ishikawapuyo.net/simu/pn.html?pp9b9rpr_ogogoe__H0b".mark == ACCEPT
    check "https://ishikawapuyo.net/simu/pn.html?pp9b9rpr_osouow__H0b".mark == WRONG_ANSWER

  # DISAPPEAR_PLACE
  block:
    check "https://ishikawapuyo.net/simu/pn.html?8w0wAcw_AuAE__I02".mark == ACCEPT
    check "https://ishikawapuyo.net/simu/pn.html?8w0wAcw_A4Au__I02".mark == WRONG_ANSWER

  # DISAPPEAR_PLACE_MORE
  block:
    check "https://ishikawapuyo.net/simu/pn.html?8w0wAcw_AuAE__J02".mark == ACCEPT
    check "https://ishikawapuyo.net/simu/pn.html?8w0wAcw_A4Au__J02".mark == WRONG_ANSWER

  # DISAPPEAR_CONNECT
  block:
    check "https://ishikawapuyo.net/simu/pn.html?M0hh0ia09r0ij8_e6gI__Q07".mark == ACCEPT
    check "https://ishikawapuyo.net/simu/pn.html?M0hh0ia09r0ij8_e2gC__Q07".mark == WRONG_ANSWER

  # DISAPPEAR_CONNECT_MORE
  block:
    check "https://ishikawapuyo.net/simu/pn.html?M0hh0ia09r0ij8_e6gI__R07".mark == ACCEPT
    check "https://ishikawapuyo.net/simu/pn.html?M0hh0ia09r0ij8_e2gC__R07".mark == WRONG_ANSWER
