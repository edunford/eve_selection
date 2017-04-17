select * from hadoop.samples.eventLogs_Move_Jump

IF OBJECT_ID('tempdb..#jumps') IS NOT NULL DROP TABLE #jumps
CREATE TABLE #jumps (eventDate date, characterID bigint, destinationID bigint)
INSERT INTO #jumps (eventDate, characterID, destinationID)
EXEC hadoop.hive.query '
SELECT distinct a.dt as eventDate, characterID, destinationID
	FROM eventLogs_all a
	LATERAL VIEW json_tuple(a.value, "eventName","ownerID","destinationID") b AS eventName, characterID, destinationID
	WHERE dt between @date1 AND @date2 AND eventName = "Move_Jump"','2017-04-01','2017-04-07'


select count(*) from #jumps 
select top 100* from #jumps


-- use the characterhistory logs to tie a char with their corp within the relevant time window
IF OBJECT_ID('tempdb..#jumps2') IS NOT NULL DROP TABLE #jumps2
select
h.corporationID,
h.userID,
h.customerID,
iif(h.allianceID is not null,1,0) inAlliance, 
j.*
into #jumps2
from #jumps j
inner join ebs_FACTORY.eve.characterHistory h on (h.historyDate = j.eventDate and h.characterID = j.characterID)

select top 10* from #jumps2




-- copy and paste code to produce the rel corp sample
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

--- subset the week long jump log by the relevant corps
	IF OBJECT_ID('tempdb..#jumps3') IS NOT NULL DROP TABLE #jumps3;
	with tmp as (
	select distinct corporationID, propHighSec,propLowSec,propNullSec,propWormhole
	from #corpRec3
	)
	select
	j.*,
	t.propHighSec,
	t.propLowSec,
	t.propNullSec,
	t.propWormhole
	into #jumps3
	from #jumps2 j
	inner join tmp t on j.corporationID = t.corporationID 

select top 10* from #corpRec3
select top 10* from #jumps3

-- render table and then export to .csv to play around with generating interaction networks (for the rel. time period)
select * from #jumps3




