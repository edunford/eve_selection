
IF OBJECT_ID('tempdb..#events') IS NOT NULL DROP TABLE #events
declare @counterDate1 date = '2017-04-11'
declare @counterDate2 date = '2017-04-12'
CREATE TABLE #events (ownerID bigint, fromCharID bigint, corporationID bigint, status_ int)

INSERT INTO #events (ownerID, fromCharID, corporationID, status_)
EXEC hadoop.hive.query '
SELECT ownerID, fromCharID, corporationID, status_
  FROM eventLogs_all a
LATERAL VIEW json_tuple(a.value, "eventName", "ownerID", "fromCharID", "corporationID", "status") b AS eventName, ownerID, fromCharID, corporationID, status_
 WHERE dt between @date1 AND @date2 AND eventName = "corporation::InsertApplication"',@counterDate1, @counterDate2

go



declare @counterDate date = '2017-04-11'

 select iif(e.ownerID = e.fromCharID, 'Applied', 'Invited') as applicationType,
		e.*,
		c.characterName as senderCharacterName, c.corporationName as senderCharacterCorp,
		crp.isRecruiting,
		own.characterName as ownerName,
		own.corporationName as ownerCorporation,
		owncorp_prior.corporationName as ownerCorporationPrior,
		owncorp_prior.corporationType as ownerCorporationPriorType
 from #events e
	inner join ebs_WAREHOUSE.owner.dimCharacterVx c on c.characterID = e.fromCharID
	inner join ebs_WAREHOUSE.owner.dimCharacterVx own on own.characterID = e.ownerID
	inner join ebs_WAREHOUSE.owner.dimCorporationVx crp on crp.corporationID = e.corporationID
	left join ebs_WAREHOUSE.owner.dimCharacterSCD charscd on charscd.characterID = e.ownerID and dateadd(day,-1, @counterDate) between charscd.dateFrom and charscd.dateTo
		left join ebs_WAREHOUSE.owner.dimCorporationVx owncorp_prior on owncorp_prior.corporationID = charscd.corporationID


select count(*) from #events where status_ = 0



-- my own take on this 
select * from hadoop.samples.eventLogs_corpRecruitment__ApplyToJoin
select * from hadoop.samples.eventLogs_corporation__InsertApplication
select * from hadoop.samples.eventLogs_corporation__UpdateApplicationOffer


IF OBJECT_ID('tempdb..#events2') IS NOT NULL DROP TABLE #events2
CREATE TABLE #events2 (ownerID bigint, eventDateTime date, fromCharID bigint, corporationID bigint, status_ int)


INSERT INTO #events2 (eventDateTime, ownerID, fromCharID, corporationID, status_)
declare @counterDate date = '2017-04-01';
EXEC hadoop.hive.query '
SELECT eventDateTime, ownerID, fromCharID, corporationID, status_
  FROM eventLogs_all a
LATERAL VIEW json_tuple(a.value, "eventDateTime" ,"eventName", "ownerID", "fromCharID", "corporationID", "status") b AS eventDateTime, eventName, ownerID, fromCharID, corporationID, status_
 WHERE dt = @date1 AND eventName = "corporation::InsertApplication"',@counterDate


 select* from #events2