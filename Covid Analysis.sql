Select * 
From [Covid Analysis].dbo.CovidDeaths 
Where continent is not null
order by 3,4

----Select * 
----From PortfolioProject.dbo.CovidVaccinations
----order by 3,4

Select Location, Date, Total_Cases, New_Cases, Total_Deaths, Population
From [Covid Analysis].dbo.CovidDeaths
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows the likelyhood of dying if you contract covid in your country

Select Location, Date, Total_Cases, Total_Deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
From [Covid Analysis].dbo.CovidDeaths
Where location like '%states%'
order by 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got Covid

Select Location, Date, Total_Cases, Population, (cast(total_cases as float)/cast(population as float))*100 as DeathPercentage
From [Covid Analysis].dbo.CovidDeaths
--Where location like '%states%'
order by 1,2


--Looking at countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((cast(total_cases as float)/cast(population as float)))*100 as PercentPopulationInfected
From [Covid Analysis].dbo.CovidDeaths
--Where location like '%states%'
Group by location, population
order by PercentPopulationInfected desc

-- Showing Countries with Highest Death Count per Population

select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
from [Covid Analysis].dbo.CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by location
order by TotalDeathCount desc

-- Showing Continents with the Highest Death Count

select location, MAX(CAST(Total_deaths as int)) as TotalDeathCount
from [Covid Analysis].dbo.CovidDeaths
--Where Location like '%states%'
Where continent is null
group by location
order by TotalDeathCount desc

select continent, MAX(CAST(Total_deaths as int)) as TotalDeathCount
from [Covid Analysis].dbo.CovidDeaths
--Where Location like '%states%'
Where continent is not null
group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/NULLIF(SUM(new_cases)*100,0) as DeathPercentage
From [Covid Analysis].dbo.CovidDeaths
-- Where location like '%states%'
where continent is not null
Group by date
order by 1,2


Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/NULLIF(SUM(new_cases)*100,0) as DeathPercentage
From [Covid Analysis].dbo.CovidDeaths
-- Where location like '%states%'
where continent is not null
--Group by date
order by 1,2

-- Looking at Total Population vs Vaccination 

Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, SUM(CONVERT(bigint,cv.new_vaccinations)) OVER (Partition by cd.location Order by cd.location, cd.date ROWS UNBOUNDED PRECEDING)
	as RollingPeopleVaccinated 
--, (RollingPeopleVaccinated/population)*100
From [Covid Analysis].dbo.CovidDeaths cd
Join [Covid Analysis].dbo.CovidVaccinations cv
	on cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
order by 2,3


--USE CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as 
(
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, SUM(CONVERT(bigint,cv.new_vaccinations)) OVER (Partition by cd.location Order by cd.location, cd.date ROWS UNBOUNDED PRECEDING)
	as RollingPeopleVaccinated  
From [Covid Analysis].dbo.CovidDeaths cd
Join [Covid Analysis].dbo.CovidVaccinations cv
	on cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location  nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, SUM(CONVERT(bigint,cv.new_vaccinations)) OVER (Partition by cd.location Order by cd.location, cd.date ROWS UNBOUNDED PRECEDING)
	as RollingPeopleVaccinated  
From [Covid Analysis].dbo.CovidDeaths cd
Join [Covid Analysis].dbo.CovidVaccinations cv
	on cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating View to Store data for later visualizations

Create View PercentPopulationVaccinated as
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, SUM(CONVERT(bigint,cv.new_vaccinations)) OVER (Partition by cd.location Order by cd.location, cd.date ROWS UNBOUNDED PRECEDING)
	as RollingPeopleVaccinated  
From [Covid Analysis].dbo.CovidDeaths cd
Join [Covid Analysis].dbo.CovidVaccinations cv
	on cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
--order by 2,3

Select*
From PercentPopulationVaccinated

--Queries used for Tableau Visualizations

--1. 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/NULLIF(SUM(new_cases)*100,0) as DeathPercentage
From [Covid Analysis].dbo.CovidDeaths
-- Where location like '%states%'
where continent is not null
--Group by date
order by 1,2

--2. 

Select Location, SUM(cast(new_deaths as int)) as TotalDeathCount
From [Covid Analysis].dbo.CovidDeaths
Where continent is null
and location not in ('World', 'European Union', 'International')
Group by location
Order by TotalDeathCount desc

--3.

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From [Covid Analysis].dbo.CovidDeaths
Group by location, population
Order by PercentPopulationInfected desc

--4.

Select Location, Population, date, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From [Covid Analysis].dbo.CovidDeaths
Group by location, population, date
Order by PercentPopulationInfected desc
