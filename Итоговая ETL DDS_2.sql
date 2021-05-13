create schema dds 

create schema rejected 

create schema stage

create table dds.Dim_Calendar -- справочник дат
AS
WITH dates AS (
    SELECT dd::date AS dt
    FROM generate_series
            ('2010-01-01'::timestamp
            , '2030-01-01'::timestamp
            , '1 day'::interval) dd
)
SELECT
    to_char(dt, 'YYYYMMDD')::int AS id,
    dt AS date,
    to_char(dt, 'YYYY-MM-DD') AS ansi_date,
    date_part('isodow', dt)::int AS day,
    date_part('week', dt)::int AS week_number,
    date_part('month', dt)::int AS month,
    date_part('isoyear', dt)::int AS year,
    (date_part('isodow', dt)::smallint BETWEEN 1 AND 5)::int AS week_day
    FROM dates
ORDER BY dt;

ALTER TABLE dds.Dim_Calendar ADD PRIMARY KEY (id);

drop table dds.Dim_Calendar

select * from dds.Dim_Calendar


create table dds.Dim_Passengers (-- справочник пассажиров. 
id serial not null primary key,
passenger_id varchar(20) not null, 
passenger_name varchar(20) not null,          
ticket_no bpchar
--contact_data json                             
)     

drop table dds.Dim_Passengers

create table rejected.Passengers (--таблица для "битых" данных о пассажирах
--id serial not null primary key,
passenger_id varchar, 
passenger_name varchar, 
ticket_no bpchar
--contact_data json
)


drop table rejected.Passengers

create table stage.Dim_Passengers (
--id serial not null primary key,
passenger_id varchar(20) not null, 
passenger_name varchar(20) not null,          
ticket_no bpchar
--contact_data json                             
)   

drop table stage.Dim_Passengers


create table dds.Dim_Aircrafts -- справочник самолетов
(aircraft_id serial primary key,
aircraft_code varchar(4) not null,
model varchar(50) not null, 
aircraft_range int not null)

drop table dds.Dim_Aircrafts 

create table rejected.Dim_Aircrafts -- справочник самолетов
(--aircraft_id serial primary key,
aircraft_code varchar,
model varchar, 
aircraft_range int)


drop table rejected.Dim_Aircrafts

create table stage.Dim_Aircrafts -- справочник самолетов
(--aircraft_id serial primary key,
aircraft_code varchar(4) not null,
model varchar(50) not null, 
aircraft_range int not null)

drop table stage.Dim_Aircrafts


create table dds.Dim_Airports -- справочник аэропортов
(airport_id serial primary key,
airport_code varchar (5) not null,
airport_name varchar(50) not null,
city varchar(100) not null 
--timezone varchar(100) not null
)

truncate dds.Dim_Airports


drop table dds.Dim_Airports

create table rejected.Dim_Airports -- справочник аэропортов
(--airport_id serial primary key,
airport_code varchar,
airport_name varchar,
city varchar 
--timezone varchar
)

drop table rejected.Dim_Airports

create table stage.Dim_Airports -- справочник аэропортов
(--airport_id serial primary key,
airport_code varchar (5) not null,
airport_name varchar(50) not null,
city varchar(100) not null 
--timezone varchar(100) not null
)

drop table stage.Dim_Airports





create table dds.Dim_Tariff -- справочник тарифов
(id serial not null primary key,
--flight_id char(6) not null primary key,
fare_conditions varchar(10) not null
--amount float8 not null
--status varchar(15) not null,
--effective_ts date not null,
--expire_ts date not null
)

drop table dds.Dim_Tariff

create table rejected.Dim_Tariff -- справочник тарифов
(--flight_id char,
fare_conditions varchar
--amount float8
--status varchar(15) not null,
--effective_ts date not null,
--expire_ts date not null
)

drop table rejected.Dim_Tariff

create table stage.Dim_Tariff -- справочник тарифов
(--flight_id char(6) not null primary key,
fare_conditions varchar(10) not null
--amount float8 not null
--status varchar(15) not null,
--effective_ts date not null,
--expire_ts date not null
)

drop table stage.Dim_Tariff




create table dds.Fact_Flights (
id serial not null primary key,
flight_id char(6) not null,
pass_id int not null references dds.Dim_Passengers (id),
date_departure_id int not null references dds.Dim_Calendar (id),
date_arrival_id int not null references dds.Dim_Calendar (id),
actual_departure timestamp,
actual_arrival timestamp,
delay_departure int, --timestamp,
delay_arrival int, --timestamp,
arrival_airport_id int not null references dds.Dim_Airports (airport_id),
departure_airport_id int not null references dds.Dim_Airports (airport_id),
aircraft_id int not null references dds.Dim_Aircrafts (aircraft_id),
tariff int not null references dds.Dim_Tariff(id),
price float8   
)

drop table dds.Fact_Flights


create table rejected.Fact_Flights (
--id serial not null primary key
flight_id varchar --not null,
,pass_id int --not null references dds.Dim_Passengers (id),
,date_departure_id int --not null references dds.Dim_Calendar (id),
,date_arrival_id int --not null references dds.Dim_Calendar (id),
,actual_departure timestamp
,actual_arrival timestamp
,delay_departure  int -- timestamp
,delay_arrival  int -- timestamp
,arrival_airport_id int -- (5) not null references dds.Dim_Airports (airport_id),
,departure_airport_id int --(5) not null references dds.Dim_Airports (airport_id),
,aircraft_id int --(4) not null references dds.Dim_Aircrafts (aircraft_id),
,tariff int --not null references dds.Dim_Tariff(id),
,price float8 -- not null  
)

drop table rejected.Fact_Flights

select * from rejected.fact_flights ff where ff.pass_id is null 


create table stage.Fact_Flights (
--id serial not null primary key
flight_id char(6) not null,
pass_id int not null ,
date_departure_id int not null ,
date_arrival_id int not null ,
actual_departure timestamp,
actual_arrival timestamp,
delay_departure int,-- timestamp,
delay_arrival int, -- timestamp,
arrival_airport_id int  not null ,
departure_airport_id int not null ,
aircraft_id int  not null ,
tariff int not null ,
price float8   
)

drop table stage.Fact_Flights

select * from stage.fact_flights ff where ff.pass_id is null

