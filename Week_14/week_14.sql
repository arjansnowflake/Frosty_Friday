--This is my solution to Frosty Friday week 14, as found at https://frostyfriday.org/2022/09/16/week-14-basic/

--First, assigne the right resources
use database frostyfriday;
use schema public;
use warehouse compute_wh;

--Create and fill table using the start-up code
CREATE OR REPLACE TABLE week_14 (
    superhero_name varchar(50),
    country_of_residence varchar(50),
    notable_exploits varchar(150),
    superpower varchar(100),
    second_superpower varchar(100),
    third_superpower varchar(100)
);

INSERT INTO week_14 VALUES ('Superpig', 'Ireland', 'Saved head of Irish Farmer\'s Association from terrorist cell', 'Super-Oinks', NULL, NULL);
INSERT INTO week_14 VALUES ('Señor Mediocre', 'Mexico', 'Defeated corrupt convention of fruit lobbyists by telling anecdote that lasted 33 hours, with 16 tangents that lead to 17 resignations from the board', 'Public speaking', 'Stamp collecting', 'Laser vision');
INSERT INTO week_14 VALUES ('The CLAW', 'USA', 'Horrifically violent duel to the death with mass murdering super villain accidentally created art installation last valued at $14,450,000 by Sotheby\'s', 'Back scratching', 'Extendable arms', NULL);
INSERT INTO week_14 VALUES ('Il Segreto', 'Italy', NULL, NULL, NULL, NULL);
INSERT INTO week_14 VALUES ('Frosty Man', 'UK', 'Rescued a delegation of data engineers from a DevOps conference', 'Knows, by memory, 15 definitions of an obscure codex known as "the data mesh"', 'can copy and paste from StackOverflow with the blink of an eye', NULL);

--Just checking...
select * from week_14;

--doodling
--first exploration leaves out the superhero without superpowers (because of the pivot)
/*SELECT superhero_name, country_of_residence, array_agg(superpowers) FROM week_14
    UNPIVOT(superpowers FOR power IN (superpower,second_superpower, third_superpower))
    group by superhero_name, country_of_residence;

--even so, trying out the object construct    
with Dinges as (SELECT superhero_name, country_of_residence, array_agg(superpowers) superpowers FROM week_14
    UNPIVOT(superpowers FOR power IN (superpower,second_superpower, third_superpower))
  group by superhero_name, country_of_residence)
                
select object_construct('country_or_residence', country_of_residence,
                        'superhero_name', superhero_name,
                        'superpowers', superpowers
                        ) from Dinges;

 
--trying out array_construct and object_construct
select superhero_name, country_of_residence, array_construct_compact(superpower,second_superpower, third_superpower) superpowers
from week_14;

select object_construct(superhero_name, country_of_residence, array_construct_compact(superpower,second_superpower, third_superpower)) as superhero_json
from week_14;
*/

--my actual solution, but this one shows the empty array as empty, not with 'undefined' for Il Segreto
select
to_json(
    object_construct(
        'country_of_residence', country_of_residence,
        'superhero_name', superhero_name,
        'superpowers', array_construct_compact(superpower,second_superpower, third_superpower)))
    as superhero_json
from week_14;

/*
I saw in other solutions I would need to use 'case when' or 'coalesce' to get 'undefined' in case of an empty array:

CASE WHEN superpower IS NULL THEN array_construct(superpower) ELSE array_construct_compact(superpower,second_superpower,third_superpower) END )

--so, if the first column is null... etc - reads easier, might be too much of a shortcut

coalesce(
          nullif(
              array_construct_compact(superpower, second_superpower, third_superpower)    --if this array
            , array_construct_compact(null)                                               --is equal to an empty array, return null
          )
          , array_construct(null)                                                         --which makes coalesce return a non-compact array (so with 'undefined')
        )

--this one reads a bit over-complicated, but would probably be more 'best practice'
*/
