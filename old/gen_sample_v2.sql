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

			-- check
			--select count(*) from #corpRec -- 906,501 entries
			--select count(distinct corporationID) from #corpRec -- 128,467 corporations
			--select top 1000* from #corpRec


		-- ID number of unique players (humans) in each corporation
		--select 
		--distinct cr.corporationID,
		--sum(iif(cr.creatorEmail = cr.employeeEmail, 1, 0))  as numCreatorAsEmployee,
		--count(distinct cr.employeeEmail) as distinctEmails,
		--count(distinct cr.employeeCharID) as distinctEmployees
		--from #corpRec cr
		--group by cr.corporationID
		--having count(distinct cr.employeeEmail) >= 5 and sum(iif(cr.creatorEmail = cr.employeeEmail, 1, 0)) !=  count(distinct cr.employeeEmail) 
		--order by  count(distinct cr.employeeEmail) desc

		-- 17,663 corporations contain 5 or more members who are not all the creator that were created from 2015 onward



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

			-- check
			--select count(*) from #corpRec2 --- 623,744 Players
			--select count(distinct corporationID) from #corpRec2 --- 17,663 corporations
			--select max(distinctUsers) as max, min(distinctUsers) as min from #corpRec2 -- Max No. of members: 24,976 and a Min No. of Members: 5



		-- (1) subset the character history logs to only deal with the relevant corporations (This took way too long)
			--IF OBJECT_ID('tempdb..#histRelCorps') IS NOT NULL DROP TABLE #histRelCorps;
			--with sub as ( 
			--	select
			--	corporationID,
			--	historyDate,
			--	travelJumpsStargateHighSec,
			--	travelJumpsStargateLowSec,
			--	travelJumpsStargateNullSec,
			--	travelJumpsWormhole,
			--	travelJumpsStargateTotal
			--	from ebs_FACTORY.eve.characterHistory
			--	where historyDate >= '2015-01-01'
			--)
			--select s.*
			--into #histRelCorps
			--from #corpRec2 cr inner join sub s on cr.corporationID = s.corporationID


IF OBJECT_ID('tempdb..#corpJumpRec') IS NOT NULL DROP TABLE #corpJumpRec;
with jumpRec as (
	select
	max(ch.corporationID) as corporationID,
	max(cast(month(ch.historyDate) as varchar(2))) as month,
	max(cast(year(ch.historyDate) as varchar(4))) as year,
	(sum(ch.travelJumpsStargateHighSec)+0.0)/(sum(ch.travelJumpsStargateTotal) + sum(ch.travelJumpsWormhole))  as propHighSec,
	(sum(ch.travelJumpsStargateLowSec)+0.0)/(sum(ch.travelJumpsStargateTotal) + sum(ch.travelJumpsWormhole))  as propLowSec,
	(sum(ch.travelJumpsStargateNullSec)+0.0)/(sum(ch.travelJumpsStargateTotal) + sum(ch.travelJumpsWormhole)) as propNullSec,
	(sum(ch.travelJumpsWormhole)+0.0)/(sum(ch.travelJumpsStargateTotal) + sum(ch.travelJumpsWormhole))  as propWormhole,
	(sum(ch.travelJumpsStargateTotal) + sum(ch.travelJumpsWormhole)) as totalJumps
	from ebs_FACTORY.eve.characterHistory ch
	where ch.historyDate >= '2015-01-01'
	group by month(ch.historyDate)+'-'+year(ch.historyDate)+'-'+ch.corporationID
) select 
max(corporationID) as corporationID,
iif(AVG(jr.propHighSec) is null,0,AVG(jr.propHighSec)) as propHighSec,
iif(AVG(jr.propLowSec) is null,0,AVG(jr.propLowSec)) as propLowSec,
iif(AVG(jr.propNullSec) is null,0,AVG(jr.propNullSec)) as propNullSec,
iif(AVG(jr.propWormhole) is null,0,AVG(jr.propWormhole)) as propWormhole,
iif(AVG(jr.totalJumps) is null,0,AVG(jr.totalJumps)) as aveMonthlyTotalJumps
into #corpJumpRec
from jumpRec jr 
group by corporationID

		-- check
		--select top 10* from #corpJumpRec

-- merge with extant corp list
IF OBJECT_ID('tempdb..#corpRec3') IS NOT NULL DROP TABLE #corpRec3
select 
cr.*,
cjr.propHighSec,
cjr.propLowSec,
cjr.propNullSec,
cjr.propWormhole,
cjr.aveMonthlyTotalJumps
into #corpRec3
from #corpRec2 cr 
left join #corpJumpRec cjr on cjr.corporationID = cr.corporationID

			 -- check
			 --select count(distinct corporationID) from #corpRec2
			 --select count(distinct corporationID) from #corpRec3
			 --select count(*) from #corpRec2
			 --select count(*) from #corpRec3
			 ---- No loss

			 --select count(distinct corporationID) from #corpRec3 where propNullSec >= .5 -- 1329 corps that spend 50%+ in Nullsec
			 --select count(distinct corporationID) from #corpRec3 where propLowSec >= .5 -- 228 corps that spend 50%+ in Lowsec
			 --select count(distinct corporationID) from #corpRec3 where propWormhole >= .5 -- 58 corps that spend 50%+ in Wormholes
			 --select count(distinct corporationID) from #corpRec3 where propHighSec >= .5 -- 10,527 (vast majority) spend most of their time in high sec
			 --select count(distinct corporationID) from #corpRec3 where propHighSec < .5  -- 5194 corps spend less than 50% of their time in High sec on ave.
			 --select count(distinct corporationID) from #corpRec3 where aveMonthlyTotalJumps = 0 -- 2717 corps inactive.


			 --select * from #corpRec3 -- let's save for later in R.
			 --select distinct corporationID from #corpRec3 where propNullSec >= .5



			 select top 100* from #corpRec3