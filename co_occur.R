# Dependency Cpp engine for iteration 
Rcpp::sourceCpp("~/ETD/selection/code/dyadMe.cpp")

co_occur = function(data){
  # Function that finds spatio-temporal co-occurrence where no ambiguity in the 
  # space of temporal unit. The process iterates through the matrices and 
  # records all one-for-one matches, returning an index of each co-occurring
  # entry's position. 
  
  # Data must be ordered as follows:
  # - col1 = date
  # - col2 = location id
  # - col3 = unique user id
  
  inputdata = as.data.frame(data)
  inputdata = inputdata[,1:3]
  for(c in 1:ncol(inputdata)){
    if(!is.numeric(inputdata[,c])){
      if(class(inputdata[,c]) %in% c("character","factor")){
        inputdata[,c] = as.numeric(as.factor(inputdata[,c]))
      }
      if(class(inputdata[,c])=="Date"){
        inputdata[,c] = as.numeric(inputdata[,c])
      }
    }
  }
  
  loc = dyadMe(as.matrix(inputdata))[-1,]
  id = data[,3]
  cnames = colnames(data)
  rdat = data.frame(data[loc[,1],cnames[1]],
                    data[loc[,1],cnames[2]],
                    user1=id[loc[,1]],
                    user2=id[loc[,2]],
                    stringsAsFactors = F)
  colnames(rdat)[1:2] = cnames[1:2]
  return(rdat)
}

co_occur(df)

