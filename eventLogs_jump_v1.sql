-- backing out jump records from the event logs

-- examine the immediate records to gather a picture of the current.
select top 10* from ebs_RESEARCH.zevent.ownerEventsEx where eventTypeID = 130


-- reach into the archive to extract a time series
IF OBJECT_ID('tempdb..#relJumpRec') IS NOT NULL DROP TABLE #relJumpRec;
select
e.*
into #relJumpRec
from ebs_ARCHIVE.zevent.ownerEvents e
inner join edvald_research.umd.crpSampSelection s on e.ownerID = s.employeeCharID -- match on relevant corps
where (e.eventTypeID = 6 or e.eventTypeID = 130) and e.eventDate between '2017-04-01' and '2017-04-07'