-- comparing the hadoop application record to the recorded one

-- HADOOP TABLE
		IF OBJECT_ID('tempdb..#apps') IS NOT NULL DROP TABLE #apps
		CREATE TABLE #apps (eventDate date, corporationID bigint, receiverID bigint, senderID bigint, status_ int)
		declare @counterDate1 date = '2017-04-01';
		declare @counterDate2 date = '2017-04-07';
		INSERT INTO #apps (eventDate, corporationid, receiverid, senderid, status_)
		EXEC hadoop.hive.query '
		SELECT date as eventDate, corporationID, receiverID, senderID, status_
		  FROM eventLogs_all a
		LATERAL VIEW json_tuple(a.value, "eventName", "dateTime", "corporationID", "ownerID", "fromCharID", "status") b AS eventName, date, corporationID, receiverID, senderID, status_
		 WHERE dt between @date1 AND @date2 AND eventName = "corporation::InsertApplication"',@counterDate1, @counterDate2

		
	-- range
		select min(eventDate) as minDate, max(eventDate) as maxDate from #apps

		
-- RESEARCH TABLE

		select top 10* from ebs_RESEARCH.corporation.applications

	-- range 
		select min(applicationDateTime) as minDate, max(applicationDateTime) as maxDate from ebs_RESEARCH.corporation.applications 


-- COMPARE

	-- breakdown by day at the beginning of april
		
		-- Hadoop
		-- breakdown by day at the beginning of april
			select 
			max(cast(day(eventDate) as varchar(2))) as day,
			count(*) as N
			from #apps
			group by cast(day(eventDate) as varchar(2))
			order by cast(day(eventDate) as varchar(2))

		-- Rtab	
			select 
			max(cast(day(applicationDateTime) as varchar(3))) as day,
			count(*) as N
			from ebs_RESEARCH.corporation.applications
			where applicationDateTime between '2017-04-01' and '2017-04-08'
			group by cast(day(applicationDateTime) as varchar(3))
			order by cast(day(applicationDateTime) as varchar(3))


			-- minor discreps in counts which are likely due to specific transitions in dates
			-- evidence that they are relatively the same record

		
	
		select count(*) from ebs_RESEARCH.corporation.applications
		where applicationDateTime between '2017-04-01' and '2017-04-08' -- N = 22758

		select count(*) from #apps -- N = 22759


	-- gather records together and compare
	select 
	r.corporationID,
	r.applicationDateTime,
	a.eventDate,
	r.characterID,
	a.receiverID,
	a.senderID,
	r.status as tb_status,
	a.status_ as hdp_status
	from ebs_RESEARCH.corporation.applications r 
	full outer join #apps a on (r.corporationID = a.corporationID and r.characterID = a.receiverID)
	where r.applicationDateTime between '2017-04-01' and '2017-04-08'


	-- is there a pattern in the status?
	select distinct
	r.status as tb_status,
	a.status_ as hdp_status
	from ebs_RESEARCH.corporation.applications r 
	full outer join #apps a on (r.corporationID = a.corporationID and r.characterID = a.receiverID)
	where r.applicationDateTime between '2017-04-01' and '2017-04-08'

	-- all status categories (except for 6), occur in both invited and the applications w/r/t the hadoop table.
	-- no logic can be backed out from bringing these tables together. 









	