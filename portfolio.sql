select * from portfolio_project..coviddeaths
order by 3,4 

Select * from portfolio_project..covidvaccination
order by 3,4

--select data that we are going to be using
select Location, date, total_cases, new_cases, total_deaths, population
from portfolio_project..coviddeaths
order by 1,2

--looking at total cases vs total deaath
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percent
from  portfolio_project..coviddeaths
where continent is not null
order by 1,2

--total cases by populaiton in india
Select  Location, date, total_cases, population, (total_cases/population)*100 as case_percent
from  portfolio_project..coviddeaths
where location like '%india%' and continent is not null
order by 1,2


--countries with highest case percentage
Select  Location, MAX(total_cases) as highest_infection_rate, population, 
MAX((total_cases/population))*100 as case_percent
from  portfolio_project..coviddeaths
group by population, location 
order by case_percent desc

--countries with highest death percentage
Select  Location, MAX(total_deaths) as highest_death_rate, population, 
MAX((total_deaths/population))*100 as death_percent_by_population
from  portfolio_project..coviddeaths 
where continent is not null
group by population, location 
order by death_percent_by_population desc

--continents with highest death percentage
Select   continent, MAX(total_deaths) as highest_death_rate
from  portfolio_project..coviddeaths
--where location like '%india%' and 
where continent is not null
group by continent

--total cases globally by date
Select  date, sum(cast(new_cases as int)) as cases, sum(cast(new_deaths as int)) as deaths, 
(sum(cast(new_deaths as float))/sum(cast(new_cases as float)))*100 as deathpercent
from  portfolio_project..coviddeaths 
where continent is not null
group by date
order by date 

--total cases in india by date
Select  date, sum(cast(new_cases as int)) as cases, sum(cast(new_deaths as int)) as deaths, 
(sum(cast(new_deaths as float))/sum(cast(new_cases as float)))*100 as deathpercent
from  portfolio_project..coviddeaths 
where location = 'india' and new_cases <> 0
group by date
order by date 

-- global death percentage
Select  sum(cast(new_cases as float)) as cases, sum(cast(new_deaths as float)) as deaths, 
(sum(cast(new_deaths as float))/sum(cast(new_cases as float)))*100 as deathpercent
from  portfolio_project..coviddeaths 

--total vaccination percent by location

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as rollingsum
--(rollingsum/population)*100 we cant use a newly created column for aggregate fxn so we can either use cte or temp table
from portfolio_project..coviddeaths dea
join portfolio_project..covidvaccination vac
on dea.location =vac.location
and dea.date =vac.date
where dea.continent is not null
--and dea.location ='india'
order by 2,3

--with cte

with popvsvsc (continent, location, date, population, new_vaccinations, rollingsum)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as rollingsum
from portfolio_project..coviddeaths dea
join portfolio_project..covidvaccination vac
	on dea.location =vac.location
	and dea.date =vac.date
where dea.continent is not null 
--and dea.location ='india'
)
select * , (rollingsum/population)*100 percent_vaccinated
from popvsvsc

--with temp table

drop table if exists PopulationVaccinated
create table PopulationVaccinated
(
continent nvarchar(255), 
location nvarchar(255),
date date,
population float,
new_vaccinations numeric,
rollingsum numeric
)

insert into PopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as rollingsum
from portfolio_project..coviddeaths dea
join portfolio_project..covidvaccination vac
	on dea.location =vac.location
	and dea.date =vac.date
where dea.continent is not null 
--and dea.location ='india'


select * , (rollingsum/population)*100 percent_vaccinated
from PopulationVaccinated

--creating view for visualisaiton

create view vaccinate as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as rollingsum
from portfolio_project..coviddeaths dea
join portfolio_project..covidvaccination vac
	on dea.location =vac.location
	and dea.date =vac.date
where dea.continent is not null 
