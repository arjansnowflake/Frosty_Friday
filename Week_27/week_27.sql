--This is my solution to Frosty Friday week 27, as found at https://frostyfriday.org/2022/12/16/week-27-beginner/

--First, assigne the right resources
use database frostyfriday;
use schema public;
use warehouse compute_wh;

create or replace table frostyfriday.public.week27 
(
    icecream_id int,
    icecream_flavour varchar(15),
    icecream_manufacturer varchar(50),
    icecream_brand varchar(50),
    icecreambrandowner varchar(50),
    milktype varchar(15),
    region_of_origin varchar(50),
    recomendad_price number,
    wholesale_price number
);

insert into frostyfriday.public.week27 values
    (1, 'strawberry', 'Jimmy Ice', 'Ice Co.', 'Food Brand Inc.', 'normal', 'Midwest', 7.99, 5),
    (2, 'vanilla', 'Kelly Cream Company', 'Ice Co.', 'Food Brand Inc.', 'dna-modified', 'Northeast', 3.99, 2.5),
    (3, 'chocolate', 'ChoccyCream', 'Ice Co.', 'Food Brand Inc.', 'normal', 'Midwest', 8.99, 5.5);

select *
    exclude milktype
    rename icecreambrandowner as ice_cream_brand_owner
     from week27;
