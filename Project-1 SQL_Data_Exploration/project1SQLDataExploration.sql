--1. Testing the data and exploring data structure of the table.

SELECT *
FROM ProjectDataExploration..CovidDeaths
ORDER BY 3,4


USE ProjectDataExploration; 
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'CovidDeaths'


--2. Exploring the data that are going to be used

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM ProjectDataExploration..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


--3. Looking at total cases vs total deaths and percentage deaths per infected population. Results are based on and filtered by latest date available November 30, 2023.
--Column DeathPercentage shows percentage likelihood of dying from covid per country if you get infected. Results are sorted by country.

SELECT location, date, total_cases, total_deaths, CAST(total_deaths AS decimal)/CAST(total_cases AS decimal)*100 AS DeathsPercentage
FROM ProjectDataExploration..CovidDeaths
WHERE date = '2023-11-30' AND continent IS NOT NULL
ORDER BY 1


--4. Looking for total and percentage deaths per whole population per country.

SELECT location, population, MAX(CAST(total_deaths AS decimal)) AS TotalDeaths, MAX(CAST(total_deaths AS decimal)/population)*100 AS DeathsPercentage
FROM ProjectDataExploration..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 1


--5. Looking total cases vs population. Results are sorted by country. This table shows how many people percentagewise were infected in whole population of a particular country..
--I used two different aproaches as the last of november is the latest and it should be highest number of people infected.

SELECT location, total_cases, population, CAST(total_cases AS decimal)/population*100 AS ContractionPercentage
FROM ProjectDataExploration..CovidDeaths
WHERE date = '2023-11-30' AND continent IS NOT NULL
ORDER BY 1

SELECT location, population, MAX(CAST(total_cases AS decimal)/population)*100 AS ContractionPercentage
FROM ProjectDataExploration..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 1


--6. Filtering death cases by continent

SELECT location, MAX(CAST(total_deaths AS decimal)) AS TotalDeaths
FROM ProjectDataExploration..CovidDeaths
WHERE (location = 'North America' OR 
       location = 'Asia' OR 
       location = 'Africa' OR 
       location = 'Oceania' OR 
       location = 'South America' OR 
       location = 'Europe')
      AND continent IS NULL
GROUP BY location


--7. New cases and new deaths in entire world day by day from 01.01.2020 - 30.11.2023 by numbers and percentage.

SELECT 
    date,
    SUM(CAST(new_cases AS decimal)) AS NewCases,
    SUM(CAST(new_deaths AS decimal)) AS NewDeaths,
    CASE 
        WHEN SUM(new_cases) > 0 THEN 
            SUM(new_deaths) * 100.0 / SUM(new_cases)
        ELSE 0 
    END AS DeathRatePercentage
FROM ProjectDataExploration..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1;

--7.1 Completete total cases, deaths and percentage deaths in whole world between 01.01.2020 - 30.11.2023.

SELECT 
    SUM(CAST(new_cases AS decimal)) AS NewCases,
    SUM(CAST(new_deaths AS decimal)) AS NewDeaths,
    CASE 
        WHEN SUM(new_cases) > 0 THEN 
            SUM(new_deaths) * 100.0 / SUM(new_cases)
        ELSE 0 
    END AS DeathRatePercentage
FROM ProjectDataExploration..CovidDeaths
WHERE continent IS NOT NULL


--WORK WITH JOINED TABLES

--8. Joining two tables and looking at population vs vaccination. Column new_vaccinations shows new vaccination per day, per country. 
--Also in column RollingCountNewVaccines is shown how vaccination progressed per day in any particular country.

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(decimal, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingCountNewVaccinations
FROM ProjectDataExploration..CovidDeaths dea
JOIN ProjectDataExploration..CovidVaccinations vac
ON dea.date = vac.date AND dea.location = vac.location
WHERE dea.continent IS NOT NULL


--USE OF CTE
-- 9. I'm using CTE since I cannot use column "RollingCountNewVaccinations" created in example 8 straight for other calculations.
-- This query show increase of vaccination in population by numbers and percentage day by day.

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingCountNewVaccinations)
AS
(
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(CONVERT(decimal, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingCountNewVaccinations
	FROM ProjectDataExploration..CovidDeaths dea
	JOIN ProjectDataExploration..CovidVaccinations vac
	ON dea.date = vac.date AND dea.location = vac.location
	WHERE dea.continent IS NOT NULL 
)
SELECT *, RollingCountNewVaccinations/population * 100 AS RollingCountNewVaccinationsPercentag
FROM PopvsVac;


--USE OF TEMPORARY TABLE
--10. I'm using temporary table to acheive the same result as in example 9.

DROP TABLE IF EXISTS #ProcentPopulationVacinnated
CREATE TABLE #ProcentPopulationVacinnated(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population decimal,
new_vaccinations decimal,
RollingCountNewVaccinations decimal
)
INSERT INTO #ProcentPopulationVacinnated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(decimal, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingCountNewVaccinations
FROM ProjectDataExploration..CovidDeaths dea
JOIN ProjectDataExploration..CovidVaccinations vac
ON dea.date = vac.date AND dea.location = vac.location
WHERE dea.continent IS NOT NULL 

SELECT *, RollingCountNewVaccinations/population * 100 AS RollingCountNewVaccinationsPercentag
FROM #ProcentPopulationVacinnated


--11. Creating VIEW to store data for visualization

CREATE VIEW ProcentPopulationVacinnated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(decimal, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingCountNewVaccinations
FROM ProjectDataExploration..CovidDeaths dea
JOIN ProjectDataExploration..CovidVaccinations vac
ON dea.date = vac.date AND dea.location = vac.location
WHERE dea.continent IS NOT NULL 

SELECT *
FROM ProcentPopulationVacinnated