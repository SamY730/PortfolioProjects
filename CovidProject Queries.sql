select *
from compact-cell-424803-f5.Portfolio_Project.covid_deaths
where continent is not null
order by 3,4

select *
from compact-cell-424803-f5.Portfolio_Project.covid_vaccinations
where continent is not null
order by 3,4

-- Above are the two tables I am working with

select location, date, total_cases, new_cases, total_deaths, population
from compact-cell-424803-f5.Portfolio_Project.covid_deaths
where continent is not null
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying from Covid in your country
select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from compact-cell-424803-f5.Portfolio_Project.covid_deaths
where location = "United States"
and  continent is not null
order by 1,2

--Looking at Total Cases vs Population
--Shows what % of population got covid
select location, date, population, total_cases,  (total_cases/population)*100 as CasesPercentage
from compact-cell-424803-f5.Portfolio_Project.covid_deaths
where location = "United States"
order by 1,2

--Looking at countries with highest infection rate compared to population

select location, population, max(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PopPercentInfected
from compact-cell-424803-f5.Portfolio_Project.covid_deaths
group by location, population
order by PopPercentInfected desc

-- Showing Countries with highest Death Count Per Population

select location, Max(Total_Deaths) as TotalDeathCount
from compact-cell-424803-f5.Portfolio_Project.covid_deaths
where continent is not null
group by location
order by TotalDeathCount desc

--Breaking Down By Continent

-- Continents with Highest Death Count

select location, Max(Total_Deaths) as TotalDeathCount
from compact-cell-424803-f5.Portfolio_Project.covid_deaths
where continent is not null
group by location
order by TotalDeathCount desc

--Global Breakdown
select date, sum(new_cases), sum(new_deaths), sum(new_deaths)
from compact-cell-424803-f5.Portfolio_Project.covid_deaths
where  continent is not null
Group by date
order by 1,2

--Looking at Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingTotalVaccinations
From compact-cell-424803-f5.Portfolio_Project.covid_deaths dea
Join compact-cell-424803-f5.Portfolio_Project.covid_vaccinations vac
  On dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Using CTE
With PopvsVac (Continent, Location, Date, Population,New Vaccinations, RollingTotalVaccinations )
as
(
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingTotalVaccinations
From compact-cell-424803-f5.Portfolio_Project.covid_deaths dea
Join compact-cell-424803-f5.Portfolio_Project.covid_vaccinations vac
  On dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null
)
select *, (RollingTotalVaccinations/Population)*100
from PopvsVac



--Using Temp Table

Create Table as #PercentagePopulationVaccinated
(
Continent string,
location string,
date datetime,
population int64,
new_vaccinations int64,
RollingTotalVaccinations int64,
)

Insert into #PercentagePopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingTotalVaccinations, (RollingTotalVaccinations/population)*100
From compact-cell-424803-f5.Portfolio_Project.covid_deaths dea
Join compact-cell-424803-f5.Portfolio_Project.covid_vaccinations vac
  On dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null
order by 2,3

select *, (RollingTotalVaccinations/Population)*100
from #PercentagePopulationVaccinated


--Creating  View to store date for visualizations

Create View PercentagePopulationVaccinated as

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingTotalVaccinations
From compact-cell-424803-f5.Portfolio_Project.covid_deaths dea
Join compact-cell-424803-f5.Portfolio_Project.covid_vaccinations vac
  On dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null


select *
from compact-cell-424803-f5.PercentPopulationVaccinated.PercentPopulationVaccinated





--Queries for Visualization Project

--1.

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From compact-cell-424803-f5.Portfolio_Project.covid_deaths
where continent is not null 
--Group By date
order by 1,2


--2.
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From compact-cell-424803-f5.Portfolio_Project.covid_deaths
Where continent is null 
and location not in ('World', 'European Union', 'International', 'High income','Upper middle income','Lower middle income','Low income'  )
Group by location
order by TotalDeathCount desc
-- Certain locations are removed above as they are redundant or not a location.

-- 3.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From compact-cell-424803-f5.Portfolio_Project.covid_deaths
Group by Location, Population
order by PercentPopulationInfected desc


-- 4.


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From compact-cell-424803-f5.Portfolio_Project.covid_deaths
Group by Location, Population, date
order by PercentPopulationInfected desc
