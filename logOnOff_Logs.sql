-- "Logged On" Logs

-- event_logs: logged on == 30005 & logged off == 30006

-- select all logged on records
select *
into #loggedon
from ebs_ARCHIVE.zevent.ownerEvents
where (eventTypeID = 30005 or eventTypeID = 30006) and eventDate >= '2015-01-01'


select min(eventDate), max(eventDate) from #loggedon

-- generate an indicator if a player was logged on for a specific date.
-- As log on times can span a day (i.e. log on to play at 10pm log off at 1am)
-- one needs to use both the on and off times.

-- what's useful is that an appearance in these logs for a date means the player was 
-- online at some point.


-- fold in corporation information
select 
format(l.eventDate,'yyyy-MM-dd') as eventDate,
l.eventDate as eventDatePrecise,
h.corporationID,
h.characterID,
iif(l.eventTypeID = 30005,'logon','logoff') as eventType
into #loggedon2
from #loggedon l 
inner join ebs_FACTORY.eve.characterHistory h on (l.ownerID = h.characterID and format(l.eventDate,'yyyy-MM-dd') = h.historyDate)
