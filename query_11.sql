--find the total number of users and the total amount spent using mobile only, desktop only and both mobile and desktop together for each date.

create table spending 
(
user_id int,
spend_date date,
platform varchar(10),
amount int
);

insert into spending values(1,'2019-07-01','mobile',100),(1,'2019-07-01','desktop',100),(2,'2019-07-01','mobile',100)
,(2,'2019-07-02','mobile',100),(3,'2019-07-01','desktop',100),(3,'2019-07-02','desktop',100);

--select * from spending

with distinct_platform as (
select *, 
case when (count(platform) over(partition by spend_date, user_id)) = 2 then 'both' else platform end as distinct_platform_flag
from spending)
, with_total_amount as (
select spend_date, user_id, distinct_platform_flag, sum(amount) as total_amount
from distinct_platform
group by spend_date, user_id, distinct_platform_flag)
, categories as (
select 'both' as category
union all
select 'mobile' as category
union all
select 'desktop' as category)
, cte as (
select *, 
count(*) over(partition by spend_date) as c, 
case when (count(*) over(partition by spend_date)) < 3 and distinct_platform_flag != 'mobile' and distinct_platform_flag != 'desktop' then 'both' else null end as both_column, 
case when (count(*) over(partition by spend_date)) < 3 and distinct_platform_flag != 'mobile' and distinct_platform_flag != 'both' then 'desktop' else null end as desktop_column, 
case when (count(*) over(partition by spend_date)) < 3 and distinct_platform_flag != 'desktop' and distinct_platform_flag != 'both' then 'mobile' else null end as mobile_column
from with_total_amount)

select *
from cte