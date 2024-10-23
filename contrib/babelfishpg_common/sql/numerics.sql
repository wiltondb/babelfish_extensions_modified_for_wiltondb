CREATE TYPE sys.TINYINT;

CREATE OR REPLACE FUNCTION sys.tinyintin(cstring)
RETURNS sys.TINYINT
AS 'babelfishpg_common', 'tinyintin'
LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE OR REPLACE FUNCTION sys.tinyintout(sys.TINYINT)
RETURNS cstring
AS 'babelfishpg_common', 'tinyintout'
LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE OR REPLACE FUNCTION sys.tinyintrecv(internal)
RETURNS sys.TINYINT
AS 'babelfishpg_common', 'tinyintrecv'
LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE OR REPLACE FUNCTION sys.tinyintsend(sys.TINYINT)
RETURNS bytea
AS 'babelfishpg_common', 'tinyintsend'
LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE TYPE sys.TINYINT(
	INPUT          = sys.tinyintin,
	OUTPUT         = sys.tinyintout,
	RECEIVE        = sys.tinyintrecv,
	SEND           = sys.tinyintsend,
	INTERNALLENGTH = 2,
	ALIGNMENT      = 'int2',
	STORAGE        = 'plain',
	CATEGORY       = 'N',
  PASSEDBYVALUE
);

CREATE DOMAIN sys.INT AS INTEGER;
CREATE DOMAIN sys.BIGINT AS BIGINT;
CREATE DOMAIN sys.REAL AS REAL;
CREATE DOMAIN sys.FLOAT AS DOUBLE PRECISION;

-- Types with different default typmod behavior
SET enable_domain_typmod = TRUE;
CREATE DOMAIN sys.DECIMAL AS NUMERIC;
RESET enable_domain_typmod;

-- Domain Self Cast Functions to support Typmod Cast in Domain
CREATE OR REPLACE FUNCTION sys.decimal(sys.nchar, integer, boolean)
RETURNS sys.nchar
AS 'numeric'
LANGUAGE INTERNAL IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION sys.numericeqint(NUMERIC, INTEGER)
RETURNS BOOL
AS $$
  SELECT $1 = $2::NUMERIC;
$$
LANGUAGE SQL IMMUTABLE STRICT PARALLEL SAFE;

CREATE OPERATOR sys.= (
    LEFTARG    = NUMERIC,
    RIGHTARG   = INTEGER,
    COMMUTATOR = =,
    PROCEDURE  = sys.numericeqint
);

CREATE OR REPLACE FUNCTION sys.int2xor(leftarg int2, rightarg int2)
RETURNS int2
AS $$
SELECT CAST(CAST(sys.bitxor(CAST(CAST(leftarg AS int4) AS pg_catalog.bit(16)),
                    CAST(CAST(rightarg AS int4) AS pg_catalog.bit(16))) AS int4) AS int2);
$$
LANGUAGE SQL STABLE;

CREATE OPERATOR sys.^ (
    LEFTARG = int2,
    RIGHTARG = int2,
    FUNCTION = sys.int2xor,
    COMMUTATOR = ^
);

CREATE OR REPLACE FUNCTION sys.intxor(leftarg int4, rightarg int4)
RETURNS int4
AS $$
SELECT CAST(sys.bitxor(CAST(leftarg AS pg_catalog.bit(32)),
                    CAST(rightarg AS pg_catalog.bit(32))) AS int4)
$$
LANGUAGE SQL STABLE;

CREATE OPERATOR sys.^ (
    LEFTARG = int4,
    RIGHTARG = int4,
    FUNCTION = sys.intxor,
    COMMUTATOR = ^
);

CREATE OR REPLACE FUNCTION sys.int8xor(leftarg int8, rightarg int8)
RETURNS int8
AS $$
SELECT CAST(sys.bitxor(CAST(leftarg AS pg_catalog.bit(64)),
                    CAST(rightarg AS pg_catalog.bit(64))) AS int8)
$$
LANGUAGE SQL STABLE;

CREATE OPERATOR sys.^ (
    LEFTARG = int8,
    RIGHTARG = int8,
    FUNCTION = sys.int8xor,
    COMMUTATOR = ^
);

-- tinyint cast definitions

