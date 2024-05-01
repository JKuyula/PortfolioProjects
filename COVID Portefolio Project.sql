--Select *
--From PortefolioProject..CovidDeaths$
--order by 3,4

Select Location, date, total_cases,new_cases,total_deaths, population
From PortefolioProject..CovidDeaths$
order by 1,2


--Looking at Total Cases vs Total Deaths
Select Location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From PortefolioProject..CovidDeaths$
Where location like '%states%'
order by 1,2


--Looking at TotalCases vs Population
--Shows what percentage of population got covid
Select Location, date,population, total_cases,(total_cases/population)*100 as  PercentPopulationInfected
From PortefolioProject..CovidDeaths$
--Where location like '%states%'
order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population
Select Location,population, MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as PercentPopulationInfected
From PortefolioProject..CovidDeaths$
Group by Location, Population
order by PercentPopulationInfected desc

--Showing Countries with Highest Death Count per Population
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortefolioProject..CovidDeaths$
Where continent is not null
Group by Location
order by TotalDeathCount desc

--LET'S BREAK THINGS BY CONTINENT
Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortefolioProject..CovidDeaths$
Where continent is null
Group by location
order by TotalDeathCount desc


--Showing continents with the highest death count per population
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortefolioProject..CovidDeaths$
Where continent is not null
Group by continent
order by TotalDeathCount desc

--GLOBALS NUMBERS

Select date,SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortefolioProject..CovidDeaths$
where continent is not null
group by date
order by 1,2

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortefolioProject..CovidDeaths$
where continent is not null
order by 1,2

--Looking at total population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortefolioProject..CovidDeaths$ dea
Join PortefolioProject..CovidVaccinations$ vac
   on dea.location = vac.location
   and dea.date =vac.date
where dea.continent is not null
order by 2,3

--USE CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortefolioProject..CovidDeaths$ dea
Join PortefolioProject..CovidVaccinations$ vac
   on dea.location = vac.location
   and dea.date =vac.date
where dea.continent is not null
)
Select * , (RollingPeopleVaccinated/Population)*100
From PopvsVac







--TEMP TABLE


Create Table #PercentagePopulationVaccinated
(Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentagePopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortefolioProject..CovidDeaths$ dea
Join PortefolioProject..CovidVaccinations$ vac
   on dea.location = vac.location
   and dea.date =vac.date
where dea.continent is not null


Select * , (RollingPeopleVaccinated/Population)*100
From #PercentagePopulationVaccinated


-- Creating View to store data for later vizualizations
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortefolioProject..CovidDeaths$ dea
Join PortefolioProject..CovidVaccinations$ vac
   on dea.location = vac.location
   and dea.date =vac.date
where dea.continent is not null

Select *
From PercentPopulationVaccinated
