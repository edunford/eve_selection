-- backing out jump records from the event logs

-- examine the immediate records to gather a picture of the current.
select top 10* from ebs_RESEARCH.zevent.ownerEventsEx where eventTypeID = 130
select top 10* from ebs_RESEARCH.zevent.ownerEventsEx where eventTypeID = 130

-- reach into the archive to extract a time series
IF OBJECT_ID('tempdb..#relJumpRec') IS NOT NULL DROP TABLE #relJumpRec;
select
e.*
into #relJumpRec
from ebs_ARCHIVE.zevent.ownerEvents e
inner join edvald_research.umd.crpSampSelection s on e.ownerID = s.employeeCharID -- match on relevant corps
where (e.eventTypeID = 6 or e.eventTypeID = 130) and e.eventDate between '2017-04-01' and '2017-04-07'

with temp as (
	select
	ch.corporationID,
	ch.userID,
	ch.customerID,
	ch.characterID,
	ch.historyDate
	from ebs_FACTORY.eve.characterHistory ch 
	where ch.historyDate >= '2015-01-01' 
)
select 
cast(e.eventDate as date) as dt,
ch.corporationID,
ch.userID,
ch.customerID,
ch.characterID,
e.eventDate,
e.eventTypeID,
e.referenceID,
e.eventID
into #jumprec
from ebs_ARCHIVE.zevent.ownerEvents e 
inner join temp ch on (e.ownerID = ch.characterID and cast(e.eventDate as date) = ch.historyDate)
where (e.eventTypeID = 6 or e.eventTypeID = 130) and e.eventDate >= '2015-01-01' 




select top 10* from ebs_FACTORY.eve.characterHistory

select top 10* from ebs_ARCHIVE.zevent.ownerEvents