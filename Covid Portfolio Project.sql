select * 
from PortfolioProjectdb..CovidVaccinations$
where continent is not NULL
order by 3,4

--select * 
--From PortfolioProjectdb..CovidVaccinations$
--order by 3,4

select location,date,total_cases,new_cases, total_deaths, population
from PortfolioProjectdb..CovidDeaths$
where continent is not NULL 
order by 1,2;

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of people dying if they contract covid in India 

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from PortfolioProjectdb..CovidDeaths$
where location ='India' and continent is not NULL
order by 1,2

-- Total Cases vs Population
-- Shows what percentage of Population got Covid

select location, date, total_cases, population, (total_cases/population)*100 as Death_Percentage
from PortfolioProjectdb..CovidDeaths$
where location ='India' and continent is not NULL 
order by 1,2

-- Looking at Highest Infection rate compared to Population

select location, population, MAX(total_cases) as highset_infection_count, MAX((total_cases/population))*100 as percentage_population_infected
From PortfolioProjectdb..CovidDeaths$
group by location, population
Order by percentage_population_infected desc

-- Showing Countries with Highest Death count 

select location,  MAX(cast(total_deaths as int)) as highest_death_count
From PortfolioProjectdb..CovidDeaths$
group by location
Order by highest_death_Count desc

-- Showing Continet with highest death count

select continent, MAX(cast(total_deaths as int)) as highest_death_count
from PortfolioProjectdb..CovidDeaths$
where continent is not NULL
GROUP BY continent


-- Global Numbers

select  SUM(CAST(total_deaths as int)) as Total_deaths, SUM(total_cases) as Total_cases,  SUM(CAST(total_deaths as int))/SUM(total_cases)*100 as Death_percentage
from PortfolioProjectdb..CovidDeaths$
where continent is not NULL
--group by date

-- Looking at Total Population vs Total Vaccination

select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
from PortfolioProjectdb..CovidDeaths$ AS cd
JOIN PortfolioProjectdb..CovidVaccinations$ AS cv
ON cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null
order by 1,2

-- USE CTE
with popvsvac( continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
as
(
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, SUM(CONVERT(int,cv.new_vaccinations)) over (partition by cd.location order by cd.location, cd.date) as rolling_people_vaccinated
from PortfolioProjectdb..CovidDeaths$ AS cd
JOIN PortfolioProjectdb..CovidVaccinations$ AS cv
ON cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null
--order by 1,2
)
select *, (rolling_people_vaccinated/population)*100 as percent_population_vaccinated
from popvsvac

--TEMP TABLE
drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(continent nvarchar(250),
location nvarchar(250),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric,
)
insert into #percentpopulationvaccinated
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, SUM(CONVERT(int, cv.new_vaccinations)) over (partition by cd.location order by cd.location, cd.date) as rolling_people_vaccinated
from PortfolioProjectdb..CovidDeaths$ AS cd
JOIN PortfolioProjectdb..CovidVaccinations$ AS cv
ON cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null
order by 1,2

select *, (rolling_people_vaccinated/population)*100 as percent_population_vaccinated
from #percentpopulationvaccinated


-- Creating View to store data for later visualization

create view PercentPopulationVaccinated as 
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, SUM(CONVERT(int, cv.new_vaccinations)) over (partition by cd.location order by cd.location, cd.date) as rolling_people_vaccinated
from PortfolioProjectdb..CovidDeaths$ AS cd
JOIN PortfolioProjectdb..CovidVaccinations$ AS cv
ON cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null
--order by 1,2

select * 
from PercentPopulationVaccinated