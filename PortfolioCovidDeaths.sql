--Importing and checking tables

Select*
From PortfolioProject..CovidDeaths$
WHERE continent is not null
Order by 3,4

--Select*
--From PortfolioProject..CovidVaccinations$
--WHERE continent is not null
--Order by 3,4

--Double checking data that will be used for project

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
ORDER BY 1,2

--Examining total_cases vs total_deaths in the USA as a percentage
--Chance of death after catching COVID

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE Location like '%states%'
and continent is not null
ORDER BY 1,2

--Examining total_cases vs population in the USA as a percentage
--*Chance of catching COVID in relation to entire population

SELECT Location, date, Population, total_cases, (total_cases/population)*100 AS Death_Percentage
FROM PortfolioProject..CovidDeaths$
WHERE Location like '%states%'
ORDER BY 1,2

--Countries with Highest Infection Rate Compared to Population

SELECT Location, Population, MAX(total_cases) as Highest_Infection_Count, MAX(total_cases/population)*100 AS Percent_Population_Infected
FROM PortfolioProject..CovidDeaths$
GROUP BY Location, Population
ORDER BY Percent_Population_Infected desc

--Continents with the Highest Death Count Compared to Population
--*Numbers were not accurate, and had to add WHERE function to past and future commands

SELECT location, MAX(cast(total_deaths AS int)) AS Total_Death_Count
FROM PortfolioProject..CovidDeaths$
WHERE continent is null
GROUP BY location
ORDER BY Total_Death_Count desc

--Countries with the Highest Death Count Compared to Population

SELECT Location, MAX(cast(total_deaths AS int)) AS Total_Death_Count
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
GROUP BY Location
ORDER BY Total_Death_Count desc

--Continents with the Highest Death Count Compared to Population

SELECT continent, MAX(cast(total_deaths AS int)) AS Total_Death_Count
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
GROUP BY continent
ORDER BY Total_Death_Count desc


--Global Numbers Death Percentage

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS Death_Percentage
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2

--Total Population vs Vaccination Rate

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date)
AS rolling_people_vaccinated
, (rolling_people_vaccinated/population)*100
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date)
AS rolling_people_vaccinated
--,(rolling_people_vaccinated/population)*100
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (rolling_people_vaccinated/population)*100
FROM PopvsVac


--TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations nvarchar(255),
RollingPeopleVaccinated numeric
)

INSERT into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date)
AS RollingPeopleVaccinated
--,(rollingpeoplevaccinated/population)*100
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

--Checking table to be used for future visulizations 

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


--Views for future visulizations

CREATE View PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date)
AS RollingPeopleVaccinated
--,(rollingpeoplevaccinated/population)*100
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

--Double Checking Previously Created View

SELECT *
From PercentPopulationVaccinated
