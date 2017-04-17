# Selection and Recruitment: Process notes

### Extraction strategy

Need to piece together recruitment records by first assessing when an individual player joined a corporation, and back tracking his/her activity prior to joining. This will offer insight into potential recruitment signatures in the data, which can then be standardized.


Following code renders important information about messages passed to recruits. There is sender and receiver information here, which one could easily clean to limit within-corp communication.

    select top 100 *
    FROM ebs_RESEARCH.mail.messages m
    WHERE title LIKE '%recruit%'
    order BY m.messageID desc

**IDEA**: check if there is a log of API queries. It would appear that corporations run background checks on individuals.

**IDEA**: scan recruitment adds to build a dictionary re: language relevant to recruitment.

**IDEA**: <s>implement a necessary scope condition whereby you only examine NULL sec organizations.</s> The question is where a _relevant subset exists_. There is an argument that high sec organizations are lacking the same kinds of demands for coordination. Thus, the focus needs to be placed on low and null sec corps. Thus, a sample of corporations needs to be generated that (a) contains other human players, (b) operating in low/null sec, (c) has over 10 members _(or some other threshold of number of players)_ who are active, defining "active" as those who log on within 30 days of each other. [Note that the activity information isn't retained as a time series, so it's difficult to ID the number of times an individuals logs on (outside of the character history tables)]

The above extraction strategy will provide corporations that have members who actually play the game. To understand how individuals work in groups, there has to be some form of initial investment in the corporation.

From here, I need to gather information about where corporations distribute their time by piecing together the jump logs.

Note that the **jump summaries** (i.e. which security zone a corp spends the majority of its time) appears off. There are corps in the jump log who report 0 activity who are clearly in the jump long (which means they're jumping and thus pointing to an error in the log).

## Recruitment applications

- Records re: invitations and applications appear to extend back to Dec 9, 2014 -- so there are limitations re: which part of the time series corp data is extracted from.

## Jump logs

Extracting from the hadoop jump log is expensive and draws a lot of superfluous entries. Just for the week of April 1 - April 7, 2017 there was approximately 8.5 million jump records. However, after removing all non-relevant corporations (npc/dust/less than 5 human players), that number reduces to 2.2 million -- which would only further reduce if one were to use a sample rather than the population. A key question is: can we subset the records _while_ drawing them from the hadoop?


----------------------------------------------------------------

## Insights

Kjartan sent hyper useful code re: constructing and indexing temporary tables.

First, to **construct** a temp table, use the following:

    IF OBJECT_ID('tempdb..#temp') IS NOT NULL DROP TABLE #temp
    SELECT TOP 10 characterID, connectDate
    INTO #temp
    FROM local_ANALYTICS.kjartanh.characterLogonDays

Second, to **index** that temp table, use the following:

    CREATE NONCLUSTERED INDEX war_IX
    ON #wars (defenderID)
    INCLUDE (dayDeclared);

where in the above chunk "war_IX" is the temp table being indexed.

### Meeting with Eddi

Customerid IS VOLATILE  use user email or userID as a unique ID

use `isPrimary` on player account email to get rid of alt accounts which will be `ebs_WAREHOUSE.customer.dimUser`

http://evemetrics/Report?counterID=1411 is a fantastic internal site with time series and SQL information query guidance for the entire EVE data base. Eddi uses this sounce primarily for his data exploration of new sources. Note that Eddi also built an R package that streamlines much of the SQL set up in R for extracting from the EVE database.

We installed `devart`, which is an SQL assistant that helps code complete when using SQL. It plugs and plays with the SQL clients.

Eddi suggested reading (varianceexplained)[http://varianceexplained.org/]. Useful uses of the `PURR` package.

----------------------------------------------------------------

## Auxiliary notes

Pandemic Horde == `98388312` (this is a major noobie corp with high membership)

Useful [stack exchange article](http://stackoverflow.com/questions/5706437/whats-the-difference-between-inner-join-left-join-right-join-and-full-join) on joins in SQL.

The **event logs** are moving. Tracking the date range of logs today (04-16-2017), the logs ranged from a **_min: 2016-12-29 to max: 2017-04-16_**). This generates major issues for how **coordination networks** are constructed. As one needs a clear jump record of all corp members to construct spatio-temporal adjacency matrices.  

Check out the external [recruitment process website](https://recruit.karmafleet.org/) for **karmafleet**
