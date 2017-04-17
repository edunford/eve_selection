# Parsing Jump logs for members in relevant corps for one week in April
# (4.01.17 to 4.07.17) -- sample and record generated in SQL.

library(tidyverse)
require(igraph)
require(reshape2)

# Initial organization of data
    # logs <- read.csv("~/ETD/selection/data/april_1_7_rel_jump_logs.csv",header=F,stringsAsFactors = F)
    # head(logs)
    # colnames(logs) = c("corporationID","customerID",
    #            "userID","inAlliance","eventDate",
    #            "characterID","destinationID","high",
    #            "low","null","worm")
    # jump_logs = logs
    # # Convert Columns
    # for(c in 8:11){ jump_logs[,c] = round(as.numeric(jump_logs[,c]),2)}
    # jump_logs[,5] = as.Date(jump_logs[,5])
    # save(jump_logs,file="~/ETD/selection/data/april_1_7_rel_jump_logs.Rdata")

# Load Cleaned data 
load("~/ETD/selection/data/april_1_7_rel_jump_logs.Rdata")


# Summaries ------------------
    jump_logs %>% group_by(corporationID) %>% tally() %>% arrange(desc(n))
    
          # Pandemic Horde (noobie corp) dominates the records with KarmaFleet in 
          # second (which has an externalized application process) and Ascendance in
          # third.
    
    jump_logs %>% group_by(corporationID) %>% tally() %>% 
      ggplot(.) + geom_histogram(aes(log(n)),
                                 fill="dodgerblue3",col="white")
    
    
    jump_logs %>% distinct(corporationID) %>% tally() # 5284 distinct corps in the records. 
    
    jump_logs %>% group_by(corporationID) %>% 
      summarize(N_chars =n_distinct(userID),N=n()) %>%
      arrange(desc(N_chars)) # number of distinct characters and activity

    
# Building interaction Networks-------------
    
    # Sample from the low end of the distribution but where more than one
    # character is operating
    set.seed(333)
    draw =  jump_logs %>% group_by(corporationID) %>% 
      summarize(N_chars =n_distinct(userID),N=n()) %>%
      filter(N_chars >= 4, N <= 250) %>% sample_n(1) %>% as.data.frame()
    draw
    
    
    samp = jump_logs %>% filter(corporationID==draw[1,1]) %>% 
      arrange(eventDate,destinationID) %>% 
      select(eventDate,userID,destinationID) %>% distinct(.) 
    
    samp %>% group_by(eventDate,userID) %>% summarize(n_distinct(destinationID))
    
   
   # Mapping the Networks 
    
    # A loop: SLOW and LONG way 
    out = c()
    for(r in 1:nrow(samp)){
      for(c in 1:nrow(samp)){
        if( r != c & r < c & samp$userID[r] != samp$userID[c] &
            samp$eventDate[r] == samp$eventDate[c] & 
            samp$destinationID[r] == samp$destinationID[c]){
          tmp = data.frame(sideA=samp$userID[r],
                           sibeB=samp$userID[c],
                           dest=samp$destinationID[r])
          out = rbind(out,tmp)
        }
      }
    }
    
    out
    
    # Generate Network
    EM = as.matrix(out[,1:2]);colnames(EM) = NULL
    actors = unique(c(out$sideA,out$sibeB))
    net <- graph_from_data_frame(EM,actors,directed=F)
    net = simplify(net)
    plot.igraph(net,vertex.color="steelblue",vertex.frame.color="white",
                edge.color="grey",edge.width=1,vertex.size=4,
                vertex.label="")

    
  # A more efficient approacy?
    
    # Dplyr
    dyad = samp %>% group_by(destinationID,eventDate) %>%
      mutate(ind=paste0('userID', ((row_number()+1) %% 2+1)), 
             ind_row = ceiling(row_number()/2)) %>%
      spread(ind, userID) %>% 
      select(-ind_row) %>% filter(!is.na(userID2)) %>% 
      ungroup %>% as.data.frame
    
    dyad
    
    dim(dyad)
    EM = dyad %>% select(userID1,userID2) %>% as.matrix();colnames(EM) = NULL
    actors = unique(c(dyad$userID1,dyad$userID2))
    net <- graph_from_data_frame(EM,actors,directed=F)
    # net = simplify(net)
    plot.igraph(net,vertex.color="steelblue",vertex.frame.color="white",
                edge.color="grey",edge.width=1,vertex.size=4,
                vertex.label="")
    
    # doesn't account for 2+ potential pairs
    
    
    # Cpp functional approach (big 0 n^2)
    source("~/ETD/selection/code/co_occur.R")
    
    out2 = samp %>% select(eventDate,destinationID,userID) %>% co_occur(.)
    EM = out2 %>% select(user1,user2) %>% as.matrix();colnames(EM) = NULL
    actors = unique(c(out2$user1,out2$user2))
    net <- graph_from_data_frame(EM,actors,directed=F)
    net <- simplify(net)
    plot.igraph(net,vertex.color="steelblue",vertex.frame.color="white",
                edge.color="grey",edge.width=1,vertex.size=4,
                vertex.label="")
    
    
# With the method d?efined, let's try it out on a big corp with a lot of
# interactions.
    
    # Pandemic Horde (98388312)
    S = jump_logs %>% filter(corporationID==98388312) %>% 
      select(eventDate,destinationID,userID) %>% as.data.frame
    
    
    
    