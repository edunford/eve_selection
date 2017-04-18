-- Generating a Sample of corps that (a) contain humans (min of five unique players), (b) are not dust corps, 
-- and (c) operate in low/Null sec (and wormholes) at least 50% of the time (as determined be where they jump on average)

IF OBJECT_ID('tempdb..#corpRec') IS NOT NULL DROP TABLE #corpRec
select
corps.corporationID,
corpName.corporationName,
corps.createDate as corpCreateDate,
corps.creatorID as creatorCharID,
chars2.characterName as creatorCharName,
users2.userID as creatorUserID,
lower(users2.eMail) as creatorEmail,
users2.dateOfBirth as creatorDOB,
users2.gender as creatorGender,
users2.createDate as creatorUserCreateDate,
users2.characterCreateDate as creatorCharCreateDate,
users2.languageName as creatorLanguage,
employ.characterID as employeeCharID,
users.userID as employeeUserID,
employ.characterName employeeCharName,
employ.startDate as hireDate,
lower(users.eMail) as employeeEmail,
users.isActive as isEmployeeActive,
users.dateOfBirth as employeeDOB,
users.gender as employeeGender,
users.createDate as employeeUserCreateDate,
users.characterCreateDate as employeeCharCreateDate,
users.languageName as employeeLanguage
into #corpRec
from ebs_RESEARCH.dbo.crpCorporations corps
left join  ebs_RESEARCH.dustCharacter.charactersVx dust on dust.characterID = corps.creatorID 
inner join ebs_RESEARCH.dbo.crpEmploymentRecordsEx employ on employ.corporationID = corps.corporationID
inner join ebs_FACTORY.eve.characters chars on chars.characterID = employ.characterID
inner join ebs_FACTORY.eve.characters chars2 on chars2.characterID = corps.creatorID
inner join ebs_WAREHOUSE.customer.dimUser users on chars.userID = users.userID
inner join ebs_WAREHOUSE.customer.dimUser users2 on chars2.userID = users2.userID
left join ebs_RESEARCH.corporation.corporationsLookup corpName on corpName.corporationID = corps.corporationID
where dust.characterID is NULL -- drop corps created by dust characters
		and corps.creatorID > 1 -- drop NPC created corps
		and corps.createDate >= '2015-01-01' -- subset by creation date (only consider corps created when the recruitment data overlaps)


-- subset primary sample to generate a list of corps that satisfy conditions
IF OBJECT_ID('tempdb..#corpRec2') IS NOT NULL DROP TABLE #corpRec2;
with corpSample as 
(
	select 
	distinct cr.corporationID as corporationID2,
	count(distinct cr.employeeEmail) as distinctUsers
	from #corpRec cr
	group by cr.corporationID
	having count(distinct cr.employeeEmail) >= 5 and sum(iif(cr.creatorEmail = cr.employeeEmail, 1, 0)) !=  count(distinct cr.employeeEmail) 
)
select * into #corpRec2
from #corpRec c inner join corpSample cc on cc.corporationID2 = c.corporationID 


IF OBJECT_ID('tempdb..#corpJumpRec') IS NOT NULL DROP TABLE #corpJumpRec;
with jumptotals as (
	select
	max(ch.corporationID) as corporationID,
	max(cast(month(ch.historyDate) as varchar(2))) as month,
	max(cast(year(ch.historyDate) as varchar(4))) as year,
	sum(isnull(travelJumpsStargateHighSec,0)) as hightotals,
	sum(isnull(travelJumpsStargateLowSec,0)) as lowtotals,
	sum(isnull(travelJumpsStargateNullSec,0)) as nulltotals,
	sum(isnull(travelJumpsWormhole,0)) as wormtotals,
	(sum(isnull(travelJumpsStargateTotal,0)) + sum(isnull(travelJumpsWormhole,0))) as totaljumps
	from ebs_FACTORY.eve.characterHistory ch
	where ch.historyDate >= '2015-01-01'
	group by month(ch.historyDate)+'-'+year(ch.historyDate)+'-'+ch.corporationID
) select
	corporationID,
	month,
	year,
	(iif(totaljumps = 0, 0, ((hightotals+0.0)/totaljumps))) as propHighSec,
	(iif(totaljumps = 0, 0, ((lowtotals+0.0)/totaljumps))) as propLowSec,
	(iif(totaljumps = 0, 0, ((nulltotals+0.0)/totaljumps))) as propNullSec,
	(iif(totaljumps = 0, 0, ((wormtotals+0.0)/totaljumps))) as propWormhole,
	totaljumps as totalJumps
	into #corpJumpRec
	from jumptotals 


-- merge with extant corp list
IF OBJECT_ID('tempdb..#corpRec3') IS NOT NULL DROP TABLE #corpRec3;
with avejumps as (
	select 
		max(corporationID) as corporationID,
		AVG(propHighSec) as propHighSec,
		AVG(propLowSec) as propLowSec,
		AVG(propNullSec) as propNullSec,
		AVG(propWormhole) as propWormhole,
		AVG(totalJumps) as aveMonthlyTotalJumps
	from #corpJumpRec 
	group by corporationID
) select 
cr.*,
cjr.propHighSec,
cjr.propLowSec,
cjr.propNullSec,
cjr.propWormhole,
cjr.aveMonthlyTotalJumps
into #corpRec3
from #corpRec2 cr 
left join avejumps cjr on cjr.corporationID = cr.corporationID


-- save hard copy of sample for easy reference

select *
into edvald_research.umd.crpSampSelection
from #corpRec3


select top 10* from edvald_research.umd.crpSampSelection