select *
from [My Portfolio Project]..CovidDeaths
where continent is not null
order by 3,4

--select *
--from..CovidVaccinations
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population, life_expectancy
from [My Portfolio Project]..CovidDeaths
where continent is not null
order by 1,2

--loking at total cases by total deaths
--Shows the possible outcome of dying if you contact covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as PercentOfDeath
from [My Portfolio Project]..CovidDeaths
where location like '%Nigeria%'
and continent is not null
order by 1,2

--Total cases by population
-- shows what percent of population got covid
select location, date, population, total_cases, (total_cases/population)*100 as PercentOfCovidPopulation
from [My Portfolio Project]..CovidDeaths
where location like '%Nigeria%'
and continent is not null
order by 1,2

--Countries with the highest covid infection cases compared to their population

select location, population, Max(total_cases) as highestCovidInfection, max((total_cases/population))*100 as HighestPercentOfCovidPopulation
from [My Portfolio Project]..CovidDeaths
--where location like '%Nigeria%'
where continent is not null
group by population, location
order by HighestPercentOfCovidPopulation desc

--continent with highest death count by population

select continent, population, Max(cast(total_deaths as int)) as highestCovidDeaths
from [My Portfolio Project]..CovidDeaths
--where location like '%Nigeria%'
where continent is not null
group by continent, population
order by highestCovidDeaths desc

--GLOBAL ISSUSE

select date, Sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPrecentage
from [My Portfolio Project]..CovidDeaths
--where location like '%Nigeria%'
where continent is not null
group by date
order by 1,2

select Sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPrecentage
from [My Portfolio Project]..CovidDeaths
--where location like '%Nigeria%'
where continent is not null
order by 1,2



--total population vs vaccination


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum (cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	from CovidDeaths dea
	join CovidVaccinations vac
		on dea.location = vac.location
		and dea.date = vac.date
		where dea.continent is not null
			order by 2,3



	--USE CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [My Portfolio Project]..CovidDeaths dea
Join [My Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [My Portfolio Project]..CovidDeaths dea
Join [My Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [My Portfolio Project]..CovidDeaths dea
Join [My Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 