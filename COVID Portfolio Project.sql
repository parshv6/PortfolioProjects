select * 
from PortFolioProject..CovidDeaths order by 3,4
select * from PortFolioProject..CovidVacinations order by 3,4

-- Select Data that we are going to be using
Select  Location, date, total_cases, new_cases, total_deaths, population
from PortFolioProject..CovidDeaths
order by 1,2

-- Looking at toatl cases vs Total deaths (You can use CAST function to convert data type of column)

Select  Location, date, total_cases,total_deaths, (CAST(total_deaths as numeric)/CAST(total_cases as numeric))*100 as DeathPercentage
from PortFolioProject..CovidDeaths
where location ='India'
order by 1,2

--Looking at Total cases vs Population
-- shows what % of population got covid

Select  Location, date,population, total_cases,(CAST(total_deaths as numeric)/population)*100 as PercentPopulationInfected
from PortFolioProject..CovidDeaths
--where location ='United States'
order by 1,2


--What country has highest infection rate

Select  Location,Population, MAX(total_cases) as HighestInfectionCount, MAX((CAST(total_cases as numeric)/Population))*100 as  PercentPopulationInfected
from PortFolioProject..CovidDeaths
Group By Location, Population
order by  PercentPopulationInfected desc


--Showing Countries with Highest Death count per population
Select  Location, MAX(CAST(total_deaths as int)) as TotalDeathCount
from PortFolioProject..CovidDeaths
where continent is not null
Group By Location
order by  TotalDeathCount desc


--Lets break things by continent

--Showing continent with the highest death counts per population

Select  continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
from PortFolioProject..CovidDeaths
where continent is not null
Group By continent
order by  TotalDeathCount desc



-- Global Numbers
Select  date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as  DeathPercentage 
from PortFolioProject..CovidDeaths
where continent is not null
AND new_cases <> 0
AND new_deaths <> 0
Group By date
order by  1,2


--Looking at toatl population Vs Vacinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortFolioProject..CovidDeaths dea
join PortFolioProject..CovidVacinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--USE CTE FOR Population Vs Vacination

With PopvsVac (Continent , location, date, population, new_vaccinations , RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as float)) 
OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortFolioProject..CovidDeaths dea
join PortFolioProject..CovidVacinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *,(RollingPeopleVaccinated/population)*100
from PopvsVac

-- create VIEW

create view PercentPopulationVacinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as float)) 
OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortFolioProject..CovidDeaths dea
join PortFolioProject..CovidVacinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select * from PercentPopulationVacinated








