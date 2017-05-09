--- manually extract warp-to-logs from cluster

select * from hadoop.samples.eventLogs_park__Warp_Char




use edvald_research

-- create initial save table into permanent table.
--drop table umd.warptologs
		--create table umd.warptologs (eventDate date,characterID bigint, toCharID bigint, autopilot bit, fleetWarp bit, minDist float) 

-- HADOOP TABLE	
		declare @counterDate1 date = '2016-01-01';
		declare @counterDate2 date = '2016-04-30';
		insert into umd.warptologs (eventDate, characterID, toCharID, autopilot, fleetWarp, minDist)
		EXEC hadoop.hive.query '
		SELECT date as eventDate, ownerID as characterID, subjectType as toCharID, autopilot as autopilot, fleetWarp, minDist
			FROM eventLogs_all a
		LATERAL VIEW json_tuple(a.value, "eventName", "dateTime", "ownerID","subjectType","autopilot","fleetWarp","minDist") b AS eventName, date, ownerID, subjectType, autopilot, fleetWarp, minDist
			WHERE dt between @date1 AND @date2 AND eventName = "park::Warp_Char"',@counterDate1, @counterDate2


-- check progress
select count(*) from umd.warptologs
select min(eventDate), max(eventDate) from umd.warptologs
select top 10* from umd.warptologs
