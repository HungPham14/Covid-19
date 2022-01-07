--select *
--from CovidDeaths$
--order by 3,4

--select * 
--from CovidVaccinations$
--order by 3,4

--Select Data that we are going to be using
Select location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths$
where continent is not null
order by location, date

--Look at the Total Cases versus Total Deaths
--Show likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 as death_percentage
From CovidDeaths$
where continent is not null
where location like '%Viet%'
order by location, date

--Looking at the Total Cases versus Population
--Show the percentage of population got Covid-19
Select location, date, population, total_cases, (total_cases / population)*100 as covid_cases_percentage
from CovidDeaths$
where continent is not null
where location like '%Viet%'
order by location, date

--Looking at the country with highest infection rate compared to Population
Select location, population, max(total_cases) as highest_infection_count, max((total_cases / population)*100) as covid_cases_percentage
from CovidDeaths$
where continent is not null
group by location, population
order by covid_cases_percentage desc

--Looking at the country with highest death count compared to Population
Select location, population, max(cast(total_deaths as int)) as total_deaths_count
from CovidDeaths$
where continent is not null
group by location, population
order by total_deaths_count desc

--Showing continents with the highest death count per population
Select continent, max(cast(total_deaths as int)) as total_deaths_count
from CovidDeaths$
where continent is not null
group by continent
order by total_deaths_count desc

--GLOBAL NUMBERS
Select SUM(new_cases) as total_new_cases, SUM(cast(new_deaths as int)) as total_new_deaths, (SUM(cast(new_deaths as int)) / SUM(new_cases))*100 as deaths_percentage
from CovidDeaths$
where continent is not null
--group by date
--order by date

select * 
from CovidVaccinations$
order by 3,4

--TOTAL POPULATION VERSUS VACCINATIONS
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as total_new_vaccinations, 
(SUM(CONVERT(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) / dea.population)*100 as percentage_of_vaccinated_people
from PortfolioProjects..CovidDeaths$ dea
join PortfolioProjects..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
and vac.new_vaccinations is not null
order by 2,3

--TEMP TABLE
DROP table if exists #PercentageOfVaccinatedPopulation
Create Table #PercentageOfVaccinatedPopulation
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Total_new_vaccinations numeric,
Percentage_of_vaccinated_people float
)

Insert into #PercentageOfVaccinatedPopulation
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as total_new_vaccinations, 
(SUM(CONVERT(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) / dea.population)*100 as percentage_of_vaccinated_people
from PortfolioProjects..CovidDeaths$ dea
join PortfolioProjects..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--and vac.new_vaccinations is not null
--order by 2,3

Select *
from #PercentageOfVaccinatedPopulation
--where Continent is not null
--and New_vaccinations is not null
--order by 2,3

--Creating View to store data for later visualization

Create View PercentageOfVaccinatedPopulation as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as total_new_vaccinations, 
(SUM(CONVERT(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) / dea.population)*100 as percentage_of_vaccinated_people
from PortfolioProjects..CovidDeaths$ dea
join PortfolioProjects..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--and vac.new_vaccinations is not null
--order by 2,3