-- tinyint smallint

CREATE OR REPLACE FUNCTION sys.smalint_to_tinyint(SMALLINT)
RETURNS sys.TINYINT
AS 'babelfishpg_common', 'smalint_to_tinyint'
LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE CAST (SMALLINT AS sys.TINYINT)
WITH FUNCTION sys.smalint_to_tinyint(SMALLINT) AS IMPLICIT;

CREATE CAST (sys.TINYINT AS SMALLINT)
WITHOUT FUNCTION AS IMPLICIT;

-- tinyint int

CREATE OR REPLACE FUNCTION sys.int2tinyint(INTEGER)
RETURNS sys.TINYINT
AS $$
  SELECT $1::SMALLINT;
$$
LANGUAGE SQL IMMUTABLE STRICT PARALLEL SAFE;

CREATE CAST (INTEGER AS sys.TINYINT)
WITH FUNCTION sys.int2tinyint (INTEGER) AS IMPLICIT;

CREATE OR REPLACE FUNCTION sys.tinyint2int(sys.TINYINT)
RETURNS INTEGER
AS $$
  SELECT $1::SMALLINT;
$$
LANGUAGE SQL IMMUTABLE STRICT PARALLEL SAFE;

CREATE CAST (sys.TINYINT AS INTEGER)
WITH FUNCTION sys.tinyint2int (sys.TINYINT) AS IMPLICIT;

-- tinyint - bigint

CREATE OR REPLACE FUNCTION sys.bigint2tinyint(BIGINT)
RETURNS sys.TINYINT
AS $$
  SELECT $1::SMALLINT;
$$
LANGUAGE SQL IMMUTABLE STRICT PARALLEL SAFE;

CREATE CAST (BIGINT AS sys.TINYINT)
WITH FUNCTION sys.bigint2tinyint (BIGINT) AS IMPLICIT;

CREATE OR REPLACE FUNCTION sys.tinyint2bigint(sys.TINYINT)
RETURNS BIGINT
AS $$
  SELECT $1::SMALLINT;
$$
LANGUAGE SQL IMMUTABLE STRICT PARALLEL SAFE;

CREATE CAST (sys.TINYINT AS BIGINT)
WITH FUNCTION sys.tinyint2bigint (sys.TINYINT) AS IMPLICIT;

-- tinyint - numeric

CREATE OR REPLACE FUNCTION sys.numeric2tinyint(NUMERIC)
RETURNS sys.TINYINT
AS $$
  SELECT TRUNC($1)::SMALLINT;
$$
LANGUAGE SQL IMMUTABLE STRICT PARALLEL SAFE;

CREATE CAST (NUMERIC AS sys.TINYINT)
WITH FUNCTION sys.numeric2tinyint (NUMERIC) AS IMPLICIT;

CREATE OR REPLACE FUNCTION sys.tinyint2numeric(sys.TINYINT)
RETURNS NUMERIC
AS $$
  SELECT $1::SMALLINT;
$$
LANGUAGE SQL IMMUTABLE STRICT PARALLEL SAFE;

CREATE CAST (sys.TINYINT AS NUMERIC)
WITH FUNCTION sys.tinyint2numeric (sys.TINYINT) AS IMPLICIT;

-- tinyint - float

CREATE OR REPLACE FUNCTION sys.float2tinyint(FLOAT)
RETURNS sys.TINYINT
AS $$
  SELECT TRUNC($1)::SMALLINT;
$$
LANGUAGE SQL IMMUTABLE STRICT PARALLEL SAFE;

CREATE CAST (FLOAT AS sys.TINYINT)
WITH FUNCTION sys.float2tinyint (FLOAT) AS IMPLICIT;

CREATE OR REPLACE FUNCTION sys.tinyint2float(sys.TINYINT)
RETURNS FLOAT
AS $$
  SELECT $1::SMALLINT;
$$
LANGUAGE SQL IMMUTABLE STRICT PARALLEL SAFE;

CREATE CAST (sys.TINYINT AS FLOAT)
WITH FUNCTION sys.tinyint2float (sys.TINYINT) AS IMPLICIT;

-- tinyint - real

