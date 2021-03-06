Unit conversion grammar
=======================

Introduction
------------

This grammar demonstrates:

  * modularity, e.g. numbers and SI prefixes are described in separate modules
  * compositionality, e.g.
    * SI prefixes can be easily applied to any units,
    * area and volume units can be built from any length units,
    * speed units are built by combining length and time units (`km / h`)
  * support for multiple wordforms of the same word (`meetrit`, `meetrites`)
  * using opers to share code
  * smart paradigms (i.e. generate `PlIn` automatically from `SgPart`)
  * unit type checking (meters and feet agree, but meters and liters do not)
  * ambiguity, e.g. "kaks minutit sekundites" gets two parse trees


Compiling
---------

    gf -s --make --optimize-pgf --path "Numeral:Fraction:lib" Unitconv/Unitconv???.gf


TODO
----

  * put Estonian-specific opers into a separate library and structure in the style of RGL
  * combining Unitconv with Exp, possibilities:
    * simple union, creating a new language (Unitconv + Exp) (see Calc);
    * Unitconv uses expressions instead of numbers;
    * Exp uses units instead of numbers, and Conv uses expressions (of the same type).
  * ambiguity as a UI technique
  * complex conversions, e.g. cost of a time-limited service (internet, parking):
    * "50 cents per 10 minutes in euros per 2 hours"
  * discuss if it makes sense to support variants like {naelades | naeltes},
    { meetritesse | meetriteks }. Since these variants sound similar, we can also
    rely on the speech recognizer robustness (i.e. it would convert a spoken
    /naeltes/ or /naelteks/ into "naelades")
  * handling rare (but legal?) forms like "kilo minut"
  * does attaching of probabilities work (in GF, in GF->JSGF, in JSGF->FSA)
  * lexing and unlexing (writing of numbers) (maybe use binding in the decimal grammar?)
  * exclude repetitions like "12 liters in liters"
  * use dependent types in unit type checking
  * demonstrate and discuss the limitations of FSA and CFG in expressivity (compared to GF)
  * does it make sense to write FSA-optimized versions for each grammar, i.e. so that we have e.g.
    * CalcApp (executable code),
    * CalcEst (used to generate App),
    * CalcEstFSA (used ONLY by the speech recognizer),
    where CalcEst and CalcEstFSA recognize the exact same language but can assign different parse
    trees, e.g. "a + b ^ c * d" could be parsed as
    * (a + (b ^ (c * d)))
    * ((a + (b ^ c)) * d)

BUGs
-----

These used to work but do not anymore for some reason,
i.e. generation to Est works but parsing of Est does not:

    kaks kilo meetrit milli sekundis milli meetrites mikro sekundis
    2 k m / m s IN m m / µ s

    kaks kilo meetrit ruut milli sekundis milli meetrites ruut mikro sekundis
    2 k m * m s ** -2 IN m m * µ s ** -2


How to add a new unit to the grammar
------------------------------------

### If the unit's physical quantity is already there

If the unit's quantity (e.g. Length, Mass, ...) is already present in the grammar,
then just edit the file Unit.gf to add the mapping of the new unit (e.g. `meter')
to the existing quantity:

    fun meter : Length;

and add the words of the unit to the concrete syntaxes (UnitEst.gf and UnitApp.gf):

    lin meter = mkUnit "meetrit";
    lin meter = ss "m";

The functions `mkUnit` and `ss` are predefined. They take a string and generate the internally
used lexicon structure, e.g. the `mkUnit` function (defined in `lib/Estonian.gf`) also generates
the plural inessive (`PlIn`) form from the given singular partitive form (`SgPart`).
If it turns out that the automatically generated form is incorrect then use
a multi-argument version of `mkUnit` to provide the forms manually, e.g.

    lin euro = mkUnit "eurot" "eurodes" ;


### If you want to add a unit of new physical quantity

If the quantity of the unit is not already described in the grammar then
additionally add a new category to Unit.gf:

    cat Length ; LengthUnit;

and add some functions:

    length_unit : Length -> LengthUnit ;
    -- only if units of this quantity can be SI-prefixed
    prefixed_length_unit : Prefix -> Length -> LengthUnit ;

(Note that it is currently not possible to declare that only some units
of a quantity can be SI-prefixed, e.g. if the grammar allows "milli seconds"
then it also allows "nano decades".)

Into the concrete syntaxes (UnitEst.gf and UnitApp.gf) add the linearizations
of these functions, e.g. in the case of UnitEst.gf:

    -- id: just copy the linearization of Length to get LengthUnit
    length_unit = id CaseStr ;
    -- prefix: prefix the linearization of Length with a prefix word to obtain LengthUnit
    prefixed_length_unit = prefix ;

Also, add the corresponding conversion function to Unitconv.gf:

    length : LengthUnit -> LengthUnit -> Conv ;

and the linearization of the function (in both UnitconvEst.gf and UnitconvApp.gf)

    lin length = c ;
