#############
nazopuyo-core
#############

:code:`nazopuyo-core` is a Nazo Puyo library written in `Nim <https://nim-lang.org>`_.

************
Installation
************

::

    nimble install https://github.com/izumiya-keisuke/nazopuyo-core

*****
Usage
*****

With :code:`import nazopuyo_core`, you can use all features provided by this module.
Please refer to the `documentation <https://izumiya-keisuke.github.io/nazopuyo-core>`_ for details.

This module uses `puyo-core <https://github.com/izumiya-keisuke/puyo-core>`_, so please refer to it as well.

*******
License
*******

Apache-2.0 or MPL-2.0

See `NOTICE <NOTICE>`_ for details.

**************
For Developers
**************

Test
====

::

    nim c -r tests/makeTest.nim
    nimble test

Writing Test
============

#. Create a new directory directly under the :code:`tests` directory.
#. Create a new file :code:`main.nim` in the directory.
#. Write the entry point of the test as :code:`main()` procedure in the file.