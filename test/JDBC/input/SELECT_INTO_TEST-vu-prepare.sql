-- create a new table select_into
create table select_into_pre_exist(select_into_pre_exist_COL int);
go
-- create a new function to double the value
CREATE FUNCTION dbo.select_into_double_function (@in INT) RETURNS INT
AS
BEGIN
    RETURN (2 * @in);
END;
go
select select_into_pre_exist_COL into select_into_pre_exist_repro from select_into_pre_exist;
go