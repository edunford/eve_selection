-- Fleets and warp records


-- we know that the "warp to" record exists because it is presented as an aggregated statistic in the character history tables
select top 5
corporationID,
characterID,
travelWarpsToFleetMember
from ebs_FACTORY.eve.characterHistory

-- scan of the available hadoop logs
select top 10* from hadoop.samples.eventLogs_fleet__AcceptInvite -- accept invite into a fleet
select top 10* from hadoop.samples.eventLogs_fleet__Created -- fleet creation
select top 10* from hadoop.samples.eventLogs_fleet__CreateSquad -- creating a squad
select top 10* from hadoop.samples.eventLogs_fleet__MoveMember	-- moving members in a fleet
select top 10* from hadoop.samples.eventLogs_fleet__AddToWatchlist -- tracking another member in the fleet (usually for repairs)
select top 10* from hadoop.samples.eventLogs_fleet__Broadcast 
select top 10* from hadoop.samples.eventLogs_park__FleetWarp -- Group fleet movements
select top 10* from hadoop.samples.eventLogs_park__FleetWarp_Lead -- Group fleet movements from the perspective of the leader.
select * from hadoop.samples.eventLogs_park__Warp_Item where fleetWarp = 'True'
select * from hadoop.samples.eventLogs_park__Warp_Char 


-- Look at the Char Warp table for one day
	IF OBJECT_ID('tempdb..#warpto') IS NOT NULL DROP TABLE #warpto
	create table #warpto (eventDate date,characterID bigint, toCharID bigint, autopilot bit, fleetWarp bit, minDist float)
	declare @counterDate1 date = '2017-04-01';
	insert into #warpto (eventDate, characterID, toCharID, autopilot, fleetWarp, minDist)
	EXEC hadoop.hive.query '
	SELECT date as eventDate, ownerID as characterID, subjectType as toCharID, autopilot as autopilot, fleetWarp, minDist
		FROM eventLogs_all a
	LATERAL VIEW json_tuple(a.value, "eventName", "dateTime", "ownerID","subjectType","autopilot","fleetWarp","minDist") b AS eventName, date, ownerID, subjectType, autopilot, fleetWarp, minDist
		WHERE dt = @date1 AND eventName = "park::Warp_Char"',@counterDate1

	select top 10* from #warpto


-- Look at the Fleet Warp table for the same day

	IF OBJECT_ID('tempdb..#fleetwarp') IS NOT NULL DROP TABLE #fleetwarp
	create table #fleetwarp (eventDate date,characterID bigint, toCharID bigint, otherOwnerID bigint, fleetID bigint, minRange float)
	declare @counterDate1 date = '2017-04-01';
	insert into #fleetwarp (eventDate, characterID, toCharID, otherOwnerID, fleetID, minRange)
	EXEC hadoop.hive.query '
	SELECT date as eventDate, ownerID as characterID, warpingCharID as toCharID, otherOwnerID, fleetID, minRange
		FROM eventLogs_all a
	LATERAL VIEW json_tuple(a.value, "eventName", "dateTime", "ownerID","warpingCharID","otherOwnerID","fleetID","minRange") b AS eventName, date, ownerID, warpingCharID, otherOwnerID, fleetID, minRange
		WHERE dt = @date1 AND eventName = "park::FleetWarp"',@counterDate1



select top 10* from #warpto

select sum(iif(autopilot=1,1,0)) as ap,sum(iif(autopilot=0,1,0)) as noap  from #warpto -- K. noted that there is no auto pilot feature, so this makes sense. 

select top 10* from #fleetwarp



-- combine and assess
			select 
			w.characterID as chID_W,
			fw.characterID as chID_F,
			w.toCharID as tochID_W,
			fw.toCharID as tochID_F,
			w.fleetWarp
			from #warpto w 
			full outer join #fleetwarp fw on fw.characterID = w.characterID

			-- there doesn't appear to be any direct relationship between the fleet jump record and the charWarp record. 



			select top 100
			corporationID,
			characterID,
			travelWarpsToFleetMember
			from ebs_FACTORY.eve.characterHistory
			where historyDate = '2017-04-01' and travelWarpsToFleetMember is not null

			select *
			from #warpto
			where characterID = 224139360


			select *
			from #warpto
			where characterID = 94999667

			-- this is, in fact, the "travelWarpsToFleetMember" record in the character history table.
			-- the "fleetWarp" column appears to not reveal membership. 


-- map on corp info to character IDs.
drop table #warpto2
		with tmp as (
			select
			characterID, 
			corporationID
			from ebs_FACTORY.eve.characterHistory
			where historyDate = '2017-04-01'
		)	select 
			w.eventDate,
			ch.corporationID,
			w.characterID,
			ch2.corporationID as toCorpID,
			w.toCharID,
			w.minDist
			into #warpto2
			from #warpto w
			inner join tmp ch on w.characterID = ch.characterID
			inner join tmp ch2 on  w.toCharID = ch2.characterID



select * from #warpto2
select sum(iif(corporationID = toCorpID,1,0)) as sameCorp, count(*) as N from #warpto2

-- the when players "warp to" other players, it's sometimes players in their corporation, other times it is players out side their corporation.


-- let's clean the logs to contain only the relevant characters and then assess their network behavior in R. 
with tt as (
select distinct corporationID
from edvald_research.umd.crpSampSelection
) select 
w.*
into #tmp
from #warpto2 w 
inner join tt c on w.corporationID = c.corporationID 
where w.corporationID = w.toCorpID 


select top 10* from edvald_research.umd.crpSampSelection


select * from #tmp


---- the network images that emerge from this set up are quite revealing. Just as a test. Let's try and back out K.'s 
---- alliance activity for the relelvant time period. AllianceID = 99003615
drop table #tmp
with tt as (
select
distinct corporationID
from ebs_FACTORY.eve.characterHistory 
where allianceID = 99003615 and historyDate = '2017-04-01'
) select 
w.*
into #tmp
from #warpto2 w 
inner join tt c on w.corporationID = c.corporationID 


select
t.*,
cp.corporationName as cpname,
cp2.corporationName as tocpname
into edvald_research.umd.kartanAlliance
from #tmp t 
inner join ebs_RESEARCH.corporation.corporationsLookup cp  on t.corporationID = cp.corporationID 
inner join ebs_RESEARCH.corporation.corporationsLookup cp2 on t.corporationID = cp2.corporationID 


drop table edvald_research.umd.kartanAlliance


