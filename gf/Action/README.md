Action
======

This grammar is meant to be the union of all other grammars that make
sense in the context of "voice actions", e.g.

  * calculations
  * map queries
  * event/alarm scheduling

Compiling
---------

    gf -s --make --optimize-pgf --mk-index --path "Calc:Address:Direction:Expr:Unitconv:Numeral:Fraction:lib" Action/Action???.gf