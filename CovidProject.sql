SELECT *
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
order by 3,4

-- Looking at total cases vs total deaths for France
-- Shows likelyhood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidProject..CovidDeaths
WHERE location like '%France%'
ORDER BY 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
SELECT location, date, total_cases, population, (total_cases/population)*100 AS PercPopInfected
FROM CovidProject..CovidDeaths
WHERE location like '%France%'
ORDER BY 1,2

--Looking at Countries with Highest Infection Rate compared to population
SELECT location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 AS CovPop
FROM CovidProject..CovidDeaths
--WHERE location like '%France%'
GROUP BY population, location
ORDER BY CovPop desc

--Looking at Countries with Highest number of deaths per population
SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathsCount
FROM CovidProject..CovidDeaths
--WHERE location like '%France%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathsCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT
SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathsCount
FROM CovidProject..CovidDeaths
--WHERE location like '%France%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathsCount desc


-- GLOBAL NUMBERS
SELECT date, SUM(new_cases) AS TotalCases, SUM(cast(new_deaths as int)) AS TotalDeaths, SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage--, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidProject..CovidDeaths
--WHERE location like '%France%'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

-- TOTAL DEATHS PER CASES
SELECT SUM(new_cases) AS TotalCases, SUM(cast(new_deaths as int)) AS TotalDeaths, SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage--, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidProject..CovidDeaths
--WHERE location like '%France%'
WHERE continent IS NOT NULL
ORDER BY 1,2

------------------------------------------------------------------------------------------
--Looking at Total Population vs Vaccinations

SELECT *
FROM CovidProject..CovidDeaths dea
JOIN CovidProject..covvacc vac
	ON dea.location = vac.location
	AND dea.date = vac.date


-- USE CTE
WITH PopVsVac (continent, location, Date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY cast(dea.location as varchar), dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM CovidProject..CovidDeaths dea
JOIN CovidProject..covvacc vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
Select *,(RollingPeopleVaccinated/population)*100 AS PercentageOfVaccinatedPeople
FROM PopVsVac


--TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date nvarchar(255),
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY cast(dea.location as varchar), dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM CovidProject..CovidDeaths dea
JOIN CovidProject..covvacc vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

Select *,(RollingPeopleVaccinated/population)*100 AS PercentagePplVaccinated 
FROM #PercentPopulationVaccinated
ORDER BY 2,3



--Creating View to store data for later visualization

CREATE VIEW PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY cast(dea.location as varchar), dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM CovidProject..CovidDeaths dea
JOIN CovidProject..covvacc vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated