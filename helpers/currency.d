/*****************************************************************************
 *                                                                           *
 * Currency datatype with 4 decimal precision								 *
 *                                                                           *
 *****************************************************************************/

module helpers.currency;

import std.string : format;
import std.traits : isNumeric, isSomeString;
import std.conv : to;
import std.math : lround;

struct Currency
{
	public:
		
		alias value this;
		
		// generic constructor
		this(T)(T val) { __toCurrency(val); }
	
		// properties
		@property double value() { return __fromCurrency(); }
		@property void value(T)(T val) { __toCurrency(val); }
		@property string toString() { return format(frmt, __fromCurrency()); }
		
		// operators
		bool opCast(T)() if (is(T == bool)) {
			return !value_ == 0;
		}
		
		// opBinary for Currency types
		Currency opBinary(string op)(Currency rhs)
		{
			return Currency(mixin("value" ~ op ~ "rhs.value"));
		}

		// opBinary for other types
		Currency opBinary(string op, T)(T rhs) if (isNumeric!T)
		{
			return opBinary!op(Currency(rhs));
		}
		
		// opUnary for preincrement and predecrement
		ref Currency opUnary(string op)() if (op == "++" || op == "--") {
			static if (op == "++")
				value_ += factor;
			else static if (op == "--")
				value_ -= factor;
				
			return this;
		}
		
		// the rest of the unary operators
		Currency opUnary(string op)() if (op == "-" || op == "+" || op == "~")
		{
			return Currency(mixin(op ~ "value"));
		}

		Currency opUnary(string op)() if (op == "!")
		{
			return !value;
		}
		
	private:
		immutable enum frmt = "%.2f";		// strings rounded to two digits
		immutable enum factor = 10000;		// internal representation is four digits
		
		// storage for our value
		long value_;
		
		// convert to Currency
		void __toCurrency(T)(T val)  
		{
			static if (isNumeric!T)
				// numeric is easy
				value_ = cast(long) lround(val * factor);
			else static if (isSomeString!T)
				// convert the string to a double
				value_ = cast(long) lround(to!double(val) * factor);
			else
				// otherwise it is not possible
				throw new Exception(format("type '%s' cannot be converted to Currency", typeid(T)));
		}
		
		// convert to double
		double __fromCurrency()
		{
			return cast(double) value_ / factor;
		}		
}

// helper function: currency.toEuro
string asEuro(ref Currency cur)
{
	return format("€ %s", cur);
}

// helper function: currency.toDollar
string asDollar(ref Currency cur)
{
	return format("$ %s", cur);
}

unittest
{
	Currency c = 100.0 / 121.0 * 2.95;
	assert(c.value == 2.438);
	
	Currency d = 6.50;
	assert(d.value == 6.5);
	
	Currency e = "3.14159265359";
	assert(e.value == 3.1415);
	
	Currency f = 2.55;
	++f;
	assert(f.value == 3.55);
	
	Currency g = 2.98765;
	assert(g.value == 2.9877);
	
	Currency h = e;
	assert(h.value == 3.1415);
	
	Currency i;
	assert(!i == false);
	assert((h + e).value == (3.1415 + 3.1415));
	
	Currency j = 9.99999;
	assert(j.value == 10);
}
