--this is my solution to Frosty Friday Week 5, as found at https://frostyfriday.org/2022/07/15/week-5-basic/

--first assign the right resources
use database FROSTYFRIDAY;
use schema PUBLIC;
use warehouse compute_wh;

--creating the table
CREATE TABLE FF_week_5
(start_int number);

--insert dummy values into table
insert into FF_week_5 values
(1),
(2),
(3),
(4),
(5),
(10),
(50),
(137);

--just checking
select * from FF_week_5;

--write the UDF
CREATE OR REPLACE FUNCTION timesthree(start_int int)
RETURNS INT
LANGUAGE PYTHON
RUNTIME_VERSION = '3.8'
HANDLER = 'timesthree_py'
as
$$
def timesthree_py(i):
    return i*3
$$;

--testing the UDF
SELECT timesthree(start_int)
FROM FF_week_5

