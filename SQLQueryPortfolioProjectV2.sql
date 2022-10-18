
--Looking at the Countries with Highest Infection Rate compared to Population
Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population) * 100 as PercentPopulationInfected
From PorfolioProject..CovidDeaths
Where continent is not null
Group by location, population
Order by HighestInfectionCount desc

Select *
From PorfolioProject..CovidDeaths
Where continent is null
Order by 3, 4

Select *
From PorfolioProject..CovidVaccination
Where continent is null
Order by 3, 4

Select location, date, population, total_cases, (total_cases/population) * 100 as death_rate_percentage
From PorfolioProject..CovidDeaths
Where location like '%states'
Order by 1,2

--Showing countries with the highest death rate
Select Location, MAX(cast (total_deaths as int)) as TotalDeathCount
From PorfolioProject..CovidDeaths
--Where location like '%states'
Where continent is not null
Group by location
Order by TotalDeathCount desc

--Breaking things down by CONTINENT
--Showing Cotinentst with the highest DeathCounts
Select Continent, MAX(cast (total_deaths as int)) as TotalDeathCount
From PorfolioProject..CovidDeaths
--Where location like '%states'
Where continent is not null
Group by Continent
Order by TotalDeathCount desc

--Breaking things down by LOCATION
Select Location, MAX(cast (total_deaths as int)) as TotalDeathCount
From PorfolioProject..CovidDeaths
--Where location like '%states'
Where continent is not null
Group by Location
Order by TotalDeathCount desc

--Global Numbers - This is to SUM UP the Total Cases Each Day
Select date, SUM(New_Cases) as New_Cases
From PorfolioProject..CovidDeaths
Where continent is not null
Group by date
Order by 1,2

--Global Numbers 2
Select continent, location, date, total_cases, (cast(total_cases/population as int)) * 100 as death_rate_percentage
From PorfolioProject..CovidDeaths
Where continent is not null
Group by continent
Order by total_cases desc

--Global Numbers 3
Select Location, SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, 
SUM(cast(New_Deaths as int))/SUM(New_Cases)*100 as Death_Percentage 
From PorfolioProject..CovidDeaths
Where continent is not null
Group by Location
Order by 1,2

--Joining 2 TABLES
Select *
From PorfolioProject..CovidDeaths dea
Join PorfolioProject..CovidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
Order by 1,2

--Looking at the Total Population VS Vaccinated with SUM Partition (Rolling Number at the TOTAL)
Select dea.Continent, dea.Location, dea.Date, dea.Population, vac.New_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location, dea.Date) as RollingPeopleVaccinated
From PorfolioProject..CovidDeaths dea
Join PorfolioProject..CovidVaccination vac
on dea.location = vac.location 
Where dea.continent is not null
Order by 2,3

---------------------------------------------------------------------
--With CTE
--START
With PopVSVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.Continent, dea.Location, dea.Date, dea.Population, vac.New_Vaccinations,
SUM(CONVERT(int, vac.New_Vaccinations)) OVER (Partition by dea.Location Order by dea.Location, dea.Date) as RollingPeopleVaccinated
From PorfolioProject..CovidDeaths dea
Join PorfolioProject..CovidVaccination vac
on dea.Location = vac.Location 
and dea.Date = vac.Date
Where dea.Continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100  as RollingPeopleVaccinatedPercentage
From PopVSVac
--END

--TEMP Table
--START

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.Continent, dea.Location, dea.Date, dea.Population, vac.New_Vaccinations,
SUM(CONVERT(int, vac.New_Vaccinations)) OVER (Partition by dea.Location Order by dea.Location, dea.Date) as RollingPeopleVaccinated
From PorfolioProject..CovidDeaths dea
Join PorfolioProject..CovidVaccination vac
on dea.Location = vac.Location 
and dea.Date = vac.Date
--Where dea.Continent is not null
--Order by 2,3
Select *, (RollingPeopleVaccinated/Population)*100  as RollingPeopleVaccinatedPercentage
From #PercentPopulationVaccinated
--END

-- Creating View to Store Data for later Visualizations
Create View PercentPopulationVaccinated as
Select dea.Continent, dea.Location, dea.Date, dea.Population, vac.New_Vaccinations,
SUM(CONVERT(int, vac.New_Vaccinations)) OVER (Partition by dea.Location Order by dea.Location, dea.Date) as RollingPeopleVaccinated
From PorfolioProject..CovidDeaths dea
Join PorfolioProject..CovidVaccination vac
	on dea.Location = vac.Location 
	and dea.Date = vac.Date
Where dea.Continent is not null
--END

--Using new table PercentPopulationVaccinated
Select *
From PercentPopulationVaccinated