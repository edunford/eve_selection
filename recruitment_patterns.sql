-- Corporation Break Down

select top 10* from edvald_research.umd.corporationApps


-- breakdown of selection inst. by group
drop table #breakdown
select
max(corporationID) as corporationID, 
sum(iif(status=0,1,0)) as applied,
sum(iif(status=8,1,0)) as invited,
count(receiverID) as  total
into #breakdown
from edvald_research.umd.corporationApps
group by corporationID
order by count(receiverID) DESC


-- "selective groups"
-- which groups have more invitations than applied? (limited to groups with 10 or more entries)
		IF OBJECT_ID('tempdb..#selective') IS NOT NULL DROP TABLE #selective;
		with tmp as (
		select *
		from #breakdown 
		where invited > applied and total >= 10
		) select 
		t.invited,
		t.applied,
		t.total as total_applicants,
		c.*
		into #selective
		from tmp t
		inner join edvald_research.umd.crpSampSelection c on t.corporationID = c.corporationID
		order by t.invited



		select top 10* from #selective order by distinctUsers desc

		-- assessment: who are the top "inviters" and do they have a vetting portal online?
		select distinct
		corporationID,
		corporationName,
		distinctUsers,
		invited, 
		applied,
		total_applicants
		from #selective
		order by distinctUsers desc

		


