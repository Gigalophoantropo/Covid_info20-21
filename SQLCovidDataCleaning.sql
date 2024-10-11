Select *
From BigProject..CovidDeaths
Where continent is not NULL
Order By 3,4

Select *
From BigProject..CovidVaccinations
Order By 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From BigProject..CovidDeaths
Where continent is not NULL
Order By 1, 2

-- total_cases vs total_deaths
-- Shows likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 As DeathPercentage
From BigProject..CovidDeaths
Where location like '%states%'
And continent is not NULL
Order By 1, 2

--total_cases vs population
--Shows what percentage of population got covid
Select location, date, population, total_cases, (total_cases/population)*100 As PercentPopulationInfected
From BigProject..CovidDeaths
--Where location like '%states%'
Where continent is not NULL
Order By 1, 2


--Looking at Countries with High Infection Rate compared to Population

Select location, population, MAX(total_cases) As HighestInfectionCount, MAX((total_cases/population)*100) As PercentPopulationInfected
From BigProject..CovidDeaths
--Where location like '%states%'
Where continent is not NULL
Group By location, population
Order By PercentPopulationInfected desc


--Showing Countries with the Highest Death Count per Population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From BigProject..CovidDeaths
--Where location like '%states%'
Where continent is not NULL
Group By location
Order By TotalDeathCount desc	


--LET'S BREAK THINGS DOWN BY CONTINENT


--Showing Continents with the Highest Death Count per Population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From BigProject..CovidDeaths
--Where location like '%states%'
Where continent is NOT NULL
Group By location
Order By TotalDeathCount desc


-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases , SUM(cast(new_deaths as float)) as total_deaths, (SUM(cast(new_deaths as float))/SUM(new_cases))*100 As DeathPercentage
From BigProject..CovidDeaths
--Where location like '%states%'
Where continent is not NULL
--Group By date
Order By 1, 2



--Loking at Total Population vs Vaccinations
--CTE
With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.date) As RollingPeopleVaccinated
From BigProject..CovidDeaths dea
Join BigProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac
Order By 2, 3


--Temp Table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.date) As RollingPeopleVaccinated
From BigProject..CovidDeaths dea
Join BigProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated
Order By 2, 3


--Creating View to store Data for later visualizations

GO

Create View PercentPopulationVaccinated1 as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
	dea.date) As RollingPeopleVaccinated
From BigProject..CovidDeaths dea
Join BigProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2, 3