CREATE OR REPLACE FUNCTION sys.real2tinyint(REAL)
RETURNS sys.TINYINT
AS $$
  SELECT TRUNC($1)::SMALLINT;
$$
LANGUAGE SQL IMMUTABLE STRICT PARALLEL SAFE;

CREATE CAST (REAL AS sys.TINYINT)
WITH FUNCTION sys.real2tinyint (REAL) AS IMPLICIT;

CREATE OR REPLACE FUNCTION sys.tinyint2real(sys.TINYINT)
RETURNS REAL
AS $$
  SELECT $1::SMALLINT;
$$
LANGUAGE SQL IMMUTABLE STRICT PARALLEL SAFE;

CREATE CAST (sys.TINYINT AS REAL)
WITH FUNCTION sys.tinyint2real(sys.TINYINT) AS IMPLICIT;

-- tinyint - fixeddecimal

CREATE OR REPLACE FUNCTION sys.fixeddecimal2tinyint(sys.FIXEDDECIMAL)
RETURNS sys.TINYINT
AS $$
  SELECT ROUND($1)::SMALLINT;
$$
LANGUAGE SQL IMMUTABLE STRICT PARALLEL SAFE;

CREATE CAST (sys.FIXEDDECIMAL AS sys.TINYINT)
WITH FUNCTION sys.fixeddecimal2tinyint (sys.FIXEDDECIMAL) AS IMPLICIT;

CREATE OR REPLACE FUNCTION sys.tinyint2fixeddecimal(sys.TINYINT)
RETURNS sys.FIXEDDECIMAL
AS $$
  SELECT $1::SMALLINT;
$$
LANGUAGE SQL IMMUTABLE STRICT PARALLEL SAFE;

CREATE CAST (sys.TINYINT AS sys.FIXEDDECIMAL)
WITH FUNCTION sys.tinyint2fixeddecimal (sys.TINYINT) AS IMPLICIT;

-- tinyint - varchar

CREATE OR REPLACE FUNCTION sys.varchar2tinyint(sys.VARCHAR)
RETURNS sys.TINYINT
AS 'babelfishpg_common', 'varchar2tinyint'
LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE CAST (sys.VARCHAR AS sys.TINYINT)
WITH FUNCTION sys.varchar2tinyint(sys.VARCHAR) AS IMPLICIT;

CREATE OR REPLACE FUNCTION sys.tinyint2varchar(sys.TINYINT)
RETURNS sys.VARCHAR
AS $$
  SELECT $1::SMALLINT;
$$
LANGUAGE SQL IMMUTABLE STRICT PARALLEL SAFE;

CREATE CAST (sys.TINYINT AS sys.VARCHAR)
WITH FUNCTION sys.tinyint2varchar(sys.TINYINT) AS IMPLICIT;

-- tinyint - jsonb

CREATE OR REPLACE FUNCTION sys.jsonb2tinyint(JSONB)
RETURNS sys.TINYINT
AS $$
  SELECT $1::SMALLINT;
$$
LANGUAGE SQL IMMUTABLE STRICT PARALLEL SAFE;

CREATE CAST (JSONB AS sys.TINYINT)
WITH FUNCTION sys.jsonb2tinyint (JSONB) AS ASSIGNMENT;

-- tinyint operator definitions to force return type to tinyint

CREATE FUNCTION sys.tinyinteq(sys.TINYINT, sys.TINYINT)
RETURNS bool
AS 'babelfishpg_common', 'tinyint_eq'
LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION sys.tinyintne(sys.TINYINT, sys.TINYINT)
RETURNS bool
AS 'babelfishpg_common', 'tinyint_ne'
LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION sys.tinyintlt(sys.TINYINT, sys.TINYINT)
RETURNS bool
AS 'babelfishpg_common', 'tinyint_lt'
LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION sys.tinyintle(sys.TINYINT, sys.TINYINT)
RETURNS bool
AS 'babelfishpg_common', 'tinyint_le'
LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION sys.tinyintgt(sys.TINYINT, sys.TINYINT)
RETURNS bool
AS 'babelfishpg_common', 'tinyint_gt'
LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION sys.tinyintge(sys.TINYINT, sys.TINYINT)
RETURNS bool
AS 'babelfishpg_common', 'tinyint_ge'
LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE OPERATOR sys.= (
    LEFTARG    = sys.TINYINT,
    RIGHTARG   = sys.TINYINT,
    COMMUTATOR = =,
    NEGATOR    = <>,
    PROCEDURE  = sys.tinyinteq,
    RESTRICT   = eqsel,
    JOIN       = eqjoinsel,
    MERGES
);

