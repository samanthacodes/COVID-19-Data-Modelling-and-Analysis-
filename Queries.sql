# Final Project SQL Queries
# Race and Ethnicity Data Query
SELECT 
    s.date,
    ecd.state,
    ecd.white_cperd,
    ecd.white_cperd*s.cases AS White_Cases,
    ecd.white_pop,
    ecd.black_cperd,
    ecd.black_cperd*s.cases AS Black_Cases,
    ecd.black_pop,
    ecd.hispanic_cperd,
    ecd.hispanic_cperd*s.cases AS Hispanic_Cases,
    ecd.hispanic_pop, 
    ecd.asian_cperd,
    ecd.asian_cperd*s.cases AS Asian_Cases,
    ecd.asian_pop,
    ecd.amind_alaska_cperd,
    ecd.amind_alaska_cperd*s.cases AS Amind_Alaska_Cases,
    ecd.amind_alaska_pop,
    ecd.hawaiian_cperd,
    ecd.hawaiian_cperd*s.cases AS Hawaiian_Cases,
    ecd.hawaiian_pop,
    ecd.other_cperd,
    ecd.other_cperd*s.cases AS Other_Cases,
    ecd.other_pop,
    s.cases as total_cases, 
    p.population
FROM
    us_states  AS s
		INNER JOIN
    ethnicity_cases_deaths ecd ON s.state = ecd.state
		JOIN 
    population p ON p.state = s.state
WHERE
	ecd.category = 'Cases'
GROUP BY ecd.state;

# Query for getting cases, deaths, tests and population by state and month
select t.state, s.id, month(str_to_date(t.date, "%m/%e/%Y")) as month, sum(t.cases) as cases, sum(t.deaths) as deaths, sum(t.tests) as tests, p.population
from trend_data t
join state s on s.name = t.state
join population p on p.state = s.name
where t.state not in ('US Total', 'American Samoa', 'Diamond Princess', 'Grand Princess', 'Northern Mariana Islands')
group by month, state, id;

# Query for drug related studies conducted in each state
SELECT
	a.state,
    COUNT(DISTINCT(a.trial_id))
FROM
    trial_state_lookup a
		JOIN
	trials b ON a.trial_id = b.trial_id
WHERE
	b.intervention_category_id = 1001 # for drug specific studies
GROUP BY a.state;

# Query for county level mask data and rate of infection
SELECT
	a.state,
a.county,
 ((a.cases / b.population)*10) as rate_of_infection_percent, #percentage calc.
((c.NEVER*1) + ( c.RARELY* 2) + ( c.SOMETIMES*3) + ( c.FREQUENTLY*4) + (    c.ALWAYS*5)) as Mask_Use_Weighted_Score #likert weighted scale, for self reporting
from
	mask_use_by_county c
		JOIN
    recent_county_counts a ON c.COUNTYFP=a.fips
		JOIN
	population b on a.state = b.state
GROUP BY a.fips
ORDER BY rate_of_infection_percent DESC;


#Query for new us_counties table to fix the FIPS code for Tableau Visualization

CREATE TABLE `us_counties_fips_1` (
  `date` datetime DEFAULT NULL,
  `county` text,
  `state` text,
  `fips` text,
  `cases` int(11) DEFAULT NULL,
  `deaths` int(11) DEFAULT NULL
) ;

insert into us_counties_fips_1
select * from us_counties;

set sql_safe_updates = 0;
update us_counties_fips_1 
set fips = concat(0,fips) 
where fips like '____';

insert into us_counties_fips
select * from us_counties;

set sql_safe_updates = 0;
update us_counties_fips 
set fips = concat(0,fips) 
where fips like '____';

select * from us_counties_fips_1; 


#Query for new mask_use table to fix the FIPS code for Tableau Visualization

CREATE TABLE `mask_use_by_county_fips` (
  `COUNTYFP` text,
  `NEVER` double DEFAULT NULL,
  `RARELY` double DEFAULT NULL,
  `SOMETIMES` double DEFAULT NULL,
  `FREQUENTLY` double DEFAULT NULL,
  `ALWAYS` double DEFAULT NULL
) ;

insert into mask_use_by_county_fips
select * from mask_use_by_county;

set sql_safe_updates = 0;
update mask_use_by_county_fips 
set countyfp = concat(0,countyfp) 
where countyfp like '____';

select * from mask_use_by_county_fips;

