select * 
from Project..Data1

select * 
from Project..Data2

-- Counting Total Number of rows in our dataset

select count(*) as Total_Rows
from project..data1

select count(*) as Total_rows
from project..data2

-- Selecting data for Delhi and Gurgaon

select * 
from Project..data1
where state in ('Haryana' , 'Delhi')

--Population of India

select sum(population) as Total_population
from project..data2

--Average Growth of India

select avg(growth)*100 as average_growth
from project..data1

-- State wise Average Growth

select state, avg(growth)*100 as average_growth 
from project..data1
group by state

--Average Sex Ratio per State

select state, round(avg(sex_ratio),0) as average_sex_ratio
from project..data1
group by state
order by average_Sex_ratio desc

--Average Literacy Rate State wise

select state, round(avg(literacy),0) as avg_literacy_rate
from project..data1
group by state
order by avg_literacy_rate desc

--Average literacy rate greater than 90

select state, round(avg(literacy),0) as avg_literacy_rate
from Project..data1
group by state
having  round(avg(literacy),0) > 90
order by avg_literacy_rate desc

-- Top 3 states showing the highest growth ratio

select top 3 state, avg(growth)*100 as average_growth 
from project..data1
group by state
order by average_growth desc


-- Bottom 3 states showing the lowest sex ratio

select top 3 state, round(avg(sex_ratio),0) as average_sex_ratio
from project..data1
group by state
order by average_Sex_ratio 

--Top and Bottom 3 states in literacy rate
--Top 3

drop table if exists #topstates
create table #topstates
(state nvarchar(255),
topstates float,
)
insert into #topstates
select state, round(avg(literacy),0) as avg_literacy_rate
from Project..data1
group by state
order by avg_literacy_rate desc

select top 3 * from #topstates 
order by #topstates.topstates desc

--Bottom 3

drop table if exists #bottomstates
create table #bottomstates
(state nvarchar(255),
bottomstates float
)
insert into #bottomstates
select state, round(avg(literacy),0) as avg_literacy_rate
from project..data1
group by state 
order by avg_literacy_rate desc

select top 3 * from #bottomstates
order by #bottomstates.bottomstates 

--Union Operator

select * from
(select top 3 * from #topstates 
order by #topstates.topstates desc) a

union

select * from
(select top 3 * from #bottomstates
order by #bottomstates.bottomstates) b

--States starting with  'A'

select distinct(state) 
from project..data1
where state like 'A%'

-- Joining both tables

select a.district, a.state, a.sex_ratio/1000 as sex_ratio, b.population 
from project..data1 a
join project..data2 b
on a.District = b.District

--Calculating Total number of Males and Females District wise

select c.district, c.state,c.sex_ratio/1000 as sex_ratio, c.population , round(c.population/(c.sex_ratio+1),0) as total_males, round((c.sex_ratio* (c.population/(c.sex_ratio+1))),0) as total_females from
(select a.district, a.state, a.sex_ratio/1000 as sex_ratio, b.population 
from project..data1 a
join project..data2 b
on a.District = b.District) c

--Calculating Total number of Males and Females State wise

select d.state, sum(d.total_males) as Males, sum(d.total_females) as Females from 
(select c.district, c.state,c.sex_ratio/1000 as sex_ratio, c.population , round(c.population/(c.sex_ratio+1),0) as total_males, round((c.sex_ratio* (c.population/(c.sex_ratio+1))),0) as total_females from
(select a.district, a.state, a.sex_ratio/1000 as sex_ratio, b.population 
from project..data1 a
join project..data2 b
on a.District = b.District) c) d
group by d.state

--Literacy Rate District wise
select c.district,(c.literacy_ratio*c.population)/100 as literates, (1-c.literacy_ratio)*c.population as illiterates from
(select a.district, a.state, a.Literacy/100 as literacy_ratio, b.population 
from project..data1 a
join project..data2 b
on a.District = b.District) c

--Literacy Rate State wise

select d.state, round(sum(d.illiterates),0) as total_illiterates, round(sum(d.literates),0) as total_literates  from
(select c.state, c.district,(c.literacy_ratio*c.population)/100 as literates, (1-c.literacy_ratio)*c.population as illiterates from
(select a.district, a.state, a.Literacy/100 as literacy_ratio, b.population 
from project..data1 a
join project..data2 b
on a.District = b.District) c) d
group by d.state
order by total_illiterates desc

--Population in previous Census State wise

select  c.state,  round(sum(c.population/(1+ c.growth_rate)),0) as previous_census_population, sum(c.population) as current_sensus_population from
(select a.district, a.state, a.Growth as growth_rate, b.population 
from project..data1 a
join project..data2 b
on a.district = b.district) c
group by c.State

--Total Population of India in previous and current census

select sum(d.previous_census_population) as previous_census_total, sum(d.current_sensus_population) current_year_total from
(select  c.state,  round(sum(c.population/(1+ c.growth_rate)),0) as previous_census_population, sum(c.population) as current_sensus_population from
(select a.district, a.state, a.Growth as growth_rate, b.population 
from project..data1 a
join project..data2 b
on a.district = b.district) c
group by c.State) d

--Population vs Area

select i.total_area/i.previous_census_total as previous_census_population_vs_area,
i.total_area/i.current_year_total as current_sensus_population_vs_area from 
(select g.*, h.total_area from
(select '1' as keyy,e.* from 
(select sum(d.previous_census_population) as previous_census_total, sum(d.current_sensus_population) current_year_total from
(select  c.state,  round(sum(c.population/(1+ c.growth_rate)),0) as previous_census_population, sum(c.population) as current_sensus_population from
(select a.district, a.state, a.Growth as growth_rate, b.population 
from project..data1 a
join project..data2 b
on a.district = b.district) c
group by c.State) d) e) g 
join
(select '1' as keyy, f.* from(
select sum(area_km2) as total_area 
from project..data2) f) h
on g.keyy = h.keyy) i

--Window Function
--Output top 3 Districts from each State with highest literacy rate

select a.* 
from 
(select district, state, literacy, rank() over(partition by state order by literacy desc) as rank  from project..data1) a
where a.rank in(1,2,3) 
order by state 
