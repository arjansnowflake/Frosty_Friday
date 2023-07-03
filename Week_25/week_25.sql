--This is my solution to Frosty Friday week 25, as found at https://frostyfriday.org/2022/11/30/week-25-beginner/

--First, assigne the right resources
use database frostyfriday;
use schema public;
use warehouse compute_wh;

--create the file format
create or replace file format frosty_25
    type = 'JSON'
    comment = 'file_format associated with Frosty Friday challenge #25';

--creat the stage
create stage frosty_25
    URL = 's3://frostyfridaychallenges/challenge_25/'
    FILE_FORMAT = frosty_25
    COMMENT = 'stage for loading FrostyFriday files';

--for spotting, check which files are in the bucket
list @frosty_25;

--inspect keywords from the keywords file
select * from @frosty_25/ber_7d_oct_clim.json;

--create the raw data table
create or replace table weather_raw
(JSON variant);

copy into frostyfriday.public.weather_raw
    from @frosty_25
    pattern = '.*.json'
    file_format = frosty_25;

--just checking
select * from weather_raw;
select json:weather from weather_raw;
SELECT value
  FROM
    weather_raw
  ,  LATERAL FLATTEN(INPUT => json:weather);

--create the parsed data table
create or replace table weather_parsed as
SELECT value:timestamp::datetime as date
        ,value:icon::varchar as icon
        ,value:temperature::float as temperature
        ,value:precipitation::float as precipitation
        ,value:wind_speed::float as wind
        ,value:relative_humidity::float as humidity
  FROM
    weather_raw
  ,  LATERAL FLATTEN(INPUT => json:weather);

--just checking
select * from weather_parsed;

--create aggregated data table
create or replace table weather_agg as
select date_trunc(day, date) as date
        ,array_agg(distinct(icon)) as icon_array
        ,avg(temperature)::float as avg_temperature
        ,sum(precipitation)::float as total_precipitation
        ,avg(wind)::float as avg_wind
        ,avg(humidity)::float as avg_humidity
from weather_parsed
group by date_trunc(day, date);

--just checking
select * from weather_agg
order by date desc;
--voilà!
