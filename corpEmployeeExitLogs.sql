

select * from hadoop.samples.eventLogs_corporation__UpdateCorporation


--- need to piece together corporation exit records...

-- generate dyadic data for each employee within the rel. period 
-- where the data is organized as: charID,exitCorpID,enterCorpID
-- for each character we then have a record of when they left and entered a corp
-- which I can represent as a flow (migration) from group to group.

select top 100* from ebs_RESEARCH.dbo.crpEmploymentRecordsEx 

select top 100* from edvald_research.umd.crpSampSelection


SELECT 
startDate as eventDate,
characterID,
LAG(corporationID, 1,0) OVER (PARTITION BY characterID ORDER BY startDate) as exitCorp,
corporationID as enterCorp,
LAG(corporationName, 1,0) OVER (PARTITION BY characterID ORDER BY startDate) as exitCorpName,
corporationName as enterCorpName
into edvald_research.umd.corpEmployeeExitLogs
from ebs_RESEARCH.dbo.crpEmploymentRecordsEx 





---- development
select *,
	FORMAT(startDate,'yyyy-MM-dd') as enter,
	format(dateadd(day,-1, startDate),'yyyy-MM-dd') as priorDate
	into #sss
	from ebs_RESEARCH.dbo.crpEmploymentRecordsEx 
	where characterID in (96019134, 95265675, 95482504)
	order by enter

select * from #ttt order by characterID, eventDate
select * from #sss order by characterID, startDate



SELECT 
startDate as eventDate,
characterID,
LAG(corporationID, 1,0) OVER (ORDER BY startDate) AS exitCorp,
corporationID as enterCorp,
LAG(corporationName, 1,0) OVER (ORDER BY startDate) AS exitCorpName,
corporationName as enterCorpName
from ebs_RESEARCH.dbo.crpEmploymentRecordsEx 
where characterID = 96019134
order by startDate


with tmp as (
	select 
	characterID,
	corporationID,
	startDate as granularDate,
	FORMAT(startDate,'yyyy-MM-dd') as eventDate,
	format(dateadd(day,-1, startDate),'yyyy-MM-dd') as priorDate
	from ebs_RESEARCH.dbo.crpEmploymentRecordsEx 
	where characterID = 96019134
)
select 
t.granularDate,
t.eventDate,
t.characterID,
ch.userID,
ch.customerID,
ch.corporationID as exitCorpID,
t.corporationID as enterCorpID
into #tmp1
from ebs_FACTORY.eve.characterHistory ch
inner join tmp t on (ch.characterID = t.characterID and ch.historyDate = t.priorDate)

drop table #tmp1

select * from #tmp1 order by eventDate

select top 10* from ebs_WAREHOUSE.owner.dimCharacterSCD
select top 10* from ebs_FACTORY.eve.characterHistory

select min(historyDate) as min,max(historyDate) as max from ebs_FACTORY.eve.characterHistory 




