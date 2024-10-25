Select *
From CovidProject..CovidDeaths
Where continent is not null
Order By 3,4

--Select *
--From CovidProject..CovidVaccinations
--order by 3,4

-- Select data we are using

Select Location, date, total_cases, new_cases, total_deaths, population
From CovidProject..CovidDeaths
Where continent is not null
Order By 1,2

--Looking at total cases vs total deaths
--had division by 0.
--shows likelihood of deaths in your USA if you had covid

Select Location, date, total_cases, total_deaths,(total_deaths / NULLIF(total_cases, 0))* 100 as deathPercentage
From CovidProject..CovidDeaths
Where location like '%states%'
And continent is not null
Order By 1,2

--Looking at total cases vs population
Select Location, date, population, total_cases,(total_cases / population)* 100 as populationInfectedPercentage
From CovidProject..CovidDeaths
Where location like '%states%'
And continent is not null
Order By 1,2


-- Countries with highest infection rate per population
Select Location, population, MAX(total_cases) as HighestInfection, MAX((total_cases / population))* 100 as populationInfectedPercentage
From CovidProject..CovidDeaths
Where continent is not null
Group By location, population
Order By populationInfectedPercentage desc

--Countries with highest death rate per population
Select Location, MAX(total_deaths) as TotalDeaths
From CovidProject..CovidDeaths
Where continent is not null
Group By location
Order By TotalDeaths desc

-- Continent with highest death rate per population
Select continent, MAX(total_deaths) as TotalDeaths
From CovidProject..CovidDeaths
Where continent is not null
Group By continent
Order By TotalDeaths desc


--Globally with date
Select date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/ SUM(nullif(new_cases, 0)) * 100 as deathPercentage
From CovidProject..CovidDeaths
Where continent is not null
Group By date
Order By 1,2

--Globally without date
Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/ SUM(nullif(new_cases, 0)) * 100 as deathPercentage
From CovidProject..CovidDeaths
Where continent is not null
Order By 1,2



-- Total Population vs Vaccinations
With PopVsVaccs (Continent, Location, Date, Population, NewVaccinations, RollingVaccinations)
AS (
	Select deaths.continent, deaths.location, deaths.date, deaths.population, vaccs.new_vaccinations,
	SUM(CAST(vaccs.new_vaccinations as bigint)) 
	OVER (Partition By deaths.location Order By deaths.location, deaths.date) as RollingVaccinations
	From CovidProject..CovidDeaths deaths
	Join CovidProject..CovidVaccinations vaccs
		ON deaths.location = vaccs.location
		AND deaths.date = vaccs.date
	Where deaths.continent is not null

)
Select *, (RollingVaccinations / Population) * 100 as RollingPercentage
From PopVsVaccs


Create View PercentPopVaccinated as
Select deaths.continent, deaths.location, deaths.date, deaths.population, vaccs.new_vaccinations,
	SUM(CAST(vaccs.new_vaccinations as bigint)) 
	OVER (Partition By deaths.location Order By deaths.location, deaths.date) as RollingVaccinations
	From CovidProject..CovidDeaths deaths
	Join CovidProject..CovidVaccinations vaccs
		ON deaths.location = vaccs.location
		AND deaths.date = vaccs.date
	Where deaths.continent is not null