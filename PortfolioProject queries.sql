SELECT * FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT * FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

-- Select data that we will use

SELECT Location, Date, total_cases, new_cases, total_deaths, population_density
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- shows likelihood of dying if you contract COVID in your country

SELECT Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%Philippines%'
WHERE continent IS NOT NULL
order by 1,2

-- Looking at Total Cases vs Population
-- shows what percentage of the population got COVID

SELECT Location, Date, population_density*100000 AS PopulationDensity, total_cases, (total_cases/population_density)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%Philippines%'
WHERE continent IS NOT NULL
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

SELECT Location, population_density, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population_density))/100 AS HighestInfectionRate
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%Philippines%'
WHERE continent IS NOT NULL
GROUP BY Location, population_density
order by HighestInfectionRate DESC

-- Showing Continents with Highest Death Count per Population

SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%Philippines%'
WHERE continent IS NOT NULL
GROUP BY continent
order by TotalDeathCount DESC
-- OR
SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%Philippines%'
WHERE continent IS NULL
GROUP BY location
order by TotalDeathCount DESC

-- Showing Countries with Highest Death Count per Population

SELECT Location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%Philippines%'
WHERE continent IS NOT NULL
GROUP BY Location
order by TotalDeathCount DESC


-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%Philippines%'
WHERE continent IS NOT NULL
GROUP BY date
order by 1,2

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%Philippines%'
WHERE continent IS NOT NULL
--GROUP BY date
order by 1,2


-- Looking at Total Population vs Vaccinations
-- USE CTE
WITH PopvsVac (Continent, Location, Date, population_density, new_vaccinations, RollingPeopleVaccinated)
AS (
SELECT dea.continent, dea.location, dea.date, dea.population_density, vac.new_vaccinations, 
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population_density)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3
)
SELECT *, (RollingPeopleVaccinated/population_density)*100
FROM PopVsVac

-- TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population_density, vac.new_vaccinations, 
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population_density)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population_density, vac.new_vaccinations, 
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population_density)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3

SELECT * FROM PercentPopulationVaccinated