--Create database PortfolioProject
--GO

Use PortfolioProject
GO

--SELECT *
--FROM CovidDeaths
--ORDER BY 3,4

--SELECT *
--FROM CovidVaccinations
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 DeathPercentage
FROM CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

-- Looking at Total Cases vs Population

SELECT location, date, population, total_cases, (total_cases/population)*100 PercentPopulationInfected
FROM CovidDeaths
--WHERE location like '%states%'
ORDER BY 1,2

--Looking at Countries with Highest Infection Rate compared to Population
SELECT location
      ,population
	  ,MAX(total_cases) HighestInfectionCount
	  ,MAX((total_cases/population))*100 PercentPopulationInfected
FROM CovidDeaths
--WHERE location like '%states%'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- Showing Countries with Highest Death Count per Population 

SELECT location 
	  ,MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent is not NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Showing Continents with Highest Death Count per Population

SELECT continent 
	  ,MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


--SELECT location 
--	  ,MAX(cast(total_deaths as int)) as TotalDeathCount
--FROM CovidDeaths
--WHERE continent is NULL
--GROUP BY location
--ORDER BY TotalDeathCount DESC

-- Global Numbers

SELECT 
      SUM(new_cases) TotalCases
	  ,SUM(cast(new_deaths as int)) TotalDeaths
	  ,SUM(cast(new_deaths as int)) / SUM(new_cases) *100 DeathPercentage
FROM CovidDeaths
WHERE continent is not null
--Group by DATE 
ORDER BY 1,2 

-- Looking at Total Population vs Vacctination

SELECT d.continent
      ,d.location
	  ,d.date
	  ,d.population
	  ,v.new_vaccinations
	  ,SUM(convert(bigint, v.new_vaccinations)) OVER (Partition by d.location ORDER BY d.location) RollingPeopleVaccinated
	  ,
FROM CovidDeaths d
JOIN CovidVaccinations v
ON d.location = v.location
AND d.date = v.date
WHERE d.continent is not null
ORDER BY 2, 3

-- Use CTE

with PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT d.continent
      ,d.location
	  ,d.date
	  ,d.population
	  ,v.new_vaccinations
	  ,SUM(convert(bigint, v.new_vaccinations)) OVER (Partition by d.location ORDER BY d.location) RollingPeopleVaccinated
	  
FROM CovidDeaths d
JOIN CovidVaccinations v
ON d.location = v.location
AND d.date = v.date
WHERE d.continent is not null
--ORDER BY 2, 3
)
SELECT *, (RollingPeopleVaccinated/Population)
FROM PopvsVac



-- Use Temp Table
CREATE Table #PercentPopulationVaccinated
(Continent nvarchar(255),
 Location nvarchar(255),
 Date datetime,
 Population numeric,
 New_vacctinations numeric,
 RollingPeopleVaccinated numeric
)


INSERT INTO #PercentPopulationVaccinated
SELECT d.continent
      ,d.location
	  ,d.date
	  ,d.population
	  ,v.new_vaccinations
	  ,SUM(convert(bigint, v.new_vaccinations)) OVER (Partition by d.location ORDER BY d.location) RollingPeopleVaccinated
	  
FROM CovidDeaths d
JOIN CovidVaccinations v
ON d.location = v.location
AND d.date = v.date
--WHERE d.continent is not null
--ORDER BY 2, 3

SELECT *, (RollingPeopleVaccinated/Population) * 100
FROM #PercentPopulationVaccinated

-- Creating View to store data for later visulizations
CREATE VIEW PercentPopulationVaccinated as
SELECT d.continent
      ,d.location
	  ,d.date
	  ,d.population
	  ,v.new_vaccinations
	  ,SUM(convert(bigint, v.new_vaccinations)) OVER (Partition by d.location ORDER BY d.location, d.date) RollingPeopleVaccinated
	  
FROM CovidDeaths d
JOIN CovidVaccinations v
ON d.location = v.location
AND d.date = v.date
WHERE d.continent is not null
--ORDER BY 2, 3