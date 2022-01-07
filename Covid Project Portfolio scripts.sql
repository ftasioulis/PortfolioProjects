select *
from PortfolioProject..['CovidDeaths$']
where continent is not null
order by 3,4

--select *
--from PortfolioProject..['CovidVaccinations$']
--where continent is not null
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..['CovidDeaths$']
where continent is not null
order by 1,2

--Total Cases vs Total Deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..['CovidDeaths$']
where location like '%states%'
and continent is not null
order by 1,2


--Total Cases vs Population
--percentage of population got Covid

select location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..['CovidDeaths$']
where location like '%states%'
and continent is not null
order by 1,2

--Countries with the Highest Infection Rate Compared to Population

select location, MAX(total_cases) as HighestInfectionCount, population, Max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..['CovidDeaths$']
where continent is not null
Group by location, population
order by PercentPopulationInfected desc


--Countries with the Highest Death Count per Population

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..['CovidDeaths$']
where continent is not null
Group by location
order by TotalDeathCount desc


--COVID DEATHS by CONTINENT

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..['CovidDeaths$']
where continent is not null
Group by continent
order by TotalDeathCount desc


--Global Numbers

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
sum(cast(new_deaths as int))/sum(New_Cases)*100 as DeathPercentage
from PortfolioProject..['CovidDeaths$']
where continent is not null
--Group by date
order by 1,2

--Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location 
order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..['CovidDeaths$'] dea
join PortfolioProject..['CovidVaccinations$'] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--CTE
with PopsVac (continent, location, date, population, New_Vaccinations, 
RollingPeopleVaccinated) as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location 
order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..['CovidDeaths$'] dea
join PortfolioProject..['CovidVaccinations$'] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

)
select *, (RollingPeopleVaccinated/population)*100
from PopsVac


-- TEMP TABLE

Drop table if exists #PercentPopulationVaccinated

create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location 
order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..['CovidDeaths$'] dea
join PortfolioProject..['CovidVaccinations$'] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated



--Creating View to store data for later visualisations

Create view PercentPopulationVacc as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location 
order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..['CovidDeaths$'] dea
join PortfolioProject..['CovidVaccinations$'] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVacc
