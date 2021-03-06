abstract Address = Eeppl, Tallinnstreet, Tartustreet, Number ** {

flags startcat = Address;

cat Address; SmallNumeral;

fun
	-- We want to redefine `num` to exclude numbers larger than 999
	-- because these do not occur as part of Estonian street addresses.
	-- Inheriting "Number - [num]" and defining "num : Sub1000 -> Number"
	-- did not work. :(
	-- The problem (or at least part of it) is that Sub1000 and Sub1000000
	-- do not necessarily have the same linearization type in all concrete
	-- syntaxes. Also, the functions are not module internal, e.g. if Action
	-- inherits from Direction (where num = small numbers) and also from
	-- Calc (where num = big numbers) then we get a conflict.

	-- So we define a new function instead.
	small_num : Sub1000 -> SmallNumeral;

	address0 : Eeppl -> Address;
	address1 : Tallinnstreet -> Address;
	address2 : SmallNumeral -> Tallinnstreet -> Address;
	tartu1 : Tartustreet -> Address;
	tartu2 : SmallNumeral -> Tartustreet -> Address;

}
