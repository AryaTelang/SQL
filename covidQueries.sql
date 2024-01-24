SELECT * 
from portfolio.coviddeaths
WHERE continent is not NULL;


SELECT Location,date_cov, total_cases, new_cases, total_deaths,population 
from portfolio.coviddeaths
WHERE continent is not NULL
order by 3,4;

-- total cases/ total coviddeaths
-- will you die if you exist in states
SELECT Location,date_cov, total_cases, total_deaths,population,
(total_deaths/total_cases)*100 as DeathPercentage
from portfolio.coviddeaths
where location like '%states%'
order by 3,4;
-- population with covid
SELECT Location,date_cov,population,total_cases,
(total_cases/population)*100 as ActivePopulation
from portfolio.coviddeaths
where location like '%states%'
order by 3,4;
-- highest infection rate
SELECT Location,population,total_cases,max(total_cases/population)*100 as PercentPopulationInfected,
max(total_cases) as HighestInfectionCount
from portfolio.coviddeaths
GROUP BY location, population
order by PercentPopulationInfected desc;


-- show countries with highest death count per popu
SELECT continent, max(total_deaths) as TotalDeathCount
from portfolio.coviddeaths
WHERE continent is not  NULL
GROUP BY continent
order by TotalDeathCount desc;

-- GLOBAL
-- new death is varchar
SELECT date_cov, SUM(new_cases) as total_cases, sum(new_deaths),sum(new_deaths)/sum(new_cases)*100
from portfolio.coviddeaths
WHERE continent is not  NULL
GROUP BY date_cov
order by 1,2

-- total population in world vaccinated
SELECT * from coviddeaths dea
join covidvaccinations vac on dea.location=vac.location and dea.date_cov =vac.date_vac 



-- use CTE no of col in cte and query same
with PopvsVac( continent, location, date_cov,population,new_vaccinations, RollingPeopleVaccinated)
as (
SELECT  dea.continent,dea.location,dea.date_cov,dea.population,vac.new_vaccinations,sum(vac.new_vaccinations) over (PARTITION BY dea.location order by dea.location, dea.date_cov) as RollingPeopleVaccinated
from coviddeaths dea
join covidvaccinations vac on dea.location=vac.location and dea.date_cov =vac.date_vac 
WHERE dea.continent is NULL
-- ORDER BY 2,3
)
SELECT * ,(RollingPeopleVaccinated/population)*100
FROM PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists PercentPopulationVaccinated;
Create  TEMPORARY table PercentPopulationVaccinated
(
Continent varchar(255),
Location varchar(255),
date_cov datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
);

Insert into PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date_cov, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.date_cov) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
From coviddeaths dea
Join covidvaccinations vac
	On dea.location = vac.location
	and dea.date_cov = vac.date_vac;
-- where dea.continent is not null 
-- order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date_cov, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.date_cov) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
From coviddeaths dea
Join covidvaccinations vac
	On dea.location = vac.location
	and dea.date_cov = vac.date_vac
where dea.continent is not null 

