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

- We have the capacity to write to permanent tables now using `edvald_research.umd` --- meaning we can back track and save the application records (including invite and application information from the hadoop). This will allow for a precise time series of this information.

## Jump logs

- Extracting from the hadoop jump log is expensive and draws a lot of superfluous entries. Just for the week of April 1 - April 7, 2017 there was approximately 8.5 million jump records. However, after removing all non-relevant corporations (npc/dust/less than 5 human players), that number reduces to 2.2 million -- which would only further reduce if one were to use a sample rather than the population. A key question is: can we subset the records _while_ drawing them from the hadoop?

- **Note that the event logs are archived in** `ebs_ARCHIVE`. These logs retain a thorough time series of all player activity in the game.  

- Daily hashes can still be too big for larger corporations. Need to further parse the interaction networks into _half_ or _quarter_ days.

## Fleets "Warp To"

- K. noted that jumps (especially jumps aggregated to the day) likely aren't capturing cohesion. Think of it like this: everyone might go to the store each day (which would be recorded as a tie) but it doesn't mean that they are "together" or that they know each other. Rather, K. suggestion using the "warp to" feature in a fleet, where a member of a fleet can warp to a specific player in that fleet. K. noted that in his corp it's a requirement to join the (only) fleet whenever you log on. That way it's easier to help the team when in need. A "warp to" would always be a gesture of coordination.

- Also, fleet and squad leaders have the capacity to warp the entire fleet, which means that you can recover group wars.

- These records exist and appear to do the trick. They are located in the hadoop, so they'll require a map-reduction.

      select * from hadoop.samples.eventLogs_park__Warp_Char


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

- `Customerid` IS VOLATILE  use **user email** or **userID** as a unique ID

- Use `isPrimary` on player account email to get rid of alt accounts which will be `ebs_WAREHOUSE.customer.dimUser`

- http://evemetrics/Report?counterID=1411 is a fantastic internal site with time series and SQL information query guidance for the entire EVE data base. Eddi uses this sounce primarily for his data exploration of new sources. Note that Eddi also built an R package that streamlines much of the SQL set up in R for extracting from the EVE database.

- We installed `devart`, which is an SQL assistant that helps code complete when using SQL. It plugs and plays with the SQL clients.

- Eddi suggested reading (varianceexplained)[http://varianceexplained.org/]. Useful uses of the `PURR` package.

### Map Reduce (for querying Hadoop)

Eddi walked through using map reduce to grab larger jobs from the cluster. Very effective. Here is the command prompt that he ran after we walked we set up the mapper function

      python doob.py --mapper corpApplications.py --date 2017.04.01-2017.04.18 --output corpApplications

with `corpApplications.py` taking the following form:

      import collections
      import doobutil
      from doobutil import PrintSimpleKeyVals
      def mapper():
          for e in doobutil.ReadInputEvent(quickFilter="corporation::InsertApplication"):
               print("%s\t%s\t%s\t%s\t%s" % (e.dt[:10], e.corpID, e.charID, e.fromCharID, e.status))
      mapper()

The working directory is the `/c/hadoop` folder.

Finally, the following code can be used to parse and load the files into a SQL table.

        # Under: F:\depot\eventLog\RELEASE\hadoop\
        # python doob.py --mapper regionImportExportMapper.py --reducer countReducer.py --output importsExports --date 2016.03.01-2016.03.31 # run the query
        # cd importsExports_edvald
        #
        # sed 's/\t/,/g' importsExports_edvald.txt > importsExports_edvald.csv
        # bcp tmp.importsExports in importsExports_edvald.csv -S researchdb -d edvald_research -T -c -t

So for me, this would look like

        cd ~/hadoop/RELASE/hadoop/

        python doob.py --mapper corpApplications.py --date 2017.04.01-2017.04.18 --output corpApplications

        sed 's/\t/,/g' corpApplications_se.david.txt > ~/Documents/ETD/selection/data/importsExports/cropApplications.csv


----------------------------------------------------------------

## Auxiliary notes

- Pandemic Horde == `98388312` (this is a major noobie corp with high membership)

- Useful [stack exchange article](http://stackoverflow.com/questions/5706437/whats-the-difference-between-inner-join-left-join-right-join-and-full-join) on joins in SQL.

- The **event logs** are moving. Tracking the date range of logs today (04-16-2017), the logs ranged from a **_min: 2016-12-29 to max: 2017-04-16_**). This generates major issues for how **coordination networks** are constructed. As one needs a clear jump record of all corp members to construct spatio-temporal adjacency matrices.  

- Check out the external [recruitment process website](https://recruit.karmafleet.org/) for **karmafleet**

- Karjtan's allianceID is (`99003615`)  (see if you can't back out his network)

- Great stackoverflow post about the [different community detection algorithms](http://stackoverflow.com/questions/9471906/what-are-the-differences-between-community-detection-algorithms-in-igraph) out there


----------------------------------------------------------------------

## Understanding the ITEM ID schema

Kjartan just sent this along. It isolates the relevant logic behind CCP's item ID schema.

      All items with itemID < 90.000.000 are items created by CCP and are so called system items.  System items have certain intervals of itemIDs and it goes like this...
      {{{
                    0 -        10.000   System items (including junkyards and other special purpose items
              500.000 -     1.000.000   Factions
            1.000.000 -     2.000.000   NPC corporations
            3.000.000 -     4.000.000   NPC characters (agents and NPC corporation CEO's)
            9.000.000 -    10.000.000   Universes
           10.000.000 -    11.000.000   NEW-EDEN Regions
           11.000.000 -    12.000.000   Wormhole Regions
           20.000.000 -    21.000.000   NEW-EDEN Constellations
           21.000.000 -    22.000.000   Wormhole Constellations
           30.000.000 -    31.000.000   NEW-EDEN Solar systems
           31.000.000 -    32.000.000   Wormhole Solar systems
           40.000.000 -    50.000.000   Celestials (suns, planets, moons, asteroid belts)
           50.000.000 -    60.000.000   Stargates
           60.000.000 -    61.000.000   Stations created by CCP
           61.000.000 -    64.000.000   Stations created from outposts
           68.000.000 -    69.000.000   Station folders for stations created by CCP
           69.000.000 -    70.000.000   Station folders for stations created from outposts
           70.000.000 -    80.000.000   Asteroids
           80.000.000 -    80.100.000   Control Bunkers
           81.000.000 -    82.000.000   WiS Promenades
           82.000.000 -    85.000.000   Planetary Districts

           90.000.000 -    98.000.000   EVE characters created after 2010-11-03 (NOTE THAT THE OLD ONES ARE SADLY SCATTERED BETWEEN 100 AND 2100 MILLS)
           98.000.000 -    99.000.000   Corporations created after 2010-11-03  (NOTE THAT THE OLD ONES ARE SADLY SCATTERED BETWEEN 100 AND 2100 MILLS)
           99.000.000 -   100.000.000   EVE alliances created after 2010-11-03  (NOTE THAT THE OLD ONES ARE SADLY SCATTERED BETWEEN 100 AND 2100 MILLS)

         2100.000.000 - 2.147.483.647   DUST characters
      }}}

      Utilize this knowledge whenever you can. Need to select all celestials in all solar systems?

      {{{
        SELECT *
          FROM zinventory.items
         WHERE locationID BETWEEN 30000000 AND 40000000 AND
               itemID BETWEEN 40000000 AND 50000000
      }}}

      And If you needed only all planets doing the join to inventory.typesDx (to add a condition on the groupID of planets) is much cheaper from this reduced record set than for all records in invItems.
