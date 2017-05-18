require(tidyverse)
require(igraph)
require(ggthemes)
require(revemetrics)
require(lubridate)


# Gathering the Sample of 500 corporations from the POPULATION Sample (see compose_analysis_sample_v1)

sampDesc = "select * from edvald_research.umd.samp1_sampleDescr" %>% QueryDB()
sampSelect = "select * from edvald_research.umd.samp1_selection" %>% QueryDB()
sampDens = "select * from edvald_research.umd.samp1_networkDensity" %>% QueryDB()
sampFlows = "select * from edvald_research.umd.samp1_employeeFlows" %>% QueryDB()

# Preparing Data for Anlaysis ---------------

# Corps in the sample
    scorps = sampDesc %>% select(corporationID) %>% distinct() %>% c %>% .[[1]]

# unique ID KEY
    creatorKey = sampDesc %>% select(characterID=creatorCharID,
                                     userID=creatorUserID,
                                     userEmail=creatorEmail) %>% distinct
    employeeKey = sampDesc %>% select(characterID=employeeCharID,
                                      userID=employeeUserID,
                                      userEmail=employeeEmail) %>% distinct
    uid.key = unique(rbind(creatorKey,employeeKey))

# Build Date frame to map TS on
    dateFrame = data.frame(eventDate=seq(as.Date('2015-01-01'),as.Date('2017-04-15'),by='day'),
                           stringsAsFactors = F)
    
    for(i in 1:length(scorps)){
      D = dateFrame;D$corporationID = scorps[i]
      if(i==1){base=D}else{base = rbind(base,D)}
    }



# From flows, generate size and exit variables
    
    sf1 = merge(sampFlows,uid.key,by="characterID",all.x=T) # map on key
    
    # Growth Counter
    size.rec = sf1 %>% group_by(eventDate,corporationID=enterCorp) %>% 
      summarize(n_enter=n_distinct(userEmail)) %>% 
      ungroup %>% filter(corporationID %in% scorps) %>% 
      merge(base,.,by=c('eventDate','corporationID'),all.x=T)
    size.rec$n_enter[is.na(size.rec$n_enter)] = 0 # fill NAs
    
    # Exit Counter
    exit.rec = sf1 %>% group_by(eventDate,corporationID=exitCorp) %>% 
      summarize(n_exit=n_distinct(userEmail)) %>% 
      ungroup %>% filter(corporationID %in% scorps) %>% 
      merge(base,.,by=c('eventDate','corporationID'),all.x=T)
    exit.rec$n_exit[is.na(exit.rec$n_exit)] = 0
    
    # Combind Records
    flow.rec = merge(size.rec,exit.rec,by=c("eventDate","corporationID"),all=T)
    
    # Drop corp dates prior to start date
    startDates = sampDesc %>% select(corporationID,corpCreateDate) %>% distinct %>% 
      mutate(startDate = as.Date(corpCreateDate,'%Y-%m-%d')) %>% 
      select(-corpCreateDate) 
    
    
    for ( i in 1:nrow(startDates)){ # Subset time series by Corp Creation Date
      cat(i,"--")
      sub = flow.rec %>% filter(corporationID == startDates$corporationID[i],
                                eventDate >= startDates$startDate[i])
      if(i==1){flow.rec2 =sub}else{flow.rec2=rbind(flow.rec2,sub)}
    }
    
            # check that only valide dates hold
            # startDates[1,]
            flow.rec2 %>% filter(corporationID==98451522) %>% View()
            
    
    # create size variable by mapping entry and exit
    flow.rec2 = flow.rec2 %>%
      arrange(corporationID,eventDate) %>%
      group_by(corporationID) %>%
      mutate(size = cumsum(n_enter)-cumsum(n_exit))
    
    
    # Plotting
          plot_size = function(corpID){ # Quick plot of membership flows
            flow.rec2 %>% filter(corporationID%in% corpID) %>% 
              reshape2::melt(id = c("corporationID","eventDate")) %>% 
              ggplot(.) + geom_line(aes(x=eventDate,y=value,color=variable),lwd=1.5) +
              scale_color_hc() + theme_hc() + facet_wrap(~corporationID,ncol = 2) +
              ylab("Membership Count") + xlab("Date")
          }
          
          
          flow.rec2 %>% summarize(ave_size=mean(size)) %>% 
            arrange(desc(ave_size)) %>% top_n(10) %>% 
            select(corporationID) %>% c %>% .[[1]] %>% 
            plot_size(.)
          
          set.seed(321)
          scorps[sample(1:500,10)] %>%  plot_size(.)
          
          
          plot_size(98372002)
          plot_size(98464601)
          
    
