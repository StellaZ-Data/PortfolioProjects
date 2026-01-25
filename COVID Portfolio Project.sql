SELECT *
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 3,4

SELECT *
FROM PortfolioProject.dbo.CovidVaccinations
ORDER BY 3,4

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT location, date,
       total_cases, total_deaths,
       (CAST(total_deaths AS float) / NULLIF(total_cases, 0)) * 100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
Where location like '%state%'
ORDER BY 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid 
SELECT location, date,
       total_cases, population,
       (CAST(total_cases AS float) / NULLIF(population, 0)) * 100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
-- Where location like '%state%'
ORDER BY 1,2

-- Looking at country with Highest Infection Rate cpmpared to Population
SELECT location, 
       population, Max(total_cases) as HighestInfectionCount, 
       Max((CAST(total_cases AS float) / NULLIF(population, 0))) * 100 AS PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
-- Where location like '%state%'
GROUP BY location,population
ORDER BY PercentPopulationInfected DESC

-- Showing Countries with Highest Death Count per Population
SELECT location, Max(total_deaths) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


-- Let's break thins down by continent
SELECT continent, Max(total_deaths) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Showing contintents with highest death count per population
SELECT continent, Max(total_deaths) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Global Numbers 
SELECT date,SUM(new_cases)as total_cases,SUM(new_deaths) as total_deaths, SUM(CAST(new_deaths AS float)) / NULLIF(SUM(CAST(new_cases AS float)), 0) * 100 AS DeathPercentage
       --, total_deaths, (CAST(total_deaths AS float) / NULLIF(total_cases, 0)) * 100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
-- Where location like '%state%'
WHERE continent is not NULL
GROUP BY date
ORDER BY 1,2


SELECT SUM(new_cases)as total_cases,SUM(new_deaths) as total_deaths, SUM(CAST(new_deaths AS float)) / NULLIF(SUM(CAST(new_cases AS float)), 0) * 100 AS DeathPercentage
       --, total_deaths, (CAST(total_deaths AS float) / NULLIF(total_cases, 0)) * 100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
-- Where location like '%state%'
WHERE continent is not NULL
-- GROUP BY date
ORDER BY 1,2

-- Looking at Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS BIGINT)) 
        OVER (PARTITION BY dea.location ORDER BY dea.date,dea.location) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not NULL
ORDER BY 2,3


-- USE CTE
WITH PopvsVac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
AS(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS BIGINT)) 
        OVER (PARTITION BY dea.location ORDER BY dea.date,dea.location) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not NULL
-- ORDER BY 2,3
)
SELECT *,
       (CAST(RollingPeopleVaccinated AS float) / NULLIF(population, 0)) * 100 AS PercentVaccinated
FROM PopvsVac;

-- Temp Table #PercentPopulationVaccinated

DROP TABLE if EXISTS PercentPopulationVaccinated
CREATE TABLE PercentPopulationVaccinated
(
    continent NVARCHAR(255),
    location NVARCHAR(255),
    date DATETIME,
    population NUMERIC,
    new_vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
)

INSERT into PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS BIGINT)) 
        OVER (PARTITION BY dea.location ORDER BY dea.date,dea.location) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not NULL

SELECT *,
       (CAST(RollingPeopleVaccinated AS float) / NULLIF(population, 0)) * 100 AS PercentVaccinated
FROM PercentPopulationVaccinated;


-- Creating View to Store data for later visualizarions
CREATE VIEW PercentPopulationVaccinatedView AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS BIGINT)) 
        OVER (PARTITION BY dea.location ORDER BY dea.date,dea.location) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not NULL


SELECT *
FROM PercentPopulationVaccinatedView;
