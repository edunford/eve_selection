--- building up the applications table from 2015 to 2017 (two year period)

use edvald_research

-- create initial save table into permanent table. 
-- create table umd.corporationApps (eventDate date, corporationID bigint, receiverID bigint, senderID bigint, status tinyint)

-- HADOOP TABLE
		declare @counterDate1 date = '2015-12-01';
		declare @counterDate2 date = '2016-04-30';
		INSERT INTO umd.corporationApps (eventDate, corporationid, receiverid, senderid, status)
		EXEC hadoop.hive.query '
		SELECT date as eventDate, corporationID, receiverID, senderID, status_
		  FROM eventLogs_all a
		LATERAL VIEW json_tuple(a.value, "eventName", "dateTime", "corporationID", "ownerID", "fromCharID", "status") b AS eventName, date, corporationID, receiverID, senderID, status_
		 WHERE dt between @date1 AND @date2 AND eventName = "corporation::InsertApplication"',@counterDate1, @counterDate2


select count(*) from umd.corporationApps

-- track progress
select eventDate, count(*) as total, sum(iif(status = 8, 1, 0)) as invites,sum(iif(status = 0, 1, 0)) as applied
		from umd.corporationApps
		group by eventDate
		order by eventDate
		