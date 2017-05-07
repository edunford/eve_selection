--- manually extract warp-to-logs from cluster

select * from hadoop.samples.eventLogs_park__Warp_Char




use edvald_research

-- create initial save table into permanent table. 
--create table umd.warptologs (eventDate date, corporationID bigint, characterID bigint, targetID bigint, locationID bigint, minDist float)

-- HADOOP TABLE
		declare @counterDate1 date = '2017-04-14';
		declare @counterDate2 date = '2017-04-15';
		INSERT INTO umd.warptologs (eventDate, corporationid, characterID, targetID, locationID,minDist)
		EXEC hadoop.hive.query '
		SELECT date as eventDate, corporationID, characterID, targetID, locationID, minDist
		  FROM eventLogs_all a
		LATERAL VIEW json_tuple(a.value, "eventName", "dateTime", "corporationID", "ownerID", "subjectID", "locationID" ,"minDist") b AS eventName, date, corporationID, characterID, targetID, locationID, minDist
		 WHERE dt between @date1 AND @date2 AND eventName = "park::Warp_Char"',@counterDate1, @counterDate2