CREATE OPERATOR sys.<> (
    LEFTARG    = sys.TINYINT,
    RIGHTARG   = sys.TINYINT,
    NEGATOR    = =,
    COMMUTATOR = <>,
    PROCEDURE  = sys.tinyintne,
    RESTRICT   = neqsel,
    JOIN       = neqjoinsel
);

CREATE OPERATOR sys.< (
    LEFTARG    = sys.TINYINT,
    RIGHTARG   = sys.TINYINT,
    NEGATOR    = >=,
    COMMUTATOR = >,
    PROCEDURE  = sys.tinyintlt,
    RESTRICT   = scalarltsel,
    JOIN       = scalarltjoinsel
);

CREATE OPERATOR sys.<= (
    LEFTARG    = sys.TINYINT,
    RIGHTARG   = sys.TINYINT,
    NEGATOR    = >,
    COMMUTATOR = >=,
    PROCEDURE  = sys.tinyintle,
    RESTRICT   = scalarlesel,
    JOIN       = scalarlejoinsel
);

CREATE OPERATOR sys.> (
    LEFTARG    = sys.TINYINT,
    RIGHTARG   = sys.TINYINT,
    NEGATOR    = <=,
    COMMUTATOR = <,
    PROCEDURE  = sys.tinyintgt,
    RESTRICT   = scalargtsel,
    JOIN       = scalargtjoinsel
);

CREATE OPERATOR sys.>= (
    LEFTARG    = sys.TINYINT,
    RIGHTARG   = sys.TINYINT,
    NEGATOR    = <,
    COMMUTATOR = <=,
    PROCEDURE  = sys.tinyintge,
    RESTRICT   = scalargesel,
    JOIN       = scalargejoinsel
);

CREATE FUNCTION tinyint_cmp(sys.TINYINT, sys.TINYINT)
RETURNS INT4
AS 'babelfishpg_common', 'tinyint_cmp'
LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION tinyint_hash(sys.TINYINT)
RETURNS INT4
AS 'babelfishpg_common', 'tinyint_hash'
LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE OPERATOR CLASS sys.tinyint_ops
DEFAULT FOR TYPE sys.TINYINT USING btree AS
    OPERATOR    1   <  (sys.TINYINT, sys.TINYINT),
    OPERATOR    2   <= (sys.TINYINT, sys.TINYINT),
    OPERATOR    3   =  (sys.TINYINT, sys.TINYINT),
    OPERATOR    4   >= (sys.TINYINT, sys.TINYINT),
    OPERATOR    5   >  (sys.TINYINT, sys.TINYINT),
    FUNCTION    1   tinyint_cmp(sys.TINYINT, sys.TINYINT);

CREATE OPERATOR CLASS sys.tinyint_ops
DEFAULT FOR TYPE sys.TINYINT USING hash AS
    OPERATOR    1   =  (sys.TINYINT, sys.TINYINT),
    FUNCTION    1   tinyint_hash(sys.TINYINT);

CREATE OR REPLACE FUNCTION sys.tinyint_larger(sys.TINYINT, sys.TINYINT)
RETURNS sys.TINYINT
AS 'babelfishpg_common', 'tinyint_larger'
LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE OR REPLACE FUNCTION sys.tinyint_smaller(sys.TINYINT, sys.TINYINT)
RETURNS sys.TINYINT
AS 'babelfishpg_common', 'tinyint_smaller'
LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE OR REPLACE AGGREGATE sys.max(sys.TINYINT)
(
    sfunc = sys.tinyint_larger,
    stype = sys.tinyint,
    combinefunc = sys.tinyint_larger,
    parallel = safe
);

CREATE OR REPLACE AGGREGATE sys.min(sys.TINYINT)
(
    sfunc = sys.tinyint_smaller,
    stype = sys.tinyint,
    combinefunc = sys.tinyint_smaller,
    parallel = safe
);

