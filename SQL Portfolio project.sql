SELECT *
FROM dbo.CovidDeaths
-- where continent IS NOT NULL
order by 3,4;

--SELECT *
--FROM dbo.CovidVaccinations   -- Portfolio Project ..CovidVaccinations
--order by 3,4


-- SELECT Data that we are going to be using 
SELECT Location,date,total_cases, new_cases, total_deaths,population
FROM dbo.CovidDeaths
where continent IS NOT NULL
order by 1,2;


-- Looking at Total Cases vs Total Deaths
-- shows likelihood of dying if you contract covid in your country
SELECT Location,date,total_cases, new_cases, total_deaths, (total_deaths/total_cases) * 100 AS DeathPercentage
FROM dbo.CovidDeaths
WHERE location LIKE  '%states%' AND continent IS NOT NULL
order by 1,2;


-- Looking at the total_cases vs population
-- shows what percentage of population got covid
SELECT Location, date, total_cases, population, total_deaths, (total_cases/population) * 100 AS CasePercentage
FROM dbo.CovidDeaths
--WHERE location LIKE  '%states%'
order by 1,2;


-- Looking at countries with highest infection rate compared to population
SELECT Location, population, MAX(total_cases) AS highestInfectionCount, MAX((total_cases/population)) * 100 AS InfectionPercentage
FROM dbo.CovidDeaths
--WHERE location LIKE  '%states%'
GROUP BY Location,population
order by InfectionPercentage DESC


-- Showing Countries with highest death count per population
SELECT Location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM dbo.CovidDeaths
--WHERE location LIKE  '%states%'
where continent IS NOT NULL
GROUP BY Location
order by TotalDeathCount DESC



SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM dbo.CovidDeaths
--WHERE location LIKE  '%states%'
where continent IS NULL
GROUP BY location
order by TotalDeathCount DESC


-- Breaking things down by continent

-- Showing the continents with the highest death count per population
SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM dbo.CovidDeaths
--WHERE location LIKE  '%states%'
where continent IS NOT NULL
GROUP BY continent
order by TotalDeathCount DESC


-- Global Numbers 
-- The sum of new cases for each dates
SELECT date,SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage-- , new_cases, total_deaths, (total_deaths/total_cases) * 100 AS DeathPercentage
FROM dbo.CovidDeaths
-- WHERE location LIKE  '%states%' AND 
WHERE continent IS NOT NULL
GROUP BY date
order by 1,2


-- Looking at Total Population Vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(new_vaccinations as INT)) OVER (Partition by dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
FROM dbo.CovidDeaths dea
JOIN dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


-- USE CTE ( COMMON TABLE EXPRESSION )
WITH PopvsVac (continent,location,date,population,new_vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(new_vaccinations as INT)) OVER (Partition by dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
FROM dbo.CovidDeaths dea
JOIN dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/population) * 100 
FROM PopvsVac
--WHERE PopvsVac.location = 'Albania'



-- Temp Table
-- DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(new_vaccinations as INT)) OVER (Partition by dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
FROM dbo.CovidDeaths dea
JOIN dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
-- WHERE dea.continent IS NOT NULL
SELECT *, (RollingPeopleVaccinated/population) * 100 
FROM #PercentPopulationVaccinated




-- Creating View to store data for later visualizations
Create VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(new_vaccinations as INT)) OVER (Partition by dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
FROM dbo.CovidDeaths dea
JOIN dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL



SELECT *
FROM PercentPopulationVaccinated
