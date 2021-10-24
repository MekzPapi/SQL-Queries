SELECT * FROM [dbo].[covid deaths]

SELECT * FROM [dbo].[covidvaccinations]

--shows likelihood of dying from covid

SELECT LOCATION,DATE,TOTAL_CASES, TOTAL_DEATHS, (TOTAL_DEATHS/TOTAL_CASES)*100 AS DEATHPERCENTAGE FROM [dbo].[covid deaths]

--shows what percentage of population got covid

SELECT LOCATION,DATE,population, TOTAL_cases, (TOTAL_cases/population)*100 AS CASEPERCENTAGE FROM [dbo].[covid deaths]

--CONTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION

SELECT LOCATION,POPULATION, MAX(TOTAL_CASES) AS HighestInfectionCount, max(TOTAL_cases/population)*100 AS PercentPopulationInfected 
FROM [dbo].[covid deaths] group by LOCATION,POPULATION
order by PercentPopulationInfected desc

--showing countries with highest death count per population

SELECT LOCATION, MAX(cast(TOTAL_DEATHS as int)) AS TotalDeathCount 
FROM [dbo].[covid deaths] 
WHERE continent is not null
group by LOCATION
order by TotalDeathCount desc

--breakdown by continent

SELECT location, MAX(cast(TOTAL_DEATHS as int)) AS TotalDeathCount 
FROM [dbo].[covid deaths] 
WHERE continent is null
group by location
order by TotalDeathCount desc

--showing continents with the highest death count per population

SELECT continent, MAX(cast(TOTAL_DEATHS as int)) AS TotalDeathCount 
FROM [dbo].[covid deaths] 
WHERE continent is not null
group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS

SELECT sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from [dbo].[covid deaths] where continent is not null order by 1,2

select * from [dbo].[covid deaths] dea join [dbo].[covidvaccinations] vac
on dea.location = vac.location
and dea.date = vac.date

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) 
over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from [dbo].[covid deaths] dea join [dbo].[covidvaccinations] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--use CTE

with PopsvsVac (Continent, location, date, population, New_vaccinations, RollingPeopleVaccinated)
as
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) 
over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from [dbo].[covid deaths] dea join [dbo].[covidvaccinations] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null)
select *, (RollingPeopleVaccinated/population)*100 as PercentRollingPeopleVacc from PopsvsVac

--temp table

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) 
over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from [dbo].[covid deaths] dea join [dbo].[covidvaccinations] vac
 on dea.location = vac.location
 and dea.date = vac.date
--where dea.continent is not null

select *, (RollingPeopleVaccinated/population)*100 
from #PercentPopulationVaccinated