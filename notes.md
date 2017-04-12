# Selection and Recruitment: Process notes

### Extraction strategy

Need to piece together recruitment records by first assessing when an individual player joined a corporation, and back tracking his/her activity prior to joining. This will offer insight into potential recruitment signatures in the data, which can then be standardized.


Following code renders important information about messages passed to recruits. There is sender and receiver information here, which one could easily clean to limit within-corp communication.

    > select top 100 *
    FROM ebs_RESEARCH.mail.messages m
    WHERE title LIKE '%recruit%'
    order BY m.messageID desc

**IDEA**: check if there is a log of API queries. It would appear that corporations run background checks on individuals.

**IDEA**: scan recruitment adds to build a dictionary re: language relevant to recruitment.

**IDEA**: implement a necessary scope condition whereby you only examine NULL sec organizations.


## Insights

Kjartan sent hyper useful code re: constructing and indexing temporary tables.

First, to **construct** a temp table, use the following:

  > IF OBJECT_ID('tempdb..#temp') IS NOT NULL DROP TABLE #temp
  SELECT TOP 10 characterID, connectDate
  INTO #temp
  FROM local_ANALYTICS.kjartanh.characterLogonDays

Second, to **index** that temp table, use the following:

  > CREATE NONCLUSTERED INDEX war_IX
    ON #wars (defenderID)
    INCLUDE (dayDeclared);

where in the above chunk "war_IX" is the temp table being indexed.
