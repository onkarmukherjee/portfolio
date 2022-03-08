SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM coviddeaths ORDER BY 1,2;

-- Looking at Total Cases vs Total Deaths
SELECT location, date, total_cases, total_deaths, (total_deaths::float/total_cases)*100 as Death_Percentage
FROM coviddeaths ORDER BY 1,2;

SELECT location, date, total_cases, total_deaths, (total_deaths::float/total_cases)*100 as Death_Percentage
FROM coviddeaths 
WHERE location like '%ndia%' 
ORDER BY 1,2;

-- Looking at Total Cases Vs Population
SELECT location, date, total_cases, population, (total_cases::float/population)*100 as Infected_Percentage
FROM coviddeaths 
WHERE location like '%ndia%' 
ORDER BY 1,2;


-- Looking at Country with Highest Infection Rate vs Population
SELECT location, population, max(total_cases) as HighestInfectionCount, max((total_cases::float/population))*100 as Highest_Infected_Percentage
FROM coviddeaths 
GROUP BY location, population 
ORDER BY Highest_Infected_Percentage DESC;

-- Showing the countries with the highest death count per population
SELECT location, max(total_deaths) as TotalDeathCount
FROM coviddeaths
WHERE continent IS NOT NULL
AND total_deaths IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;


-- Showing continents with the highest death count per population
SELECT location, max(total_deaths) as TotalDeathCountByContinent
FROM coviddeaths
WHERE continent IS NULL
AND total_deaths IS NOT NULL
AND location IN ('North America', 'South America', 'Asia', 'Europe', 'Africa', 'Oceania','Antartica')
GROUP BY location
ORDER BY TotalDeathCountByContinent DESC;

-- Global Stats
SELECT date, SUM(new_cases) as Total_New_Cases, SUM(new_deaths) as Total_New_Deaths, (SUM(new_deaths)::float/SUM(new_cases))*100 as Death_Percentage_NewCases
FROM coviddeaths 
WHERE continent IS NOT NULL
AND new_cases IS NOT NULL 
AND new_deaths IS NOT NULL
GROUP BY date
ORDER BY 1,2;

SELECT SUM(new_cases) as Total_New_Cases, SUM(new_deaths) as Total_New_Deaths, (SUM(new_deaths)::float/SUM(new_cases))*100 as Death_Percentage_NewCases
FROM coviddeaths 
WHERE continent IS NOT NULL
AND new_cases IS NOT NULL 
AND new_deaths IS NOT NULL
ORDER BY 1,2;


-- Join tables looking at total population vs vaccinations
SELECT dea.continent, dea.location, dea.population, vac.new_vaccinations,
SUM (vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS vaccinations_daily_total 
FROM coviddeaths dea
JOIN covidvaccinations vac
On dea.location=vac.location
and dea.date = vac.date
WHERE dea.continent IS NOT NULL
AND vac.new_vaccinations IS NOT NULL
ORDER BY 2,3;

-- Using CTE
With Daily_Vac (Continent, Location, Population, New_Vaccinations, Vaccinations_Daily_Total)
AS
(
SELECT dea.continent, dea.location, dea.population, vac.new_vaccinations,
SUM (vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS vaccinations_daily_total 
FROM coviddeaths dea
JOIN covidvaccinations vac
On dea.location=vac.location
and dea.date = vac.date
WHERE dea.continent IS NOT NULL
AND vac.new_vaccinations IS NOT NULL
)
SELECT *,(vaccinations_daily_total/population)*100 AS New_Vac_Perc 
FROM Daily_Vac;

-- TEMP TABLE
CREATE TABLE PercentPopulationVaccinated
(
Continent VARCHAR (255),
Location VARCHAR (255),
Population BIGINT,
New_Vaccinations BIGINT,
Vaccinations_Daily_Total NUMERIC
);

INSERT INTO PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.population, vac.new_vaccinations,
SUM (vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS vaccinations_daily_total 
FROM coviddeaths dea
JOIN covidvaccinations vac
On dea.location=vac.location
and dea.date = vac.date
WHERE dea.continent IS NOT NULL
AND vac.new_vaccinations IS NOT NULL
ORDER BY 2,3;

SELECT *,(vaccinations_daily_total/population)*100 AS New_Vac_Perc 
FROM PercentPopulationVaccinated;

-- Creating View to store data for later visualizations
CREATE VIEW PopulationVaccinatedView AS 
SELECT dea.continent, dea.location, dea.population, vac.new_vaccinations,
SUM (vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS vaccinations_daily_total 
FROM coviddeaths dea
JOIN covidvaccinations vac
On dea.location=vac.location
and dea.date = vac.date
WHERE dea.continent IS NOT NULL
AND vac.new_vaccinations IS NOT NULL;

SELECT * FROM PopulationVaccinatedView;
