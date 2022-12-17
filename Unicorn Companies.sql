
Select *
From PortfolioProject..Unicorn_Companies

----------------------------------------------------------------------------------------------------------------
--Create columns and clean data


--Create new Valuation column without $ and B

Select
replace(replace(Valuation, '$',''),'B','') as Valuation_billions
From PortfolioProject..Unicorn_Companies

Alter Table PortfolioProject..Unicorn_Companies
Add Valuation_billions Numeric

Update PortfolioProject..Unicorn_Companies
set Valuation_billions = replace(replace(Valuation, '$',''),'B','000000000')

-- Create new Funding column without $, M, B or Unknown
-- Set Unknown as '999999999999' so the column could be numeric

Select
replace(replace(replace(replace(Funding, '$',''),'B','000000000'),'M','000000'),'Unknown', '999999999999') as Funding_Num
From PortfolioProject..Unicorn_Companies

Alter Table PortfolioProject..Unicorn_Companies
Drop column Funding_Num

Alter Table PortfolioProject..Unicorn_Companies
Add Funding_Num Numeric

Update PortfolioProject..Unicorn_Companies
set Funding_Num = replace(replace(replace(replace(Funding, '$',''),'B','000000000'),'M','000000'),'Unknown', '999999999999')

-- Create ROI column

Alter Table PortfolioProject..Unicorn_Companies
Add ROI Numeric;

Update PortfolioProject..Unicorn_Companies
set ROI = ROUND((Valuation_billions - funding_num) * 100.0/ Valuation_billions, 2)

--Years between founding and unicorn status reached

select Company
	, (datepart(YYYY, [date joined]) - [Year Founded]) as years_before_unicorn
from PortfolioProject..Unicorn_Companies

Alter Table PortfolioProject..Unicorn_Companies
Add years_before_unicorn Numeric

Update PortfolioProject..Unicorn_Companies
set years_before_unicorn = (datepart(YYYY, [date joined]) - [Year Founded])

----------------------------------------------------------------------------------------------------------------
--Look at the top 3 industries for 2019-2021

With top_industries AS(
	Select industry
	      , COUNT(*) as industry_num
	From PortfolioProject..Unicorn_Companies
	where datepart(YYYY, [date joined]) in ('2019', '2020', '2021')
	group by Industry
	order by industry_num desc
	Offset 0 rows fetch first 3 rows only
	),

yearly_rankings AS(
select COUNT(*) AS num_unicorns
		, industry
		, datepart(YYYY, [date joined]) as [year]
		, AVG(cast(valuation_billions as int)) as average_valuation
from PortfolioProject..Unicorn_Companies
group by Industry, datepart(YYYY, [date joined])
	)

Select Industry
	 , [year]
	 , num_unicorns
	 , average_valuation
From yearly_rankings
where [year] in ('2019', '2020', '2021')
	and industry in (select industry
					from top_industries)
group by industry, num_unicorns, [year], average_valuation
order by industry, [year] desc

--------------------------------------------------------------------------------------------------------------------------------------

--Look at the top 3 industries for 2015-2020

With top_industries AS(
	Select industry
	      , COUNT(*) as industry_num
	From PortfolioProject..Unicorn_Companies
	where datepart(YYYY, [date joined]) in ('2015', '2016', '2017', '2018', '2019', '2020', '2021')
	group by Industry
	),

yearly_rankings AS(
select COUNT(*) AS num_unicorns
		, industry
		, datepart(YYYY, [date joined]) as [year]
		, AVG(cast(valuation_billions as int)) as average_valuation
from PortfolioProject..Unicorn_Companies
group by Industry, datepart(YYYY, [date joined])
	)

Select Industry
	 , [year]
	 , num_unicorns
	 , average_valuation
From yearly_rankings
where [year] in ('2015', '2016', '2017', '2018', '2019', '2020', '2021')
	and industry in (select industry
					from top_industries)
group by industry, num_unicorns, [year], average_valuation
order by industry, [year] desc

----------------------------------------------------------------------------------------------------------------

--Look at the number of unicorns joined each year per country and their avg vluation for 2015-2021 

With top_industries AS(
	Select industry
	      , COUNT(*) as industry_num
	From PortfolioProject..Unicorn_Companies
	where datepart(YYYY, [date joined]) in ('2015', '2016', '2017', '2018', '2019', '2020', '2021')
	group by Industry
	order by industry_num desc
	Offset 0 rows fetch first 3 rows only
	),