CREATE OR REPLACE FUNCTION sys.tinyintand(sys.TINYINT, sys.TINYINT)
RETURNS sys.TINYINT
AS 'babelfishpg_common', 'tinyintand'
LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE OR REPLACE FUNCTION sys.tinyintor(sys.TINYINT, sys.TINYINT)
RETURNS sys.TINYINT
AS 'babelfishpg_common', 'tinyintor'
LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE OR REPLACE FUNCTION sys.tinyintxor(sys.TINYINT, sys.TINYINT)
RETURNS sys.TINYINT
AS 'babelfishpg_common', 'tinyintxor'
LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE OR REPLACE FUNCTION sys.tinyintnot(sys.TINYINT)
RETURNS sys.TINYINT
AS 'babelfishpg_common', 'tinyintnot'
LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE OPERATOR sys.& (
    LEFTARG = sys.TINYINT,
    RIGHTARG = sys.TINYINT,
    FUNCTION = sys.tinyintand,
    COMMUTATOR = &
);

CREATE OPERATOR sys.| (
    LEFTARG = sys.TINYINT,
    RIGHTARG = sys.TINYINT,
    FUNCTION = sys.tinyintor,
    COMMUTATOR = |
);

CREATE OPERATOR sys.^ (
    LEFTARG = sys.TINYINT,
    RIGHTARG = sys.TINYINT,
    FUNCTION = sys.tinyintxor,
    COMMUTATOR = ^
);

CREATE OPERATOR sys.~ (
    RIGHTARG   = sys.TINYINT,
    PROCEDURE  = sys.tinyintnot
);

CREATE FUNCTION sys.tinyintup(sys.TINYINT)
RETURNS sys.TINYINT
AS 'babelfishpg_common', 'tinyintup'
LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION sys.tinyintum(sys.TINYINT)
RETURNS SMALLINT
AS 'babelfishpg_common', 'tinyintum'
LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE OPERATOR sys.+ (
    RIGHTARG   = sys.TINYINT,
    PROCEDURE  = sys.tinyintup
);

CREATE OPERATOR sys.- (
    RIGHTARG   = sys.TINYINT,
    PROCEDURE  = sys.tinyintum
);

CREATE FUNCTION sys.tinyintpl(sys.TINYINT, sys.TINYINT)
RETURNS sys.TINYINT
AS $$
  SELECT int2pl($1,$2)::sys.TINYINT;
$$
LANGUAGE SQL IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION sys.tinyintmi(sys.TINYINT, sys.TINYINT)
RETURNS sys.TINYINT
AS $$
  SELECT int2mi($1,$2)::sys.TINYINT;
$$
LANGUAGE SQL IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION sys.tinyintmul(sys.TINYINT, sys.TINYINT)
RETURNS sys.TINYINT
AS $$
  SELECT int2mul($1,$2)::sys.TINYINT;
$$
LANGUAGE SQL IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION sys.tinyintdiv(sys.TINYINT, sys.TINYINT)
RETURNS sys.TINYINT
AS $$
  SELECT int2div($1,$2)::sys.TINYINT;
$$
LANGUAGE SQL IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION sys.tinyintmod(sys.TINYINT, sys.TINYINT)
RETURNS sys.TINYINT
AS $$
  SELECT int2mod($1,$2)::sys.TINYINT;
$$
LANGUAGE SQL IMMUTABLE STRICT PARALLEL SAFE;

CREATE OPERATOR sys.+ (
    LEFTARG    = sys.TINYINT,
    RIGHTARG   = sys.TINYINT,
    COMMUTATOR = +,
    PROCEDURE  = sys.tinyintpl
);

CREATE OPERATOR sys.- (
    LEFTARG    = sys.TINYINT,
    RIGHTARG   = sys.TINYINT,
    PROCEDURE  = sys.tinyintmi
);

CREATE OPERATOR sys.* (
    LEFTARG    = sys.TINYINT,
    RIGHTARG   = sys.TINYINT,
    COMMUTATOR = *,
    PROCEDURE  = sys.tinyintmul
);

CREATE OPERATOR sys./ (
    LEFTARG    = sys.TINYINT,
    RIGHTARG   = sys.TINYINT,
    PROCEDURE  = sys.tinyintdiv
);

