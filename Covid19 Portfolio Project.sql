--select all columns in the CovidDeaths table ordering by location and date
select *
from PortfolioProject..CovidDeaths 
order by 3,4

--select all columns in the CovidVaccinations table ordering by location and date
select *
from PortfolioProject..CovidVaccinations 
order by 3,4

--select below columns from the CovidDeaths table ordering by location and date
select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths 
order by 1,2

--Total_cases vs Total death with Death Percentage in Nigeria (Likelihood of death if contracted Covid)
select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as Percentage_Of_death
from PortfolioProject..CovidDeaths 
where location like '%nigeria%'
order by 1,2

---Countries with highest rate of infection compared to their population
select location, population, MAX(total_cases) as Highest_number_of_infection, MAX((total_cases/population)) * 100 as Percentage_Of_Population_infected
from PortfolioProject..CovidDeaths 
where continent is not null
group by location, population
order by Percentage_Of_Population_infected desc


---countries with the highest number of death
select location, MAX(cast(total_deaths as int)) as Highest_number_of_death
from PortfolioProject..CovidDeaths 
where continent is not null
group by location
order by Highest_number_of_death desc

---Continents with highest death count per population
select location, MAX(cast(total_deaths as int)) as Highest_number_of_death
from PortfolioProject..CovidDeaths
where continent is null
group by location
order by Highest_number_of_death desc


--Global number
--Death Percentage across the world
select sum(new_cases) as Total_cases, sum(cast(new_deaths as int)) as Total_deaths, (sum(cast(new_deaths as int)) / sum(new_cases)) * 100  as Death_Percentage
from PortfolioProject..CovidDeaths 
where continent is not null
--group by date
order by 1, 2


--Percentage population of people vaccinated
with PopVsVac (Continent, Location, Date, Population, Vaccination, Summation_of_people_vaccinated) as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date)
from PortfolioProject..CovidVaccinations vac
join PortfolioProject..CovidDeaths dea
	on vac.location = dea.location
	and vac.date = dea.date
where dea.continent is not null
--order by 2,3
)
select *, (Summation_of_people_vaccinated / population) * 100
from PopVsVac

--Percentage population of people vaccinated (Alternative, using Temp Table)
drop table if exists #PercentageOfVaccinatedPeople
create table #PercentageOfVaccinatedPeople
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
Vaccination numeric,
Summation_of_people_vaccinated numeric
)

insert into #PercentageOfVaccinatedPeople
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date)
from PortfolioProject..CovidVaccinations vac
join PortfolioProject..CovidDeaths dea
	on vac.location = dea.location
	and vac.date = dea.date
where dea.continent is not null

select *, (Summation_of_people_vaccinated / population) * 100
from #PercentageOfVaccinatedPeople


--Creating a view for visualization
create view PercentageOfVaccinatedPeople as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as Summation_of_people_vaccinated
from PortfolioProject..CovidVaccinations vac
join PortfolioProject..CovidDeaths dea
	on vac.location = dea.location
	and vac.date = dea.date
where dea.continent is not null
--order by 2,3

select * from PercentageOfVaccinatedPeople