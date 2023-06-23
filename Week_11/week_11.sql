--This is my solution to Frosty Friday week 11, as found at https://frostyfriday.org/2022/08/26/week-11-basic/

--First, assigne the right resources
use database frostyfriday;
use schema public;
use warehouse compute_wh;

--Create file format
CREATE OR REPLACE FILE FORMAT frosty_11
    TYPE = 'CSV'
    SKIP_HEADER = 1
    COMMENT = 'file format associated with Frosty Friday challenge #11';

--Create stage for csv loading
CREATE OR REPLACE stage frosty_11
    URL = 's3://frostyfridaychallenges/challenge_11/'
    FILE_FORMAT = frosty_11
    COMMENT = 'stage associated with Frosty Friday challenge #11';

--just checking
list @frosty_11;

--inspect contents of csv
select $1, $2, $3, $4, $5, $6 from @frosty_11/milk_data.csv;

-- Create the table as a CTAS statement.
create or replace table frostyfriday.public.week11 as
select m.$1 as milking_datetime,
        m.$2 as cow_number,
        m.$3 as fat_percentage,
        m.$4 as farm_code,
        m.$5 as centrifuge_start_time,
        m.$6 as centrifuge_end_time,
        m.$7 as centrifuge_kwph,
        m.$8 as centrifuge_electricity_used,
        m.$9 as centrifuge_processing_time,
        m.$10 as task_used
from @frosty_11 (file_format => 'frosty_11', pattern => '.*milk_data.*[.]csv') m;

--just checking...
select * from week11;

-- TASK 1: Remove all the centrifuge dates and centrifuge kwph and replace them with NULLs WHERE fat = 3. 
-- Add note to task_used.
create or replace task whole_milk_updates
    schedule = '1400 minutes'
as
    update frostyfriday.public.week11
        set CENTRIFUGE_START_TIME = NULL
            ,CENTRIFUGE_END_TIME = NULL
            ,CENTRIFUGE_KWPH = NULL
            ,TASK_USED = SYSTEM$CURRENT_USER_TASK_NAME() || ' at ' || current_timestamp()
        where week11.FAT_PERCENTAGE = 3;


-- TASK 2: Calculate centrifuge processing time (difference between start and end time) WHERE fat != 3. 
-- Add note to task_used.
create or replace task skim_milk_updates
    after frostyfriday.public.whole_milk_updates
as
    update week11
        set CENTRIFUGE_PROCESSING_TIME = datediff(minute, CENTRIFUGE_START_TIME, CENTRIFUGE_END_TIME)
            ,CENTRIFUGE_ELECTRICITY_USED = ((datediff(minute, CENTRIFUGE_START_TIME, CENTRIFUGE_END_TIME)/60) * CENTRIFUGE_KWPH)::NUMBER(10,2)
            ,TASK_USED = SYSTEM$CURRENT_USER_TASK_NAME()  || ' at ' || current_timestamp()
        where week11.FAT_PERCENTAGE != 3;

--make sure the tasks are actually running        
alter task whole_milk_updates resume;
alter task skim_milk_updates resume;

execute task whole_milk_updates;

--just checking...
select * from week11;
