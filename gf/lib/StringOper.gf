resource StringOper = {

-- Note. Some of these opers come from GF libraries Prelude and Formal,
-- i.e. one could take them directly from there.

-- Note: Predef (that provides Int and Ints) seems to be available
-- without having to point to it.

-- Note: the implementation of precedence is explained in the GF Tutorial
-- http://www.grammaticalframework.org/doc/tutorial/gf-tutorial.html

param
	Bool = True | False ;

oper

	-- Identity function
	id : (A : Type) -> A -> A = \_,a -> a ;

	nonExistType : (A : Type) -> A = \_ -> variants {} ;

	-- TODO: glue that takes arbitrarily many input arguments
	glue = overload {
		glue : (x1,x2 : Str) -> Str = \x1,x2 -> x1 ++ BIND ++ x2 ;
		glue : (x1,x2,x3 : Str) -> Str = \x1,x2,x3 -> x1 ++ BIND ++ x2 ++ BIND ++ x3;
		glue : (x1,x2,x3,x4 : Str) -> Str = \x1,x2,x3,x4 -> x1 ++ BIND ++ x2 ++ BIND ++ x3 ++ BIND ++ x4;
		glue : (x1,x2,x3,x4,x5 : Str) -> Str = \x1,x2,x3,x4,x5 -> x1 ++ BIND ++ x2 ++ BIND ++ x3 ++ BIND ++ x4 ++ BIND ++ x5;
		glue : (x1,x2,x3,x4,x5,x6 : Str) -> Str = \x1,x2,x3,x4,x5,x6 -> x1 ++ BIND ++ x2 ++ BIND ++ x3 ++ BIND ++ x4 ++ BIND ++ x5 ++ BIND ++ x6;
	};

	BIND : Str = "&+" ;

	-- Note that '4' is hard-coded in a few places below, therefore
	-- if you change highestPrec to something else then
	-- look for FIXME below for places than additionally need
	-- an update.
	highestPrec = 4 ;

	-- Numbers from 0 to highestPrec
	Prec : PType = Predef.Ints highestPrec ;
	-- Structure: string (e.g. "pluss") + precedence number (e.g. "3")
	TermPrec : Type = {s : Str ; p : Prec} ;


	SS : Type = {s : Str} ;

	ss : Str -> SS = \s -> {s = s} ;

	prefixSS : Str -> SS -> SS = \f,x -> ss (f ++ x.s) ;
	prefixSS_glue : Str -> SS -> SS = \f,x -> ss (glue f x.s) ;

	postfixSS : Str -> SS -> SS = \f,x -> ss (x.s ++ f) ;
	postfixSS_glue : Str -> SS -> SS = \f,x -> ss (glue x.s f) ;

	-- optional pre- and postfix, e.g. "degrees" (ss "Celsius"):
	-- Celsius
	-- degrees Celsius
	-- Celsius degrees
	optPrePostSS : Str -> SS -> SS = \f,x ->
		variants {x ; ss (f ++ x.s) ; ss (x.s ++ f)} ;

	infixSS : Str -> SS -> SS -> SS
		= \f,x,y -> ss (x.s ++ f ++ y.s) ;
	infixSS_glue : Str -> SS -> SS -> SS
		= \f,x,y -> ss (glue x.s f y.s) ;

	infix : Str -> SS -> SS -> SS
		= \f,x,y -> ss (parenth_Glue (x.s ++ f ++ y.s)) ;

	mkPrec : Prec -> Str -> TermPrec = \p,s -> {s = s ; p = p} ;

	constant : Str -> TermPrec = mkPrec highestPrec ;

	infixl : Prec -> Str -> (_,_ : TermPrec) -> TermPrec = \p,f,x,y ->
		mkPrec p (usePrec p x ++ f ++ usePrec (nextPrec p) y) ;

	infixr : Prec -> Str -> (_,_ : TermPrec) -> TermPrec = \p,f,x,y ->
		mkPrec p (usePrec (nextPrec p) x ++ f ++ usePrec p y) ;

	parenth : Str -> Str = \s -> "(" ++ s ++ ")" ;
	parenth_Glue : Str -> Str = \s -> glue "(" s ")" ;
	parenthSS : SS -> SS = \s -> ss ("(" ++ s.s ++ ")");
	parenthSS_glue : SS -> SS = \s -> ss (glue "(" s.s ")");

	parenthOpt : Str -> Str = \s -> variants {s ; "(" ++ s ++ ")"} ;

	-- Optional string with preference on the string vs. empty.

	optStr : Str -> Str = \s -> variants {s ; []} ;
	strOpt : Str -> Str = \s -> variants {[] ; s} ;

	usePrec : Prec -> TermPrec -> Str = \p,x ->
		case lessPrec x.p p of {
			True => parenth x.s ;
			False => x.s
		} ;

	-- FIXME: Assuming that highestPrec = 4
	lessPrec : Prec -> Prec -> Bool = \p,q ->
		case <<p,q> : Prec * Prec> of {
			<3,4> | <2,3> | <2,4> => True ;
			<1,1> | <1,0> | <0,0> => False ;
			<1,_> | <0,_>         => True ;
			_ => False
		} ;

	-- FIXME: Assuming that highestPrec = 4
	nextPrec : Prec -> Prec = \p -> case <p : Prec> of {
		4 => highestPrec ;
		n => Predef.plus n 1
	} ;

}
