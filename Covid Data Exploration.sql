SELECT *
FROM PortfolioProect..CovidDeaths
ORDER BY 3,4

SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Looking at Total Cases vs. Total Deaths
-- Shows likelihood of dying if you contract covide in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE Location like '%states%'
ORDER BY 1,2

-- Looking at Total Cases vs. Population
-- Shows percentage of population that got Covid

SELECT Location, date, total_cases, population, (total_cases/population)*100 AS InfectionPercentage
FROM PortfolioProject..CovidDeaths
WHERE Location like '%states%'
ORDER BY 1,2

-- Look at Countries with Highest Infection Rate compared to population

SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as InfectionPercentage
FROM PortfolioProject..CovidDeaths
GROUP BY Location, Population
ORDER BY InfectionPercentage desc

-- Showing Highest Death Count by Continent

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount, MAX((cast(total_deaths as int)/population))*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL AND location <> 'International' AND location <> 'Oceania' AND location <> 'World'
GROUP BY Location
ORDER BY TotalDeathCount desc


-- Showing Countries with highest Death Count per Population

SELECT Location, population, MAX(cast(total_deaths as int)) as TotalDeathCount, MAX((cast(total_deaths as int)/population))*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location, Population
ORDER BY TotalDeathCount desc


-- GLOBAL NUMBERS

-- Total Cases and Deaths by Day

SELECT date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

-- Total Cases and Deaths Overall

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations AS int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS TotalVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- Creating a CTE for Further Calculations

WITH PopulationVsVaccinations (Continent, Location, Date, Population, New_Vaccinations, TotalVaccinated) AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations AS int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS TotalVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (TotalVaccinated/Population)*100 AS PercentageVaccinated
FROM PopulationVsVaccinations

-- Creating View for Visualization

CREATE VIEW CountryDeathPercentage AS
SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount, MAX((cast(total_deaths as int)/population))*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL AND location <> 'International' AND location <> 'Oceania' AND location <> 'World'
GROUP BY Location
