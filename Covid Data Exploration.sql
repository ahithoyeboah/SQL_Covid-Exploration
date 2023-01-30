--SELECT * FROM dbo.CovidDeaths$
--SELECT * FROM dbo.CovidVaccinations$

--Select Data Needed For exploration

Select location, date, total_cases, new_cases, total_deaths, population  
From dbo.CovidDeaths$
Order by 1,2

--Comparing the total number of cases to the total number of deaths
-- Shows deathpercentage vs total cases

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From dbo.CovidDeaths$ where location = 'Ghana'
Order by date DESC

-- Looking at Total Cases vs Population
-- Shows percentage of population got Covid

Select Location AS 'Country', Date, Population, Total_Cases, (total_cases/population)*100 AS 'Percentage of Population Infected'
From dbo.CovidDeaths$ where location = 'Ghana'
Order by date DESC

-- Countries with highest rate of infection compared to population

Select Location AS 'Country', Population, MAX(Total_Cases) AS 'Highest Infection Count', MAX((total_cases/population))*100 AS 
'Percentage of Population Infected'
From dbo.CovidDeaths$ 
-- where location = 'Ghana'
Group by Location,Population
Order by [Percentage of Population Infected] DESC

-- Countries with highest death count per population

Select Location AS 'Country', MAX(CAST(Total_Deaths as Bigint)) AS 'Total Death Count'
From dbo.CovidDeaths$ where continent is not null
-- where location = 'Ghana'
Group by Location
Order by [Total Death Count] DESC

-- Breaking it down by Continent
-- Total Death Count By Continent

Select Location AS 'Continent' , MAX(CAST(Total_Deaths as Bigint)) AS 'Total Death Count'
From dbo.CovidDeaths$ where continent is null
-- where location = 'Ghana'
Group by Location
Order by [Total Death Count] DESC

-- Global Stats

Select SUM(new_cases) AS 'Total Cases', SUM(CAST(new_deaths as bigint)) AS'Total_Deaths', SUM(CAST(new_deaths as bigint))/SUM(new_cases)*100 AS 
'Death Percentage'
From dbo.CovidDeaths$ where continent is not null
Order by 1,2

-- Total Population vs Vaccinations
-- Join Death Table with Vaccination Table

--USE CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) AS (
Select dea.Continent, dea.Location, dea.Date, dea.Population, vac.New_Vaccinations,
SUM(CAST(vac.New_Vaccinations as bigint)) OVER (Partition by dea.Location order by dea.Location, dea.Date) 
AS RollingPeopleVaccinated
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac on
dea.Location = vac.Location and dea.Date = vac.Date
where dea.Continent is not null
)
SELECT * , (RollingPeopleVaccinated / Population) * 100
FROM PopvsVac 

-- Creating Views for Later Viz 

