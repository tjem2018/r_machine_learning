#######################################################
# Module: MANM354 - Machine Learning and Visualisations
# Author: Tim McKinnon-Lower
# Date: 29/04/2017
# Developed on R version 3.3.2
#######################################################

## Function to compute a gains/cumulative lift table
## Input: vector of expected clases, vector of predicted classes, number of buckets to list gain over
## Output: prints a lift graph for the given parameters
## Return: returns a gains table
## Cite Source: Code copied from function “lift”
##              Obtained from http://www.listendata.com/2015/06/r-function-gain-and-lift-table.html
##              Accessed 18 May 2017
gain_lift <- function(depvar, predcol, groups=10) {
  #if(!require(dplyr)){
  #  install.packages("dplyr")
  #  library(dplyr)}
  if(is.factor(depvar)) depvar <- as.integer(as.character(depvar))
  if(is.factor(predcol)) predcol <- as.integer(as.character(predcol))
  helper = data.frame(cbind(depvar, predcol))
  helper[,"bucket"] = ntile(-helper[,"predcol"], groups)
  gaintable = helper %>% group_by(bucket)  %>%
    summarise_at(vars(depvar), funs(total = n(),
                                    totalresp=sum(., na.rm = TRUE))) %>%
    mutate(Cumresp = cumsum(totalresp),
           Gain=Cumresp/sum(totalresp)*100,
           Cumlift=Gain/(bucket*(100/groups)))
  return(gaintable)
}
