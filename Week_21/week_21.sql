--This is my solution to Frosty Friday week 21, as found at https://frostyfriday.org/2022/11/04/week-21-basic/

--First, assigne the right resources
use database frostyfriday;
use schema public;
use warehouse compute_wh;

--creating the initial table
create or replace table hero_powers (
hero_name VARCHAR(50),
flight VARCHAR(50),
laser_eyes VARCHAR(50),
invisibility VARCHAR(50),
invincibility VARCHAR(50),
psychic VARCHAR(50),
magic VARCHAR(50),
super_speed VARCHAR(50),
super_strength VARCHAR(50)
);
insert into hero_powers (hero_name, flight, laser_eyes, invisibility, invincibility, psychic, magic, super_speed, super_strength) values ('The Impossible Guard', '++', '-', '-', '-', '-', '-', '-', '+');
insert into hero_powers (hero_name, flight, laser_eyes, invisibility, invincibility, psychic, magic, super_speed, super_strength) values ('The Clever Daggers', '-', '+', '-', '-', '-', '-', '-', '++');
insert into hero_powers (hero_name, flight, laser_eyes, invisibility, invincibility, psychic, magic, super_speed, super_strength) values ('The Quick Jackal', '+', '-', '++', '-', '-', '-', '-', '-');
insert into hero_powers (hero_name, flight, laser_eyes, invisibility, invincibility, psychic, magic, super_speed, super_strength) values ('The Steel Spy', '-', '++', '-', '-', '+', '-', '-', '-');
insert into hero_powers (hero_name, flight, laser_eyes, invisibility, invincibility, psychic, magic, super_speed, super_strength) values ('Agent Thundering Sage', '++', '+', '-', '-', '-', '-', '-', '-');
insert into hero_powers (hero_name, flight, laser_eyes, invisibility, invincibility, psychic, magic, super_speed, super_strength) values ('Mister Unarmed Genius', '-', '-', '-', '-', '-', '-', '-', '-');
insert into hero_powers (hero_name, flight, laser_eyes, invisibility, invincibility, psychic, magic, super_speed, super_strength) values ('Doctor Galactic Spectacle', '-', '-', '-', '++', '-', '-', '-', '+');
insert into hero_powers (hero_name, flight, laser_eyes, invisibility, invincibility, psychic, magic, super_speed, super_strength) values ('Master Rapid Illusionist', '-', '-', '-', '-', '++', '-', '+', '-');
insert into hero_powers (hero_name, flight, laser_eyes, invisibility, invincibility, psychic, magic, super_speed, super_strength) values ('Galactic Gargoyle', '+', '-', '-', '-', '-', '-', '++', '-');
insert into hero_powers (hero_name, flight, laser_eyes, invisibility, invincibility, psychic, magic, super_speed, super_strength) values ('Alley Cat', '-', '++', '-', '-', '-', '-', '-', '+');

--just checking...
select * from hero_powers;

--first solution, with join
SELECT a.hero_name, a.main_power, b.secondary_power
FROM hero_powers a
   UNPIVOT ( value
             FOR main_power IN (FLIGHT, LASER_EYES, INVISIBILITY, INVINCIBILITY, PSYCHIC, MAGIC, SUPER_SPEED, SUPER_STRENGTH))
INNER JOIN hero_powers b
   UNPIVOT ( value
             FOR secondary_power IN (FLIGHT, LASER_EYES, INVISIBILITY, INVINCIBILITY, PSYCHIC, MAGIC, SUPER_SPEED, SUPER_STRENGTH))
ON a.hero_name = b.hero_name
WHERE a.value = '++' and b.value = '+'
;

--second solution, with union and grouped max values
/*
select hero_name, max(main_power) main_power, max(secondary_power) secondary_power from (
    SELECT hero_name, main_power, null as secondary_power
    FROM hero_powers
       UNPIVOT ( value
        FOR main_power IN (FLIGHT, LASER_EYES, INVISIBILITY, INVINCIBILITY, PSYCHIC, MAGIC, SUPER_SPEED, SUPER_STRENGTH))
    WHERE value = '++'
    UNION ALL
    SELECT hero_name, null, secondary_power
    FROM hero_powers
       UNPIVOT ( value
             FOR secondary_power IN (FLIGHT, LASER_EYES, INVISIBILITY, INVINCIBILITY, PSYCHIC, MAGIC, SUPER_SPEED, SUPER_STRENGTH))
    WHERE value = '+')
group by hero_name
;
*/

--third solution, after looking at solution by dsmdavid
/*
select hero_name, "'++'" as main_power, "'+'" as secondary_power
from (
    select hero_name, main_power, value
    from hero_powers
        UNPIVOT(value for main_power in (FLIGHT, LASER_EYES, INVISIBILITY, INVINCIBILITY, PSYCHIC, MAGIC, SUPER_SPEED, SUPER_STRENGTH))
    where value != '-'
    )
PIVOT(listagg(main_power) for value in ('++', '+'))
;
*/