# Generate selection time series ------
          
    accepted = sampFlows %>% filter(enterCorp %in% scorps) %>% 
            select(eventDate,corporationID=enterCorp,characterID) %>% 
            mutate(eventDate=as.Date(eventDate),accepted = 1)
    
    exited = sampFlows %>% filter(exitCorp %in% scorps) %>% 
      select(eventDate,corporationID=exitCorp,characterID) %>% 
      mutate(eventDate=as.Date(eventDate),exited = 1)
          
    flow = plyr::rbind.fill(sampSelect,accepted,exited)
    flow[is.na(flow)] = 0
    
    flow2 = merge(flow,uid.key,by="characterID",all.x=T)
    
    # Look at who applied/invited, and who got in.
    sel_process = flow %>% group_by(corporationID,characterID) %>% 
      arrange(eventDate) %>% 
      mutate(A = lag(applied,1),
             A = ifelse(is.na(A),0,A),
             I = lag(invited,1),
             I = ifelse(is.na(I),0,I),
             applied_accepted = as.numeric(A == 1 & accepted ==1),
             invited_accepted = as.numeric(I == 1 & accepted ==1),
             applied_not_accepted = as.numeric(A == 1 & accepted ==0),
             invited_not_accepted = as.numeric(I == 1 & accepted ==0),
             either = (applied_accepted + invited_accepted),
             accepted_no_app = as.numeric(either==0 & accepted==1)) %>% 
      filter(exited!=1) %>% select(-A,-I,-either,-exited) %>% ungroup()
    
    # Look at the sums
    sel_process %>% group_by(corporationID) %>%
      select(applied_accepted:accepted_no_app) %>% 
      summarize_each(funs(sum))
      
    sel_processCorp = sel_process %>% group_by(corporationID) %>% 
      summarize(applied_accepted = sum(applied_accepted),
                applied_not_accepted = sum(applied_not_accepted),
                invited_accepted = sum(invited_accepted),
                invited_not_accepted = sum(invited_not_accepted),
                total_invited = invited_accepted+invited_not_accepted,
                total_applied = applied_accepted+applied_not_accepted,
                total_accepted = applied_accepted+invited_accepted+sum(accepted_no_app),
                selective = round(applied_not_accepted/total_applied,3),
                rejected = round(invited_not_accepted/total_invited,3),
                funky=round(sum(accepted_no_app)/total_accepted,3))
    
    sel_processCorp$selective[is.nan(sel_processCorp$selective)] = 0
    sel_processCorp$rejected[is.nan(sel_processCorp$rejected)] = 0
    
# Gather Measures by corp as unit
    
    dens.corp = sampDens %>% group_by(corporationID) %>% 
      summarize(aveDens = mean(density))
    
    flow.corp = flow.rec2 %>% group_by(corporationID) %>% 
      summarize(ave_enter=mean(n_enter),
                ave_exit = mean(n_exit),
                ave_size = mean(size))
    
    gen.corp = sampDesc %>% group_by(corporationID) %>% 
    summarize(high=max(propHighSec),
              low=max(propLowSec),
              null=max(propNullSec),
              worm=max(propWormhole),
              monthly=max(aveMonthlyTotalJumps))
    
    
    M = merge(sel_processCorp,dens.corp,by="corporationID")
    M = merge(M,flow.corp,by="corporationID")
    M = merge(M,gen.corp,by="corporationID")
    
    
    # Negatively Associated
    summary(lm(aveDens~selective,data=M))
    summary(lm(aveDens~selective+funky,data=M))
    summary(lm(aveDens~selective+total_invited,data=M))
    summary(lm(aveDens~selective+ave_size,data=M))
    summary(lm(aveDens~selective+ave_exit,data=M))
    summary(lm(ave_exit~aveDens+ave_size,data=M))
    summary(lm(ave_size~selective,data=M))
    
    summary(lm(aveDens~selective+total_invited+null,data=M))
    
    
# aggregated by month --- 
      
    sel_process.month = sel_process %>% mutate(m=month(eventDate),y=year(eventDate)) %>% 
      group_by(corporationID,m,y) %>% 
      summarize(applied_accepted = sum(applied_accepted),
                applied_not_accepted = sum(applied_not_accepted),
                invited_accepted = sum(invited_accepted),
                invited_not_accepted = sum(invited_not_accepted),
                total_invited = invited_accepted+invited_not_accepted,
                total_applied = applied_accepted+applied_not_accepted,
                total_accepted = applied_accepted+invited_accepted+sum(accepted_no_app),
                selective = round(applied_not_accepted/total_applied,3),
                rejected = round(invited_not_accepted/total_invited,3),
                funky=round(sum(accepted_no_app)/total_accepted,3))
    sel_process.month$selective[is.nan(sel_process.month$selective)] = 0
    sel_process.month$rejected[is.nan(sel_process.month$rejected)] = 0
    
    dens.month = sampDens %>%  mutate(m=month(eventDate),y=year(eventDate)) %>% 
      group_by(corporationID,m,y) %>% 
      summarize(aveDens = mean(density))
    
    flow.month = flow.rec2 %>% mutate(m=month(eventDate),y=year(eventDate)) %>% 
      group_by(corporationID,m,y) %>% 
      summarize(ave_enter=mean(n_enter),
                ave_exit = mean(n_exit),
                ave_size = mean(size))
       
    M2 = merge(sel_process.month,dens.month,by=c("corporationID","m","y"))
    M2 = merge(M2,flow.month,by=c("corporationID","m","y"))
    M2$ave_size[M2$ave_size<0] = 0

    summary(lm(aveDens~selective,data=M2))
    summary(lm(aveDens~funky,data=M2))
    summary(lm(aveDens~selective+ave_size,data=M2))
    summary(lm(aveDens~selective+total_invited,data=M2))
    summary(lm(aveDens~selective+total_applied,data=M2))
    summary(lm(ave_size~selective,data=M2))
    
    
    save(scorps,flow.rec2,M,M2,file="~/ETD/selection/data/for_hanna_5_15_2017.Rdata")
    
    
    M2 %>% group_by(corporationID) %>%  mutate(selectionLag = lag(selective,1)) %>% 
      lm(selectionLag~aveDens,data=.) %>%  summary(.)
    
   
    