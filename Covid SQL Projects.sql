Select *
From PortfolioProject..CovidVaccination
Order By 3,4;

Select *
From CovidDeaths
Order By 3,4;

--Select *
--From PortfolioProject..CovidVaccination
--Order By 3,4;

-- Looking at total cases vs total deaths

Select location, date, population, total_cases, total_deaths, (total_deaths/total_cases)*100 as deaths_percentage
From CovidDeaths Where location like '%states%' and continent is not null
Order by 1,2

-- Looking at total cases vs poppulation

Select location, date, total_cases, population, (total_cases/population)*100 as deaths_percentage
From CovidDeaths Where location like '%states%'
Order by 1,2

--Looking at Countries with highest infection rate Compare to poppulation

Select location, population, max(total_cases) as HighestInfection, max(total_cases/population)*100 as PercentPopulationInfected
From CovidDeaths
Where continent is not null
Group by location, population
Order by PercentPopulationInfected desc

-- Showing countries with hightest per population

Select location, max(cast(total_deaths as int)) as TotalDeathsCount
From CovidDeaths
Where continent is not null
Group by location
Order by TotalDeathsCount desc

-- Break by Continet with highest deaths count

Select continent, max(cast(total_deaths as int)) as TotalDeathsCount
From CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathsCount desc

-- The rolling average of deaths by week
Select 
  avg(CAST(new_deaths AS INT)) OVER(ORDER BY Date
     ROWS BETWEEN CURRENT ROW AND 7 FOLLOWING)
     as moving_average, *
from CovidDeaths
WHERE continent IS NOT NULL
AND new_deaths IS NOT NULL
ORDER BY DATE
;

--The rolling average of deaths by location
Select dea.location, dea.date, population, new_deaths
, SUM(CAST(new_deaths AS INT)) OVER (Partition by dea.location ORDER BY DEA.LOCATION, DEA.DATE) AS ROLLINGPPLVAC
From CovidDeaths dea
INNER JOIN CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by dea.location, dea.date


-- looking total population vs vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition by dea.location ORDER BY DEA.LOCATION, DEA.DATE) AS ROLLINGPPLVAC
From CovidDeaths dea
INNER JOIN CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
AND new_vaccinations IS NOT NULL
AND new_vaccinations <> 0
Order by 2,3

-- use CTE
With PopvsVac(continent, location, date, poppulation, new_vaccinations, ROLLINGPPLVAC)
AS
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition by dea.location ORDER BY DEA.LOCATION, DEA.DATE) AS ROLLINGPPLVAC
From CovidDeaths dea
INNER JOIN CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
AND new_vaccinations IS NOT NULL
AND new_vaccinations <> 0
)
Select *,(ROLLINGPPLVAC/poppulation)*100
From PopvsVac
Order by 2,3

-- Temp Table

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
ROLLINGPPLVAC numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition by dea.location ORDER BY DEA.LOCATION, DEA.DATE) AS ROLLINGPPLVAC
From CovidDeaths dea
INNER JOIN CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
AND new_vaccinations IS NOT NULL
AND new_vaccinations <> 0
Select *,(ROLLINGPPLVAC/population)*100
From #PercentPopulationVaccinated
Order by 2,3

-- Create view to store data for data visualization 
Create view PercentPopulationVaccinated as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition by dea.location ORDER BY DEA.LOCATION, DEA.DATE) AS ROLLINGPPLVAC
From CovidDeaths dea
INNER JOIN CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
	)
--Where dea.continent is not null
--AND new_vaccinations IS NOT NULL
--AND new_vaccinations <> 0
Select *,(ROLLINGPPLVAC/population)*100
From #PercentPopulationVaccinated
--Order by 2,3