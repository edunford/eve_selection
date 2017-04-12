declare @counterDate date = '2017-04-11'
CREATE TABLE #events (ownerID bigint, fromCharID bigint, corporationID bigint, status_ int)

INSERT INTO #events (ownerID, fromCharID, corporationID, status_)
EXEC hadoop.hive.query '
SELECT ownerID, fromCharID, corporationID, status_
  FROM eventLogs_all a
LATERAL VIEW json_tuple(a.value, "eventName", "ownerID", "fromCharID", "corporationID", "status") b AS eventName, ownerID, fromCharID, corporationID, status_
 WHERE dt = @date1 AND eventName = "corporation::InsertApplication"',@counterDate

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

