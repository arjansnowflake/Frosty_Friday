
//This is my soluion to Frosty Friday Week 3, as found at https://frostyfriday.org/2022/07/15/week-3-basic/

//first, assign using the right resources
use warehouse compute_wh;
use database frostyfriday;
use schema public;

//just to be sure, create a csv file format
create or replace file format frosty_3
    type = 'CSV'
    comment = 'file_format associated with Frosty Friday challenge #3'
    skip_header = 1;

//create the external stage with provided url and created file format
create stage frosty_3
    URL = 's3://frostyfridaychallenges/challenge_3/'
    FILE_FORMAT = (FORMAT_NAME = 'frosty_3')
    COMMENT = 'stage for loading FrostyFriday files';

//for spotting, check which files are in the bucket
list @frosty_3;

//inspect keywords from the keywords file
select $1 from @frosty_3/keywords.csv;

//create the result table
CREATE OR REPLACE TABLE CHALLENGE_3_RESULT
(FILENAME varchar,
NUMBER_OF_ROWS number);

//just checking...
select * from challenge_3_result;

//since I misread the assignment and assumed I only needed to create a table that lists filenames, and not necessarily had to insert the files themselves into a table,
//I tried to query only directly from the files in the stage. Had to sift through snowflake docs and some solutions by others to get what I wanted.

INSERT INTO challenge_3_result --copy into only accepts simple select statements
(select METADATA$FILENAME FILENAME, count(*) NUMBER_OF_ROWS from @frosty_3
    where FILENAME like any (select '%' || $1 || '%' from @frosty_3/keywords.csv) --did not know of 'like any'; also did not know I needed a 'select' for concatenation in this context (plus, pipes for concat are great!)
    group by FILENAME
    ORDER BY NUMBER_OF_ROWS); --inserting them in the right order

//checking the results
select * from challenge_3_result; --results come back scrambled, darn...

//since I missed the part where I had to copy all the file content into a single table:

//file format for checking file content and column names
create or replace file format frosty_3_check
    type = 'CSV'
    comment = 'file_format associated with Frosty Friday challenge #3'
    skip_header = 0;

//inspect contents of a file
select $1, $2, $3, $4, $5, $6, $7 from @frosty_3/week3_data2_stacy_forgot_to_upload.csv (file_format => 'frosty_3_check');

//Creating the data table
CREATE OR REPLACE TABLE CHALLENGE_3_DATA
    (id number,
    first_name varchar,
    last_name varchar,
    catch_phrase varchar,
    timestamp date);

//just checking...
select * from challenge_3_data;

//checking the file names again
list @frosty_3;

//copy he right files into the table, matching with regex
COPY INTO challenge_3_data
FROM @frosty_3 pattern = '.*?week3_data.*?.csv';

//checking
select * from challenge_3_data;
