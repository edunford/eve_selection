-- employee ENTER/EXIT Logs
	-- generate dyadic data for each employee within the rel. period 
	-- where the data is organized as: charID,exitCorpID,enterCorpID
	-- for each character we then have a record of when they left and entered a corp
	-- which I can represent as a flow (migration) from group to group.


SELECT 
startDate as eventDate,
characterID,
LAG(corporationID, 1,0) OVER (PARTITION BY characterID ORDER BY startDate) as exitCorp,
corporationID as enterCorp,
LAG(corporationName, 1,0) OVER (PARTITION BY characterID ORDER BY startDate) as exitCorpName,
corporationName as enterCorpName
into edvald_research.umd.corpEmployeeExitLogs
from ebs_RESEARCH.dbo.crpEmploymentRecordsEx 



select top 100* from edvald_research.umd.corpEmployeeExitLogs order by characterID, eventDate


-- examine by character
select top 100* from edvald_research.umd.corpEmployeeExitLogs 
where characterID in (96019134, 95265675, 95482504)
order by characterID, eventDate

-- examine by corporation (exit rate)
select top 100* from edvald_research.umd.corpEmployeeExitLogs 
where exitCorp = 98382684 or enterCorp = 98382684
order by eventDate