yearly_rankings AS(
select COUNT(*) AS num_unicorns
		, industry
		, country
		, City
		, datepart(YYYY, [date joined]) as [year]
		, AVG(cast(valuation_billions as int)) as average_valuation
from PortfolioProject..Unicorn_Companies
where city is not null
group by country, city, Industry, datepart(YYYY, [date joined])
	)

Select Industry
	 , [year]
	 , country
	 , City
	 , num_unicorns
	 , average_valuation
From yearly_rankings
where [year] in ('2015', '2016', '2017', '2018', '2019', '2020', '2021')
	and industry in (select industry
					from top_industries)
group by industry, [year], country, city, num_unicorns, average_valuation
order by industry, [year] desc


Select *
From PortfolioProject..Unicorn_Companies
-----------------------------------------------------------------------------------------------------------------------------------------------

--Top 3 Industries for 2019-2021 (Number of Unicorns and AVG number of years Companies were established befor becoming Unicorns)

With top_industries AS(
	Select industry
	      , COUNT(*) as industry_num
	From PortfolioProject..Unicorn_Companies
	where datepart(YYYY, [date joined]) in ('2019', '2020', '2021')
	group by Industry
	order by industry_num desc
	Offset 0 rows fetch first 3 rows only
	)

Select Industry
	, datepart(YYYY, [date joined]) as [year]
	, COUNT(*) AS num_unicorns
	, AVG(cast(years_before_unicorn as int)) as num_years_bu
From PortfolioProject..Unicorn_Companies
where datepart(YYYY, [date joined]) in ('2019', '2020', '2021')
	and industry in (select industry
					from top_industries)
group by industry, datepart(YYYY, [date joined])
order by industry, datepart(YYYY, [date joined]) desc

-----------------------------------------------------------------------------------------------------------------------------------------------

--Look at Funding per Company

select Company
	, Industry
	, datepart(YYYY, [date joined]) as year
	, cast(Valuation_billions as bigint) as Valuation_billions
	, years_before_unicorn
	, funding_num
	, ROI
from PortfolioProject..Unicorn_Companies
where datepart(YYYY, [date joined]) in ('2015', '2016', '2017', '2018', '2019', '2020', '2021')
	and funding_num not like '%Unknown%'
order by funding_num desc

-----------------------------------------------------------------------------------------------------------------------------------------------

--Look at ROI per Company

select Company
	, Industry
	, datepart(YYYY, [date joined]) as year
	, Valuation_billions
	, years_before_unicorn
	, funding_num
	, ROI
from PortfolioProject..Unicorn_Companies
where datepart(YYYY, [date joined]) in ('2015', '2016', '2017', '2018', '2019', '2020', '2021')
order by ROI desc

-----------------------------------------------------------------------------------------------------------------------------------------------

--Years before Unicorn for the last 3 years across all sectors

select Company
	, Industry
	, datepart(YYYY, [date joined]) as year
	, Valuation_billions
	, years_before_unicorn
	, funding_num
	, ROI
from PortfolioProject..Unicorn_Companies
where datepart(YYYY, [date joined]) in ('2019', '2020', '2021')
order by datepart(YYYY, [date joined]), years_before_unicorn

--Years before Unicorn for the last 6 years across all sectors (Average)

Select Industry
	, datepart(YYYY, [date joined]) as [year]
	, COUNT(*) AS num_unicorns
	, AVG(cast(years_before_unicorn as int)) as num_years_bu
	, Round(AVG(ROI), 2) as avg_roi
From PortfolioProject..Unicorn_Companies
where datepart(YYYY, [date joined]) in ('2015', '2016', '2017', '2018', '2019', '2020', '2021')
	and Funding_Num not like 999999999999
group by industry, datepart(YYYY, [date joined])
order by industry, datepart(YYYY, [date joined]), AVG(cast(years_before_unicorn as int))

Select Industry
	, count(case when datepart(YYYY, [date joined]) = ('2020') then Company else NULL end) as num_2020
	, count(case when datepart(YYYY, [date joined]) = ('2021') then Company else NULL end) as num_2021
From PortfolioProject..Unicorn_Companies
group by Industry

Select *
From PortfolioProject..Unicorn_Companies