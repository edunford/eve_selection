IF OBJECT_ID('tempdb..#applications') IS NOT NULL DROP TABLE #applications
CREATE TABLE #applications (eventDate date, corporationID bigint, receiverID bigint, senderID bigint, status_ int)
declare @counterDate date = '2016-01-01';
INSERT INTO #applications (eventDate, corporationid, receiverid, senderid, status_)
EXEC hadoop.hive.query '
SELECT date as eventDate, corporationID, receiverID, senderID, status_
  FROM eventLogs_all a
LATERAL VIEW json_tuple(a.value, "eventName", "dateTime", "corporationID", "ownerID", "fromCharID", "status") b AS eventName, date, corporationID, receiverID, senderID, status_
 WHERE dt >= @date1 AND eventName = "corporation::InsertApplication"',@counterDate


select top 10* from #applications

 -- example of the application json
 -- {"status": 0, "corporationID": 98324027, "fromCharID": 2112594331, "ownerID": 2112594331, "dateTime": "2017.04.01 18:02:24.132", "eventName": "corporation::InsertApplication", "locationID": null, "applicationID": 5515862}



IF OBJECT_ID('tempdb..#applications2') IS NOT NULL DROP TABLE #applications2
CREATE TABLE edvald_research.umd.applications (eventDate date, corporationID bigint, receiverID bigint, senderID bigint, status_ int)

select * from edvald_research.umd.

declare @counterDate date = '2017-04-01';
INSERT INTO #applications2 (eventDate, corporationid, receiverid, senderid, status_)
EXEC hadoop.hive.query '
SELECT date as eventDate, corporationID, receiverID, senderID, status_
  FROM eventLogs_all a
LATERAL VIEW json_tuple(a.value, "eventName", "dateTime", "corporationID", "ownerID", "fromCharID", "status") b AS eventName, date, corporationID, receiverID, senderID, status_
 WHERE dt = @date1 AND eventName = "corporation::InsertApplication"', @counterDate


select * from #applications2