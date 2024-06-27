--1 which team has won the maximum gold medals over the years.

select top 1 team, count(distinct event) as no_of_gold_medal
from athletes
inner join athlete_events on athlete_events.athlete_id=athletes.id
where medal='gold'
group by team,medal
order by no_of_gold_medal desc

--2 for each team print total silver medals and year in which they won maximum silver medal..output 3 columns
-- team,total_silver_medals, year_of_max_silver

with cte as
(
select a.team,ae.year,count(distinct event) as silver_medals,
rank() over (partition by team order by count(distinct event) desc) as rn
from athlete_events ae
inner join athletes a on ae.athlete_id=a.id
where medal='silver'
group by team,ae.year
)
select team, sum(silver_medals) as total_silver_medals
,max(case when rn=1 then year end) as year_of_max_silver
from cte
group by team

--3 which player has won maximum gold medals  amongst the players 
--which have won only gold medal (never won silver or bronze) over the years

with cte as
(
select name,medal
from athlete_events ae
inner join athletes a on ae.athlete_id=a.id
)
select top 1 name, count(1) as no_of_gold_medal
from cte
where medal='gold'and name not in ( select distinct name from cte where medal in ('silver','bronze'))
group by name 
order by no_of_gold_medal desc

--4 in each year which player has won maximum gold medal . Write a query to print year,player name 
--and no of golds won in that year . In case of a tie print comma separated player names.

with cte as
(
select name,year,count(1) as no_of_gold_medals
from athlete_events ae
inner join athletes a on ae.athlete_id=a.id
where medal='gold'
group by name,year
)
select year,no_of_gold_medals ,String_agg(name,',') as player_name
from(
select *,
rank() over (partition by year order by no_of_gold_medals desc) as rn
from cte) as A
where rn=1
group by  year,no_of_gold_medals
ORDER BY year



--5 in which event and year India has won its first gold medal,first silver medal and first bronze medal
--print 3 columns medal,year,sport

select  distinct* 
from 
(
select year, event,sport,medal,
rank() over ( partition by medal order by year ) rn
from athlete_events ae
inner join athletes a on a.id=ae.athlete_id
where team ='india' and medal!= 'na'
) as A
where rn =1



--6 find players who won gold medal in summer and winter olympics both.

select * from athlete_events
order by year
select name
from athlete_events ae
inner join athletes a on ae.athlete_id=a.id
where medal ='gold'
group by name
having count(distinct season)=2

--7 find players who won gold, silver and bronze medal in a single olympics. print player name along with year.

select year,name
from athlete_events ae
inner join athletes a on ae.athlete_id=a.id
where medal!='na'
group by year, name
having count(distinct medal)=3



--8 find players who have won gold medals in consecutive 3 summer olympics in the same event .Consider only olympics 2000 onwards.
--Assume summer olympics  happens every 4 year starting 2000. print player name and event name.

with cte as
(
select year,name,event
from athlete_events ae
inner join athletes a on ae.athlete_id=a.id
where medal='gold' and year>=2000 and season='summer'
)
select * from 
(
select *,
lag(year,1) over (partition by name,event order by year) as prev_year,
lead(year,1) over (partition by name,event order by year ) as next_year
from cte
) as A 
WHERE year= prev_year+4 and year=next_year-4
order by year