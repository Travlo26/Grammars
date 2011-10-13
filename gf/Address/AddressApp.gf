concrete AddressApp of Address = TownEst, StreetFEst, decimal ** open StringOper in {

-- Using Estonian town and street names but "decimal" numerals.

flags coding=utf8;

lincat Address, SmallNumeral = SS;

lin
	small_num n = {s = n.s ! noz} ;
	address1 x y = ss (x ++ "," ++ y);
	address2 x y z = ss (x ++ y.s ++ "," ++ z);
}