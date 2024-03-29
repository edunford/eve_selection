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
		IF OBJECT_ID('tempdb..#sampleWarp') IS NOT NULL DROP TABLE #sampleWarp;
		with tmpwarp as(
			select *
			from #warpto2  
			where corporationID = toCorpID
		) select w.*
		into #sampleWarp
		from tmpwarp w
		inner join #samp s on s.corporationID = w.corporationID

-- map on unique identifying information to partial out only interactions between unique players
		IF OBJECT_ID('tempdb..#sampleWarp2') IS NOT NULL DROP TABLE #sampleWarp2;
		with selection as ( -- only draw from subsample
			select 
			ss.historyDate as eventDate,
			ss.corporationID,
			ss.characterID,
			ss.customerID
			from ebs_FACTORY.eve.characterHistory ss
			inner join #samp s on s.corporationID = ss.corporationID
		) select 
		sw.*,
		sel.customerID,
		sel2.customerID as toCustomerID
		into #sampleWarp2
		from #sampleWarp sw
		left join selection sel on (sel.eventDate = sw.eventDate and sel.corporationID = sw.corporationID and sel.characterID = sw.characterID)
		left join selection sel2 on  (sel2.eventDate = sw.eventDate and sel2.corporationID = sw.toCorpID and sel2.characterID = sw.toCharID)
		

		-- again there is a slight expansion... need to investigate why (but for now, moving forward)
		select distinct count(*) from #sampleWarp2
		select distinct count(*) from #sampleWarp

				-- large portion of interactions appear to be between the same customer
				select count(*) 
				from #sampleWarp2
				where customerID = toCustomerID

		-- drop the same player interactions
		IF OBJECT_ID('tempdb..#sampleWarp3') IS NOT NULL DROP TABLE #sampleWarp3;
		select *
		into #sampleWarp3
		from #sampleWarp2
		where customerID != toCustomerID



-- draw sample entries from the Logged on/off logs
		IF OBJECT_ID('tempdb..#samplogon') IS NOT NULL DROP TABLE #samplogon;
		select l.* 
		into #samplogon
		from edvald_research.umd.charloggedOn l
		inner join #samp s on l.corporationID = s.corporationID

		-- map on customerID
		IF OBJECT_ID('tempdb..#samplogon2') IS NOT NULL DROP TABLE #samplogon2;
		with tmp as ( 
			select 
			ss.historyDate as eventDate,
			ss.corporationID,
			ss.characterID,
			ss.customerID
			from ebs_FACTORY.eve.characterHistory ss
			inner join #samp s on s.corporationID = ss.corporationID
		) select sw.*,
		sel.customerID
		into #samplogon2
		from #samplogon sw
		left join tmp sel on (sel.eventDate = sw.eventDate and sel.corporationID = sw.corporationID and sel.characterID = sw.characterID)

	
-- generated condensed network measures for each corporation day.
-- (1) who is online from the corporation (N)
-- (2) who is coordinating, i.e. "warping to" another player (E)
-- (3) network density measure: actual connections (E) over potential connections (N*(N-1))
-- NOTE: the assumption is that the connections are directed. Thus no need to divide PC by 2 (i.e. (N*N-1)/2)

		-- generate online counts
		IF OBJECT_ID('tempdb..#dailyOnlineCounts') IS NOT NULL DROP TABLE #dailyOnlineCounts;
		with N as (
			select DISTINCT
			eventDate,
			corporationID,
			customerID
			from #samplogon2
		) select 
		max(eventDate) as eventDate,
		max(corporationID) as corporationID,
		count(*) as N_online
		into #dailyOnlineCounts
		from N 
		group by corporationID, eventDate

		-- generate edge counts
		IF OBJECT_ID('tempdb..#dailyEdgeCounts') IS NOT NULL DROP TABLE #dailyEdgeCounts;
		with E as(
			select DISTINCT
			eventDate,
			corporationID,
			customerID,
			toCustomerId
			from #sampleWarp3
		) select 
		max(eventDate) as eventDate,
		max(corporationID) as corporationID,
		count(*) as N_edges
		into #dailyEdgeCounts
		from E
		group by eventDate,corporationID

		-- combine and generate density metric
		-- right join because we want to know when corp members were online but there were no connections
		IF OBJECT_ID('tempdb..#corpDensity') IS NOT NULL DROP TABLE #corpDensity;
		select 
		n.eventDate,
		n.corporationID,
		n.N_online,
		e.N_edges,
		round(cast((e.N_edges) as decimal)/((cast((n.N_online)*(n.N_online-1) as decimal))),4) as density
		into #corpDensity
		from #dailyEdgeCounts e
		right join #dailyOnlineCounts n on (e.corporationID = n.corporationID and e.eventDate = n.eventDate)


		-- drop instances when only one character from the corp was online.
		IF OBJECT_ID('tempdb..#corpDensity2') IS NOT NULL DROP TABLE #corpDensity2;
		select 
		eventDate,
		corporationID,
		N_online,
		iif(N_edges is null,0,N_edges) as N_edges,
		iif(density is null,0,density) as density
		into #corpDensity2
		from #corpDensity
		where N_online > 1
		order by eventDate,corporationID

		
-- build aggregate selection logs

			IF OBJECT_ID('tempdb..#selection') IS NOT NULL DROP TABLE #selection;
			select 
			app.eventDate,
			app.corporationID,
			app.receiverID as characterID,
			iif(status=8,1,0) as invited,
			iif(status=0,1,0) as applied
			into #selection
			from edvald_research.umd.corporationApps app
			inner join #samp s on s.corporationID = app.corporationID 


			select * from edvald_research.umd.corporationApps
			where receiverID = 1761102685

-- generate logs needed for aggregate exit and size by corp

			IF OBJECT_ID('tempdb..#size') IS NOT NULL DROP TABLE #size;
			select e.*  
			into #size
			from edvald_research.umd.corpEmployeeExitLogs e
			inner join #samp s on (e.enterCorp = s.corporationID or e.exitCorp = s.corporationID)
			


-- retain logs for import into R

select *
into edvald_research.umd.samp1_networkDensity
from #corpDensity2

select * 
into edvald_research.umd.samp1_selection
from #selection

-- size
select * 
into edvald_research.umd.samp1_employeeFlows
from #size

-- sample information

select S.*
into edvald_research.umd.samp1_sampleDescr
from edvald_research.umd.crpSampSelection S
inner join #samp ss on S.corporationID = ss.corporationID



