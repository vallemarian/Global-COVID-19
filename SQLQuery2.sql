SELECT *
FROM [Portfolio Project_1]..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

SELECT *
FROM [Portfolio Project_1]..CovidVaccinations
ORDER BY 3,4

--Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project_1]..CovidDeaths
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths
--shows likelihood of dying if you contract covid
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM [Portfolio Project_1]..CovidDeaths
WHERE Location like '%states%'
ORDER BY 1,2


--Looking at Total Cases VS Population
--Shows what percentage of population got covid
SELECT location, date, total_cases, population, (total_cases/population)*100 AS DeathPercentage
FROM [Portfolio Project_1]..CovidDeaths
WHERE Location like '%states%'
ORDER BY 1,2

--Looking at Countries with Highest Infection Rate compared to Population 

SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/Population))*100 AS PercentofPouplationInfected
FROM [Portfolio Project_1]..CovidDeaths
--WHERE Location like '%states%'
GROUP BY Location, Population
ORDER BY PercentofPouplationInfected DESC

--Showing Countries with Highest Death Count per Population

SELECT Location, MAX(Cast(total_deaths as int)) AS TotalDeathCount
FROM [Portfolio Project_1]..CovidDeaths
--WHERE Location like '%states%'
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount DESC

-- Break down things by Continent

SELECT location, MAX(Cast(total_deaths as int)) AS TotalDeathCount
FROM [Portfolio Project_1]..CovidDeaths
--WHERE Location like '%states%'
WHERE continent is  null
GROUP BY location
ORDER BY TotalDeathCount DESC

--#2
SELECT continent, MAX(Cast(total_deaths as int)) AS TotalDeathCount
FROM [Portfolio Project_1]..CovidDeaths
--WHERE Location like '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC


--Global Numbers
--These are cases per DAY
SELECT date, SUM(new_cases) AS Total_cases, SUM(CAST(new_deaths AS int)) AS Total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM [Portfolio Project_1]..CovidDeaths
--WHERE Location like '%states%'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2


--total in the world
SELECT SUM(new_cases) AS Total_cases, SUM(CAST(new_deaths AS int)) AS Total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM [Portfolio Project_1]..CovidDeaths
--WHERE Location like '%states%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2


--Vaccination

SELECT *
FROM [Portfolio Project_1]..CovidVaccinations

--JOIN

SELECT *
FROM [Portfolio Project_1]..CovidDeaths AS Death
JOIN [Portfolio Project_1]..CovidVaccinations AS Vacc
	ON Death.location = Vacc.location
	AND Death.date = Vacc.date

	-- Looking at total Population VS Vaccination

SELECT Death.continent, Death.location, Death.date, death.population, Vacc.new_vaccinations
FROM [Portfolio Project_1]..CovidDeaths AS Death
JOIN [Portfolio Project_1]..CovidVaccinations AS Vacc
	ON Death.location = Vacc.location
	AND Death.date = Vacc.date
WHERE Death.continent is not null
ORDER BY 2,3
--#2

SELECT Death.continent, Death.location, Death.date, death.population, Vacc.new_vaccinations
,SUM(CAST(Vacc.new_vaccinations AS int)) OVER(Partition by  Death.Location ORDER BY Death.location,Death.date) AS RollingPeopleVaccinated
,(RollingPeopleVaccinated/population)*100
FROM [Portfolio Project_1]..CovidDeaths AS Death
JOIN [Portfolio Project_1]..CovidVaccinations AS Vacc
	ON Death.location = Vacc.location
	AND Death.date = Vacc.date
WHERE Death.continent is not null
ORDER BY 2,3

--USE CTE

with PopvsVac(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT Death.continent, Death.location, Death.date, death.population, Vacc.new_vaccinations
,SUM(CAST(Vacc.new_vaccinations AS int)) OVER(Partition by  Death.Location ORDER BY Death.location,Death.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM [Portfolio Project_1]..CovidDeaths AS Death
JOIN [Portfolio Project_1]..CovidVaccinations AS Vacc
	ON Death.location = Vacc.location
	AND Death.date = Vacc.date
WHERE Death.continent is not null
--ORDER BY 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



--Creat View to store data for Viz

CREATE VIEW PercentOfPopulationVaccinated as
SELECT Death.continent, Death.location, Death.date, death.population, Vacc.new_vaccinations
,SUM(CAST(Vacc.new_vaccinations AS int)) OVER(Partition by  Death.Location ORDER BY Death.location,Death.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM [Portfolio Project_1]..CovidDeaths AS Death
JOIN [Portfolio Project_1]..CovidVaccinations AS Vacc
	ON Death.location = Vacc.location
	AND Death.date = Vacc.date
WHERE Death.continent is not null
--ORDER BY 2,3

Select *
From PercentOfPopulationVaccinated