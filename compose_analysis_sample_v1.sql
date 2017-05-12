-- Constructing the master tmp tables to be imported into R for processing

-- GOALS: attached corpID to warp logs, generate corp sample (N=500), 
-- subset warp logs to sample only looking at membership interactions,
-- subset entry exit-logs for sample

-- building on the large warpto records. I need to ID: 
		-- unique players (for each character ID)
		-- and their corporation
		-- then just look at the interaction between unique players.


-- attached corporation ID to warp logs
IF OBJECT_ID('tempdb..#warpto2') IS NOT NULL DROP TABLE #warpto2;
select 
w.eventDate,
h.corporationID,
w.characterID,
h2.corporationID as toCorpID,
w.toCharID,
w.minDist
into #warpto2
from edvald_research.umd.warptologs w
left join ebs_FACTORY.eve.characterHistory h on (w.characterID = h.characterID and w.eventDate = h.historyDate)
left join ebs_FACTORY.eve.characterHistory h2 on (w.toCharID = h2.characterID and  w.eventDate = h2.historyDate)


-- there is an expansion in the N when merging (needs to be addressed)**
select count(*) from #warpto2
select count(*) from edvald_research.umd.warptologs


-- generate a RANDOM SAMPLE from the population sample of 500 corps.
IF OBJECT_ID('tempdb..#samp') IS NOT NULL DROP TABLE #samp;
with ss as (
select distinct corporationID 
from edvald_research.umd.crpSampSelection
where corpCreateDate <= '2017-04-15'
) select top 500 *
into #samp 
from ss
ORDER BY RAND()


-- draw entries from the interaction logs where 
-- (a) corp members are interacting (warping to) members from the same corp
-- (b) corporations are contained within the relevant sample
with tmpwarp as(
	select *
	from #warpto2  
	where corporationID = toCorpID
) select w.*
into #sampleWarp
from tmpwarp w
inner join #samp s on s.corporationID = w.corporationID


select top 100* from #sampleWarp
select count(*) from #sampleWarp


 




