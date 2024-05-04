-- Covid 19 Project

-- SELECT * from [dbo].[CovidDeaths] order by 3, 4
-- SELECT * from [dbo].[CovidVaccinations] order by 3, 4

-- PART 1

-- Select data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths 
FROM [dbo].[CovidDeaths]
ORDER BY 1, 2

-- Looking at total cases vs totla deaths
-- SHows likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, (total_Deaths/ total_cases) *100 as death_percentageg
FROM [dbo].[CovidDeaths]
WHERE location = 'India'

-- Looking at total cases vs the population (how many people got covid)

SELECT Location, date, population, total_cases, (total_deaths/ population) *100 as death_percent
FROM [dbo].[CovidDeaths]
-- WHERE location = 'India'

-- Looking at countries with highest infection rates

SELECT Location, population, max(total_cases) as HighestInfectionRate, MAX((total_deaths/ population)) *100 as PercentPopulationInfected
FROM [dbo].[CovidDeaths]
Group By Location, population
ORDER BY Location, PercentPopulationInfected

-- Countries with the highest death counts per population

SELECT Location, max(cast(total_deaths as int)) as TotalDeathCount
FROM [dbo].[CovidDeaths]
where continent is not null
Group By Location, population
ORDER BY TotalDeathCount DESC

-- Lets break things down by continent

SELECT continent, max(cast(total_deaths as int)) as TotalDeathCount
FROM [dbo].[CovidDeaths]
where continent is not null
Group By continent
ORDER BY TotalDeathCount DESC

SELECT location, max(cast(total_deaths as int)) as TotalDeathCount
FROM [dbo].[CovidDeaths]
where continent is null
Group By location
ORDER BY TotalDeathCount DESC

-- Showing the continent with the highest death count per population

SELECT continent, max(cast(total_deaths as int)) as TotalDeathCount
FROM [dbo].[CovidDeaths]
where continent is not null
Group By continent
ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBERS Deaths/ Cases

SELECT date, sum(new_cases) as Total_Cases, 
			sum(cast(new_deaths as int)) as Total_Deaths, 
			sum(cast(new_deaths as int))/ sum(new_cases)*100 as death_percent
FROM [dbo].[CovidDeaths]
-- WHERE location = 'India'
where continent is not null
Group by date
ORDER BY 1,2

-- Total deaths across the world

SELECT sum(new_cases) as Total_Cases, 
			sum(cast(new_deaths as int)) as Total_Deaths, 
			sum(cast(new_deaths as int))/ sum(new_cases)*100 as death_percent
FROM [dbo].[CovidDeaths]
-- WHERE location = 'India'
where continent is not null
ORDER BY 1,2


-- Looking at total populations vs vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/ population)*100
from [dbo].[CovidDeaths] as dea
JOIN [dbo].[CovidVaccinations] as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE Above query in CTE

WITH PopVsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/ population)*100
from [dbo].[CovidDeaths] as dea
JOIN [dbo].[CovidVaccinations] as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/ population) *100 as Percentage from PopVsVac

--- TEMP Table Method
DROP table if exists #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/ population)*100
from [dbo].[CovidDeaths] as dea
JOIN [dbo].[CovidVaccinations] as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2,3

Select *, (RollingPeopleVaccinated/ population) *100 as Percentage from #PercentPopulationVaccinated


-- Create a View to store data for later visualization

Create View PercentPopulationVaccincated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/ population)*100
from [dbo].[CovidDeaths] as dea
JOIN [dbo].[CovidVaccinations] as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2,3


-- Calling the data from VIEW
Select * from PercentPopulationVaccincated