CREATE OPERATOR sys.% (
    LEFTARG    = sys.TINYINT,
    RIGHTARG   = sys.TINYINT,
    PROCEDURE  = sys.tinyintmod
);

-- tinyint - int

CREATE FUNCTION sys.tinyinteqint(sys.TINYINT, INTEGER)
RETURNS BOOL
AS $$
  SELECT $1::SMALLINT = $2;
$$
LANGUAGE SQL IMMUTABLE STRICT PARALLEL SAFE;

CREATE OPERATOR sys.= (
    LEFTARG    = sys.TINYINT,
    RIGHTARG   = INTEGER,
    COMMUTATOR = =,
    PROCEDURE  = sys.tinyinteqint
);

CREATE FUNCTION sys.inteqtinyint(INTEGER, sys.TINYINT)
RETURNS BOOL
AS $$
  SELECT $1 = $2::SMALLINT;
$$
LANGUAGE SQL IMMUTABLE STRICT PARALLEL SAFE;

CREATE OPERATOR sys.= (
    LEFTARG    = INTEGER,
    RIGHTARG   = sys.TINYINT,
    COMMUTATOR = =,
    PROCEDURE  = sys.inteqtinyint
);

CREATE FUNCTION sys.intneqtinyint(INTEGER, sys.TINYINT)
RETURNS BOOL
AS $$
  SELECT $1 <> $2::SMALLINT;
$$
LANGUAGE SQL IMMUTABLE STRICT PARALLEL SAFE;

CREATE OPERATOR sys.<> (
    LEFTARG    = INTEGER,
    RIGHTARG   = sys.TINYINT,
    COMMUTATOR = <>,
    PROCEDURE  = sys.intneqtinyint
);

CREATE FUNCTION sys.tinyintneqint(sys.TINYINT, INTEGER)
RETURNS BOOL
AS $$
  SELECT $1::SMALLINT <> $2;
$$
LANGUAGE SQL IMMUTABLE STRICT PARALLEL SAFE;

CREATE OPERATOR sys.<> (
    LEFTARG    = sys.TINYINT,
    RIGHTARG   = INTEGER,
    COMMUTATOR = <>,
    PROCEDURE  = sys.tinyintneqint
);

CREATE FUNCTION sys.tinyintltint(sys.TINYINT, INTEGER)
RETURNS BOOL
AS $$
  SELECT $1::SMALLINT < $2;
$$
LANGUAGE SQL IMMUTABLE STRICT PARALLEL SAFE;

CREATE OPERATOR sys.< (
    LEFTARG    = sys.TINYINT,
    RIGHTARG   = INTEGER,
    COMMUTATOR = <,
    PROCEDURE  = sys.tinyintltint
);

CREATE FUNCTION sys.intlttinyint(INTEGER, sys.TINYINT)
RETURNS BOOL
AS $$
  SELECT $1 < $2::SMALLINT;
$$
LANGUAGE SQL IMMUTABLE STRICT PARALLEL SAFE;

CREATE OPERATOR sys.< (
    LEFTARG    = INTEGER,
    RIGHTARG   = sys.TINYINT,
    COMMUTATOR = <,
    PROCEDURE  = sys.intlttinyint
);

-- tinyint - numeric
CREATE FUNCTION sys.tinyintdivnumeric(sys.TINYINT, NUMERIC)
RETURNS NUMERIC
AS $$
  SELECT int2div($1,$2::SMALLINT)::NUMERIC;
$$
LANGUAGE SQL IMMUTABLE STRICT PARALLEL SAFE;

CREATE OPERATOR sys./ (
    LEFTARG    = sys.TINYINT,
    RIGHTARG   = NUMERIC,
    PROCEDURE  = sys.tinyintdivnumeric
);

-- tinyint - smallmoney

CREATE FUNCTION sys.smallmoneytinyintpl(sys.SMALLMONEY, sys.TINYINT)
RETURNS sys.SMALLMONEY
AS $$
  SELECT sys.fixeddecimalint2pl($1,$2)::sys.SMALLMONEY;
