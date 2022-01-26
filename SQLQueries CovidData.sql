Select *
from PortfolioProject..[covid-deaths]
order by 3,4

--Select *
--from PortfolioProject..[covid-vaccination]
--order by 3,4



---Selecting the Date to be used ---


Select location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..[covid-deaths]
order by 1,2

----Looking at Death Percentage or Total deaths vs total cases location wise--


Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..[covid-deaths]
where location like '%states%'
order by 1,2

Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..[covid-deaths]
where location like '%India%'
order by 1,2

----Looking at Total cases Vs Population--
----What percentage of population got Covid


Select location,date,total_cases,population,(total_cases/population)*100 as CovidPercentage
from PortfolioProject..[covid-deaths]
--where location like '%India%'
where location like '%states%'
order by 1,2


---Looking at countries with highest infection Rate compared to population---

Select location,population,Max(total_cases)as InfectionCount,
Max((total_cases/population))*100 as PercentagePopulationInfected
from PortfolioProject..[covid-deaths]
--where location like '%India%'
--where location like '%states%'
group by location,population
order by PercentagePopulationInfected desc

-----Date wise Highest Infected population
Select location,population,date,Max(total_cases)as InfectionCount,
Max((total_cases/population))*100 as PercentagePopulationInfected
from PortfolioProject..[covid-deaths]
--where location like '%India%'
--where location like '%states%'
group by location,population,date
order by PercentagePopulationInfected desc


---Looking for countries with Highest TotalDeathCount

Select location,MAX(cast(total_deaths as int)) as TotalDeathCount 
from PortfolioProject..[covid-deaths]
--where continent is NULL
where continent is NULL and location not in ('World','European Union', 
'International','Upper middle income','High income','Lower middle income','Low income')
group by location
order by TotalDeathCount  desc


---Lets Breal down by Continets with highest death count 

Select continent,MAX(cast(total_deaths as int)) as TotalDeathCount 
from PortfolioProject..[covid-deaths]
where continent is NOT NULL
group by continent
order by TotalDeathCount  desc

----Global Numbers
Select Sum(new_cases) as Total_Cases,Sum(Cast(new_deaths as int))as Total_deaths,
(Sum(Cast(new_deaths as int))/Sum(new_cases) )*100 as CovidDeathPercentage
from PortfolioProject..[covid-deaths]
where continent is NOT NULL
order by 1,2


----Total amount of people in the world vaccinated

Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
Sum(Cast(vac.new_vaccinations as bigint))	
OVER(partition by dea.location order by dea.location,dea.Date) as RunningTotalPeopleVaccinated

from PortfolioProject..[covid-deaths] as dea
join PortfolioProject..[covid-vaccination] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


-----Using Temp Table
Drop table if exists #PercentagePopulationVaccinated

Create Table #PercentagePopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population int,
new_vaccinations bigint,
RunningTotalPeopleVaccinated bigint
)
Insert into #PercentagePopulationVaccinated
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
Sum(Cast(vac.new_vaccinations as bigint))	
OVER(partition by dea.location order by dea.location,dea.Date) as RunningTotalPeopleVaccinated

from PortfolioProject..[covid-deaths] as dea
join PortfolioProject..[covid-vaccination] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

Select * ,(RunningTotalPeopleVaccinated/Population)*100
from #PercentagePopulationVaccinated

----Storing Data in View for Visualization

Create View PercentagePopulationVaccinated as
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
Sum(Cast(vac.new_vaccinations as bigint))	
OVER(partition by dea.location order by dea.location,dea.Date) as RunningTotalPeopleVaccinated

from PortfolioProject..[covid-deaths] as dea
join PortfolioProject..[covid-vaccination] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null








