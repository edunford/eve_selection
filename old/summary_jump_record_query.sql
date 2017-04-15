
select top 10* from ebs_FACTORY.eve.characterHistory 

select top 10
historyDate,
cast(month(historyDate) as varchar(2)) as month,
cast(year(historyDate) as varchar(4)) as year
from ebs_FACTORY.eve.characterHistory 




select top 10
sum(travelWarpsLowSec) as lowSecWarps,
sum(travelWarpsHighSec) as highSecWarps,
sum(travelWarpsNullSec) as nullSecWarps,
sum(travelWarpsWormhole) as wormholeWarps,
sum(travelWarpsTotal) as totalWarps,
sum(travelJumpsStargateHighSec) as highsecJumps,
sum(travelJumpsStargateLowSec) as lowsecJumps,
sum(travelJumpsStargateNullSec) as nullsecJumps,
sum(travelJumpsWormhole) as wormholeJumps,
sum(travelJumpsStargateTotal) totalJumps
from ebs_FACTORY.eve.characterHistory 
where characterID = 94381495
group by characterID

select min(historyDate) from ebs_FACTORY.eve.characterHistory


select
max(corporationID) as corporationID,
max(cast(month(historyDate) as varchar(2))) as month,
max(cast(year(historyDate) as varchar(4))) as year,
sum(travelJumpsStargateHighSec) as highsecJumps,
sum(travelJumpsStargateLowSec) as lowsecJumps,
sum(travelJumpsStargateNullSec) as nullsecJumps,
sum(travelJumpsWormhole) as wormholeJumps,
(sum(travelJumpsWormhole)+0.0)/sum(travelJumpsStargateTotal)  as prop,
sum(travelJumpsStargateTotal) totalJumps
from ebs_FACTORY.eve.characterHistory 
where historyDate >= '2017-03-01' and corporationID in (98389204,98475953,98478490)
group by month(historyDate)+'-'+year(historyDate)+'-'+corporationID
order by month


---- generage proportions
select
max(corporationID) as corporationID,
max(cast(month(historyDate) as varchar(2))) as month,
max(cast(year(historyDate) as varchar(4))) as year,
(sum(travelJumpsStargateHighSec)+0.0)/(sum(travelJumpsStargateTotal) + sum(travelJumpsWormhole))  as propHighSec,
(sum(travelJumpsStargateLowSec)+0.0)/(sum(travelJumpsStargateTotal) + sum(travelJumpsWormhole))  as propLowSec,
(sum(travelJumpsStargateNullSec)+0.0)/(sum(travelJumpsStargateTotal) + sum(travelJumpsWormhole)) as propNullSec,
(sum(travelJumpsWormhole)+0.0)/(sum(travelJumpsStargateTotal) + sum(travelJumpsWormhole))  as propWormhole,
sum(travelJumpsStargateHighSec) as highsecJumps,
sum(travelJumpsStargateLowSec) as lowsecJumps,
sum(travelJumpsStargateNullSec) as nullsecJumps,
sum(travelJumpsWormhole) as wormholeJumps,
sum(travelJumpsStargateTotal) + sum(travelJumpsWormhole) as totalJumps
from ebs_FACTORY.eve.characterHistory 
where historyDate >= '2017-03-01' and corporationID in (98389204,98475953,98478490)
group by month(historyDate)+'-'+year(historyDate)+'-'+corporationID
order by month



-- aggregate by month and then take the monthly average 
with jumpRec as (
	select
	max(corporationID) as corporationID,
	max(cast(month(historyDate) as varchar(2))) as month,
	max(cast(year(historyDate) as varchar(4))) as year,
	(sum(travelJumpsStargateHighSec)+0.0)/(sum(travelJumpsStargateTotal) + sum(travelJumpsWormhole))  as propHighSec,
	(sum(travelJumpsStargateLowSec)+0.0)/(sum(travelJumpsStargateTotal) + sum(travelJumpsWormhole))  as propLowSec,
	(sum(travelJumpsStargateNullSec)+0.0)/(sum(travelJumpsStargateTotal) + sum(travelJumpsWormhole)) as propNullSec,
	(sum(travelJumpsWormhole)+0.0)/(sum(travelJumpsStargateTotal) + sum(travelJumpsWormhole))  as propWormhole,
	(sum(travelJumpsStargateTotal) + sum(travelJumpsWormhole)) as totalJumps
	from ebs_FACTORY.eve.characterHistory 
	where historyDate >= '2017-04-01' --and corporationID in (98389204,98475953,98478490)
	group by month(historyDate)+'-'+year(historyDate)+'-'+corporationID
) select 
max(corporationID) as corporationID,
AVG(jr.propHighSec) as propHighSec,
AVG(jr.propLowSec) as propLowSec,
AVG(jr.propNullSec) as propNullSec,
AVG(jr.propWormhole) as propWormhole,
AVG(jr.totalJumps) as aveMonthlyTotalJumps
from jumpRec jr
group by corporationID


select
travelJumpsStargateHighSec,
travelJumpsStargateNullSec,
travelJumpsStargateLowSec,
travelJumpsWormhole
from ebs_FACTORY.eve.characterHistory where corporationID = 98406800 and historyDate >= '2017-04-01'

select count(*) from ebs_FACTORY.eve.characterHistory where historyDate >= '2015-01-01'
select count(distinct corporationID) as distinctCorpsinSet from ebs_FACTORY.eve.characterHistory where historyDate >= '2015-01-01'