$$
LANGUAGE SQL IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION sys.smallmoneytinyintmi(sys.SMALLMONEY, sys.TINYINT)
RETURNS sys.SMALLMONEY
AS $$
  SELECT sys.fixeddecimalint2mi($1,$2)::sys.SMALLMONEY;
$$
LANGUAGE SQL IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION sys.smallmoneytinyintmul(sys.SMALLMONEY, sys.TINYINT)
RETURNS sys.SMALLMONEY
AS $$
  SELECT sys.fixeddecimalint2mul($1,$2)::sys.SMALLMONEY;
$$
LANGUAGE SQL IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION sys.smallmoneytinyintdiv(sys.SMALLMONEY, sys.TINYINT)
RETURNS sys.SMALLMONEY
AS $$
  SELECT sys.fixeddecimalint2div($1,$2)::sys.SMALLMONEY;
$$
LANGUAGE SQL IMMUTABLE STRICT PARALLEL SAFE;

CREATE OPERATOR sys.+ (
    LEFTARG    = sys.SMALLMONEY,
    RIGHTARG   = sys.TINYINT,
    COMMUTATOR = +,
    PROCEDURE  = sys.smallmoneytinyintpl
);

CREATE OPERATOR sys.- (
    LEFTARG    = sys.SMALLMONEY,
    RIGHTARG   = sys.TINYINT,
    PROCEDURE  = sys.smallmoneytinyintmi
);

CREATE OPERATOR sys.* (
    LEFTARG    = sys.SMALLMONEY,
    RIGHTARG   = sys.TINYINT,
    COMMUTATOR = *,
    PROCEDURE  = sys.smallmoneytinyintmul
);

CREATE OPERATOR sys./ (
    LEFTARG    = sys.SMALLMONEY,
    RIGHTARG   = sys.TINYINT,
    PROCEDURE  = sys.smallmoneytinyintdiv
);

CREATE FUNCTION sys.tinyintsmallmoneypl(sys.TINYINT, sys.SMALLMONEY)
RETURNS sys.SMALLMONEY
AS $$
  SELECT sys.int2fixeddecimalpl($1,$2)::sys.SMALLMONEY;
$$
LANGUAGE SQL IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION sys.tinyintsmallmoneymi(sys.TINYINT, sys.SMALLMONEY)
RETURNS sys.SMALLMONEY
AS $$
  SELECT sys.int2fixeddecimalmi($1,$2)::sys.SMALLMONEY;
$$
LANGUAGE SQL IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION sys.tinyintsmallmoneymul(sys.TINYINT, sys.SMALLMONEY)
RETURNS sys.SMALLMONEY
AS $$
  SELECT sys.int2fixeddecimalmul($1,$2)::sys.SMALLMONEY;
$$
LANGUAGE SQL IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION sys.tinyintsmallmoneydiv(sys.TINYINT, sys.SMALLMONEY)
RETURNS sys.SMALLMONEY
AS $$
  SELECT sys.int2fixeddecimaldiv($1,$2)::sys.SMALLMONEY;
$$
LANGUAGE SQL IMMUTABLE STRICT PARALLEL SAFE;

CREATE OPERATOR sys.+ (
    LEFTARG    = sys.TINYINT,
    RIGHTARG   = sys.SMALLMONEY,
    COMMUTATOR = +,
    PROCEDURE  = sys.tinyintsmallmoneypl
);

CREATE OPERATOR sys.- (
    LEFTARG    = sys.TINYINT,
    RIGHTARG   = sys.SMALLMONEY,
    PROCEDURE  = sys.tinyintsmallmoneymi
);

CREATE OPERATOR sys.* (
    LEFTARG    = sys.TINYINT,
    RIGHTARG   = sys.SMALLMONEY,
    COMMUTATOR = *,
    PROCEDURE  = sys.tinyintsmallmoneymul
);

CREATE OPERATOR sys./ (
    LEFTARG    = sys.TINYINT,
    RIGHTARG   = sys.SMALLMONEY,
    PROCEDURE  = sys.tinyintsmallmoneydiv
);


-- function definition on REAL datatype to force return type to REAL

CREATE OR REPLACE FUNCTION sys.real_larger(sys.REAL, sys.REAL)
RETURNS sys.REAL
AS 'float4larger'
LANGUAGE INTERNAL IMMUTABLE STRICT PARALLEL SAFE;

