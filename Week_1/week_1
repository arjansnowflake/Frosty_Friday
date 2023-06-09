//this is my solution to Frosty Friday Week 1, as found at https://frostyfriday.org/2022/07/14/week-1/
//note, this might look like a nice and structured list of commands, but especially the first part relating to
//stages, fileformats and inspecting the files in the stage have been a process of iteration

//first we create a database and use it for our commands
CREATE DATABASE FrostyFriday;
USE DATABASE FrostyFriday;

//if not already done previously, set the auto_suspend of the warehouse to minimum
ALTER warehouse COMPUTE_WH
   SET AUTO_SUSPEND = 60;

//we need a file format first to inspect the csv files in the bucket
//just go with the default and see if we need to change it
create or replace file format Frosty_challenge_1
    TYPE = 'CSV'
    comment = 'file_format associated with Frosty Friday challenge #1';

//create the external stage with provided url and our created file format
CREATE OR replace STAGE FrostyFriday_Inc
    URL = 's3://frostyfridaychallenges/challenge_1/'
    FILE_FORMAT = (FORMAT_NAME = 'Frosty_challenge_1')
    COMMENT = 'stage for loading FrostyFriday files';

//just checking...
SHOW STAGES;

//have a look at the files in the stage
LIST @FROSTYFRIDAY_INC;

// let's have a look at the contents of the csv's
SELECT $1,$2, $3
FROM @FrostyFriday_Inc/2.csv (file_format => Frosty_challenge_1);

//file format seems ok, no changes needed

//now we've seen he structure of the csv files, let's create a table to copy into
create or replace table challenge_1
    (kolom_een varchar(50));

//just checking...
select * from challenge_1;

//now, let's copy the content from the files in the stage into the table
copy into frostyfriday.public.challenge_1
    from @FrostyFriday_Inc
    pattern = '.*.csv'
    file_format = 'Frosty_challenge_1';

//check the result of our copy_into command
select * from challenge_1;

//voila!
