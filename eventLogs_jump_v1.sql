-- backing out recruitment and jump records from the event logs

-- MAJOR issue: the event logs are on a rolling basis. Currently the logs only extedn back to the start of 2017
select top 10* from ebs_RESEARCH.zevent.ownerEvents --event logs
select min(eventDate) as minDate, max(eventDate) as maxDate from ebs_RESEARCH.zevent.ownerEventsEx --min: 2016-12-29 max: 2017-04-16
select top 10* from ebs_RESEARCH.zevent.ownerEventsEx where eventDate = '2017-04-05'

-- charID 96514232 who applied to CorpID 98399497 on 4.5.17
select top 5* from ebs_WAREHOUSE.owner.dimCharacterSCD where characterID = 96514232


-- hadoop jump logs
select * from hadoop.samples.eventLogs_Move_Jump


EXEC hadoop.hive.query '
SELECT max(a.dt) as Date, max(characterID) as charID, max(destinationID) as destinationID
	FROM eventLogs_all a
	LATERAL VIEW json_tuple(a.value, "eventName","ownerID","destinationID") b AS eventName, characterID, destinationID
	WHERE dt = @date1 AND characterID = 2112457093 AND eventName = "Move_Jump"
	group by (a.dt and destinationID)','2017-04-15'
	