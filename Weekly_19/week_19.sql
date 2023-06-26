--This is my solution to Frosty Friday week 19, as found at https://frostyfriday.org/2022/10/21/week-19-basic/

--First, assigne the right resources
use database frostyfriday;
use schema public;
use warehouse compute_wh;

--enabling week_of_year_policy sets the week number of 2000-01-01 to 1 (in stead of 52, in this particular case)
ALTER SESSION SET WEEK_OF_YEAR_POLICY = 1;

--second attempt at the dimension table, after reading two solutions

    --get number of rows to generate (date at time of challenge wat 2023-06-26)
    --setting a variable using datediff does not work, so copy-pasting from query results here...
select datediff(days, ' 2000-01-01', current_date) + 1;

    --create dimension table
create or replace table MY_DATE_DIMENSION as
select dateadd(day, (row_number() over (order by null))-1, '2000-01-01') as date
        , year(date) as year
        , monthname(date) as month_short
        , TO_CHAR(date,'MMMM')as month_long
        , DAYOFMONTH(date) as day_of_month
        , DAYOFWEEK(date)as day_of_week 
        , WEEKOFYEAR(date)as week_of_year 
        , DAYOFYEAR(date) as day_of_year 
from table(generator(rowcount => 8578));

  --just checking...
select * from MY_DATE_DIMENSION;

--this was my first attempt, not knowing enough about the 'create as' methodology (did not get referring to the 'date' column for the other calculations to work)

/*create or replace table MY_DATE_DIMENSION (
--get the number of days between 2000-01-01 and today, as GENERATOR only accepts constants for row count, not variables
select datediff(day, '2000-01-01', current_date) + 1;
--create dimension table with dates, the rest with default values
date DATE,
year VARCHAR,
month_short VARCHAR,
month_long VARCHAR,
day_of_month VARCHAR,
day_of_week VARCHAR,
week_of_year VARCHAR,
day_of_year VARCHAR
) AS
SELECT dateadd(day, seq4(), '2000-01-01'::date), 2000, 'Jan', 'January', 1, 1, 1, 1
  FROM TABLE(GENERATOR(ROWCOUNT => 8578)) v
  ORDER BY 1;
--update the default values with correct values
update MY_DATE_DIMENSION
set year = date_part(year, date),
    month_short = monthname(date),
    month_long = TO_CHAR(date,'MMMM'),
    day_of_month = DAYOFMONTH(date),
    day_of_week = DAYOFWEEK(date),
    week_of_year = WEEKOFYEAR(date),
    day_of_year = DAYOFYEAR(date);
*/

--second attempt at the function, after reading two solutions
CREATE OR REPLACE FUNCTION calculate_business_days(start_date date, end_date date, including BOOLEAN)
    RETURNS INT
AS
$$
    select count(*)
    from MY_DATE_DIMENSION
    --we know 2000-01-01 is a saturday, and 2000-01-02 is sunday, and I wanted to make this session-agnostic, so:
    where day_of_week not in (dayofweek('2000-01-01'::date), dayofweek('2000-01-02'::date))
    and date between start_date and (end_date - IFF(including, 0, 1))
$$;

/*
--first attempt at the function, this one does not take into account the switching end date for including/excluding when counting saturdays and sundays to subtract
CREATE OR REPLACE FUNCTION calculate_business_days(start_date date, end_date date, including BOOLEAN)
  RETURNS INT
  AS
  $$
    datediff(day, start_date, end_date) + IFF(including, 1, 0) - (select count(date) from MY_DATE_DIMENSION where date >= start_date and date <= end_date
        and day_of_week in (dayofweek('2000-01-01'::date), dayofweek('2000-01-02'::date)))
  $$
  ;
  */

--calling this function with 'from MY_DATE_DIMENSION' at the end renders tons of rows. Why is that in the example on the website? I need just one record to check...
select calculate_business_days('2020-11-2', '2020-11-6', true) AS including
, calculate_business_days('2020-11-2', '2020-11-6', false) AS excluding
--from MY_DATE_DIMENSION
;

create table testing_data (
id INT,
start_date DATE,
end_date DATE
);
insert into testing_data (id, start_date, end_date) values (1, '11/11/2020', '9/3/2022');
insert into testing_data (id, start_date, end_date) values (2, '12/8/2020', '1/19/2022');
insert into testing_data (id, start_date, end_date) values (3, '12/24/2020', '1/15/2022');
insert into testing_data (id, start_date, end_date) values (4, '12/5/2020', '3/3/2022');
insert into testing_data (id, start_date, end_date) values (5, '12/24/2020', '6/20/2022');
insert into testing_data (id, start_date, end_date) values (6, '12/24/2020', '5/19/2022');
insert into testing_data (id, start_date, end_date) values (7, '12/31/2020', '5/6/2022');
insert into testing_data (id, start_date, end_date) values (8, '12/4/2020', '9/16/2022');
insert into testing_data (id, start_date, end_date) values (9, '11/27/2020', '4/14/2022');
insert into testing_data (id, start_date, end_date) values (10, '11/20/2020', '1/18/2022');
insert into testing_data (id, start_date, end_date) values (11, '12/1/2020', '3/31/2022');
insert into testing_data (id, start_date, end_date) values (12, '11/30/2020', '7/5/2022');
insert into testing_data (id, start_date, end_date) values (13, '11/28/2020', '6/19/2022');
insert into testing_data (id, start_date, end_date) values (14, '12/21/2020', '9/7/2022');
insert into testing_data (id, start_date, end_date) values (15, '12/13/2020', '8/15/2022');
insert into testing_data (id, start_date, end_date) values (16, '11/4/2020', '3/22/2022');
insert into testing_data (id, start_date, end_date) values (17, '12/24/2020', '8/29/2022');
insert into testing_data (id, start_date, end_date) values (18, '11/29/2020', '10/13/2022');
insert into testing_data (id, start_date, end_date) values (19, '12/10/2020', '7/31/2022');
insert into testing_data (id, start_date, end_date) values (20, '11/1/2020', '10/23/2021');

--checking the function
select calculate_business_days(start_date, end_date, true) as including
, calculate_business_days(start_date, end_date, false) as excluding
from testing_data;
