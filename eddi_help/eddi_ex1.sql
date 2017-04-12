

with characterSample as
(
	select top 100 characterID
	from ebs_WAREHOUSE.customer.dimUser u
		inner join ebs_WAREHOUSE.owner.dimCharacter c on c.userID = u.userID
	where u.isPrimaryForEmail = 1
	  and u.isActive = 1
	  and u.logonMinutes > 0
	  and c.isDeleted = 0
	  and c.isUsersPrimaryCharacter = 1
)
select * 
from ebs_FACTORY.eve.characterHistory c
	inner join characterSample cc on cc.characterID = c.characterID