CREATE OR REPLACE FUNCTION sys.real_smaller(sys.REAL, sys.REAL)
RETURNS sys.REAL
AS 'float4smaller'
LANGUAGE INTERNAL IMMUTABLE STRICT PARALLEL SAFE;

CREATE OR REPLACE AGGREGATE sys.max(sys.REAL)
(
    sfunc = sys.real_larger,
    stype = sys.real,
    combinefunc = sys.real_larger,
    parallel = safe
);

CREATE OR REPLACE AGGREGATE sys.min(sys.REAL)
(
    sfunc = sys.real_smaller,
    stype = sys.real,
    combinefunc = sys.real_smaller,
    parallel = safe
);

CREATE OR REPLACE FUNCTION sys.bigint_sum(INTERNAL)
RETURNS BIGINT
AS 'babelfishpg_common', 'bigint_sum'
LANGUAGE C IMMUTABLE PARALLEL SAFE;

CREATE OR REPLACE FUNCTION sys.bigint_avg(INTERNAL)
RETURNS BIGINT
AS 'babelfishpg_common', 'bigint_avg'
LANGUAGE C IMMUTABLE PARALLEL SAFE;

CREATE OR REPLACE FUNCTION sys.int4int2_sum(BIGINT)
RETURNS INT
AS 'babelfishpg_common' , 'int4int2_sum'
LANGUAGE C IMMUTABLE PARALLEL SAFE;

CREATE OR REPLACE FUNCTION sys.int4int2_avg(pg_catalog._int8)
RETURNS INT
AS 'babelfishpg_common', 'int4int2_avg'
LANGUAGE C IMMUTABLE PARALLEL SAFE;



CREATE OR REPLACE AGGREGATE sys.sum(BIGINT) (
SFUNC = int8_avg_accum,
FINALFUNC = bigint_sum,
STYPE = INTERNAL,
COMBINEFUNC = int8_avg_combine,
SERIALFUNC = int8_avg_serialize,
DESERIALFUNC = int8_avg_deserialize,
PARALLEL = SAFE
);


CREATE OR REPLACE AGGREGATE sys.sum(INT)(
SFUNC = int4_sum,
FINALFUNC = int4int2_sum,
STYPE = int8,
COMBINEFUNC = int8pl,
PARALLEL = SAFE
);

CREATE OR REPLACE AGGREGATE sys.sum(SMALLINT)(
SFUNC = int2_sum,
FINALFUNC = int4int2_sum,
STYPE = int8,
COMBINEFUNC = int8pl,
PARALLEL = SAFE
);

CREATE OR REPLACE AGGREGATE sys.sum(TINYINT)(
SFUNC = int2_sum,
FINALFUNC = int4int2_sum,
STYPE = int8,
COMBINEFUNC = int8pl,
PARALLEL = SAFE
);

CREATE OR REPLACE AGGREGATE sys.avg(TINYINT)(
SFUNC = int2_avg_accum,
FINALFUNC = int4int2_avg,
STYPE = _int8,
COMBINEFUNC = int4_avg_combine,
PARALLEL = SAFE,
INITCOND='{0,0}'
);

CREATE OR REPLACE AGGREGATE sys.avg(SMALLINT)(
SFUNC = int2_avg_accum,
FINALFUNC = int4int2_avg,
STYPE = _int8,
COMBINEFUNC = int4_avg_combine,
PARALLEL = SAFE,
INITCOND='{0,0}'
);

CREATE OR REPLACE AGGREGATE sys.avg(INT)(
SFUNC = int4_avg_accum,
FINALFUNC = int4int2_avg,
STYPE = _int8,
COMBINEFUNC = int4_avg_combine,
PARALLEL = SAFE,
INITCOND='{0,0}'
);

CREATE OR REPLACE AGGREGATE sys.avg(BIGINT) (
SFUNC = int8_avg_accum,
FINALFUNC = bigint_avg,
STYPE = INTERNAL,
COMBINEFUNC = int8_avg_combine,
SERIALFUNC = int8_avg_serialize,
DESERIALFUNC = int8_avg_deserialize,
PARALLEL = SAFE
);