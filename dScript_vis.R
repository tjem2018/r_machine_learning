#######################################################
# Module: MANM354 - Machine Learning and Visualisations
# Author: Tim McKinnon-Lower
# Date: 29/04/2017
# Developed on R version 3.3.2
#######################################################

###########################
### Visualisation Functions
###########################

## Function to visualise all data in a dataset
## Input: raw data to process, sample and visualise
## Output: Displays visualisations and graphs of the data in raw and sampled form
vis_visAll<-function(raw_train_data){
  
  # Plot distribution of IsRoof in training data
  plotclrs<-c("lightblue","mistyrose")
  myTable <- table(raw_train_data[,"IsRoof"])
  bp<-barplot(myTable, main="Barplot IsRoof",xlab="IsRoof",ylab="Record Count", col=plotclrs,cex.names=1)
  legend(x="topright", legend = paste(round((myTable[2]/(myTable[1]+myTable[2]))*100,2),"%",sep=""), col=plotclrs[2], pch=15,title="% IsRoof = Yes")
  text(bp, 0, round(myTable, 1),cex=1,pos=3)
  
  # raw train data plots
  # plot ordinal fields agaist each other to look for high leverage points
  #plot(raw_train_data[,"MonthlyCharges"],raw_train_data[,"TotalCharges"],xlab="MonthlyCharges",ylab="TotalCharges",main="Scatter Plot",col="darkblue", pch=1)
  #plot(raw_train_data[,"TotalCharges"],raw_train_data[,"tenure"],xlab="TotalCharges",ylab="tenure",main="Scatter Plot",col="darkblue", pch=1)
  #plot(raw_train_data[,"tenure"],raw_train_data[,"MonthlyCharges"],xlab="tenure",ylab="MonthlyCharges",main="Scatter Plot",col="darkblue", pch=1)
  
  ## replace missing values with field mean to use data to plot looking for introduced outliers
  #train_data_missing_replaced<-raw_train_data
  #if(preProc_hasMissingFields(raw_train_data)) {
  #  train_data_missing_replaced<-preProc_replaceMissingFields(raw_train_data)
  #}
  
  # train data plots with missing values replaced with mean
  # plot ordinal fields agaist each other to look for high leverage points
  #plot(train_data_missing_replaced[,"MonthlyCharges"],train_data_missing_replaced[,"TotalCharges"],xlab="MonthlyCharges",ylab="TotalCharges",main="Scatter Plot (after handle missing values)",col="darkgreen", pch=1)
  #plot(train_data_missing_replaced[,"TotalCharges"],train_data_missing_replaced[,"tenure"],xlab="TotalCharges",ylab="tenure",main="Scatter Plot (after handle missing values)",col="darkgreen", pch=1)
  #plot(train_data_missing_replaced[,"tenure"],train_data_missing_replaced[,"MonthlyCharges"],xlab="tenure",ylab="MonthlyCharges",main="Scatter Plot (after handle missing values)",col="darkgreen", pch=1)
  
  # create variable for raw training data less incomplete records with NA in any field
  train_less_na<-raw_train_data[complete.cases(raw_train_data[,]),]
  
  # train data plots with incomplete records removed
  # plot ordinal fields agaist each other to look for high leverage points
  #plot(train_less_na[,"MonthlyCharges"],train_less_na[,"TotalCharges"],xlab="MonthlyCharges",ylab="TotalCharges",main="Scatter Plot (after remove incomplete records)",col="darkred", pch=1)
  #plot(train_less_na[,"TotalCharges"],train_less_na[,"tenure"],xlab="TotalCharges",ylab="tenure",main="Scatter Plot (after remove incomplete records)",col="darkred", pch=1)
  #plot(train_less_na[,"tenure"],train_less_na[,"MonthlyCharges"],xlab="tenure",ylab="MonthlyCharges",main="Scatter Plot (after remove incomplete records)",col="darkred", pch=1)
  
  # Create random sample subset of raw data for visualisations
  random_train_data<-train_less_na[order(runif(nrow(train_less_na))),]
  sample_records<-signif(nrow(random_train_data)*0.2,2)
  train_data_sample<-random_train_data[1:sample_records,]
    
  # Plot ordinal fields againts each other with IsRoof distribution
  # Good options for pch: 1, 16, 18, 20, 23, 24, 25
  #plot(train_data_sample[,"MonthlyCharges"],train_data_sample[,"TotalCharges"],xlab="MonthlyCharges",ylab="TotalCharges",main="Scatter Plot with IsRoof",col=c("blue","orange")[train_data_sample$"IsRoof"], pch=20)
  #legend(x="topright", legend = levels(train_data_sample$IsRoof), col=c("blue","orange"), pch=20,title="IsRoof")
  #plot(train_data_sample[,"TotalCharges"],train_data_sample[,"tenure"],xlab="TotalCharges",ylab="tenure",main="Scatter Plot with IsRoof",col=c("blue","orange")[train_data_sample$"IsRoof"], pch=20)
  #legend(x="topright", legend = levels(train_data_sample$IsRoof), col=c("blue","orange"), pch=20,title="IsRoof")
  #plot(train_data_sample[,"tenure"],train_data_sample[,"MonthlyCharges"],xlab="tenure",ylab="MonthlyCharges",main="Scatter Plot with IsRoof",col=c("blue","orange")[train_data_sample$"IsRoof"], pch=20)
  #legend(x="topright", legend = levels(train_data_sample$IsRoof), col=c("blue","orange"), pch=20,title="IsRoof")
  
  # barplots
  #vis_barplotsForOrdinals(train_data_sample,c("cornflowerblue","coral2"))
  vis_plotBarplots(train_data_sample,"IsRoof",c("slategray2","thistle3"))
  
  # Data visualisations
  #c("moccasin")
  # histograms for raw data
  vis_plotHistograms(raw_train_data, "- All Data",c("ivory2"))
  # histograms for sample data with normal density curves added
  # c("darkseagreen1","darkslategray") c("cornflowerblue","mediumorchid4") c("paleturquoise", "dodgerblue")
  vis_plotHistogramsAndNormal(train_data_sample, "- Sample Data", c("honeydew1","darkslategray"))
  vis_plotHistogramsAndNormal(train_data_sample[which(train_data_sample[,"IsRoof"]==0),], "- Sample Data (IsRoof:No)",c("azure1","cornflowerblue"))
  vis_plotHistogramsAndNormal(train_data_sample[which(train_data_sample[,"IsRoof"]==1),], "- Sample Data (IsRoof:Yes)",c("lavenderblush","coral2"))
  print("Visualisation complete.")
}

## Function to display barplots for ordinal fields
## Input: dataset to plot graphs for, colour vector(2)
vis_barplotsForOrdinals<-function(dataset,plotclrs=c("cornflowerblue","coral2")) {
  parBackup<-par(no.readonly = TRUE)
  par(lty="blank") # set line type
  par(mar=c(5,4,4,2)) # set margins
  par(las=0) # set axis labels parallel to axis
  # Stacked Bar Plot - IsRoof/tenure
  #myTable <- table(dataset$IsRoof,dataset$tenure)
  #barplot(myTable, main="Stacked Barplot with IsRoof",xlab="tenure",ylab="Record Count", col=plotclrs,cex.names=0.8)
  # 15, 16, 19, 7, 10, 12, 13, 22, 
  #legend(x="topright", legend = rownames(myTable), col=plotclrs, pch=15,title="IsRoof")
  
  # stacked barplot - IsRoof/MonthlyCharges
  #myTable <- table(dataset$IsRoof,round(dataset$MonthlyCharges,0))
  #barplot(myTable, main="Stacked Barplot with IsRoof",xlab="MonthlyCharges",ylab="Record Count", col=plotclrs,cex.names=0.8)
  # 15, 16, 19, 7, 10, 12, 13, 22, 
  #legend(x="topright", legend = rownames(myTable), col=plotclrs, pch=15,title="IsRoof")
  
  # stacked barplot - IsRoof/TotalCharges
  #myTable <- table(dataset$IsRoof,signif(dataset$TotalCharges,2))
  #barplot(myTable, main="Stacked Barplot with IsRoof",xlab="TotalCharges",ylab="Record Count", col=plotclrs,cex.names=0.8)
  # 15, 16, 19, 7, 10, 12, 13, 22, 
  #legend(x="topright", legend = rownames(myTable), col=plotclrs, pch=15,title="IsRoof")
  
  par(parBackup)
}

## Plot stacked barplots for all fields focusing on focus field distribution
## input: dataset to plot and focus field to show distribution for, colour vector(2)
## output: stacked barplots with focus field distribution for each field
vis_plotBarplots<-function(dataset,focusField,plotclrs=c("slategray2","thistle3")) {
  parBackup<-par(no.readonly = TRUE)
  par(lty="solid") # set line type
  par(las=2) # make labels perpendicular to axis
  par(mar=c(5,10,4,2)) # increase y-axis margin
  col1<-dataset[,focusField]
  for (i in 1:ncol(dataset)) {
    col2<-dataset[,colnames(dataset)[i]]
    myTable <- table(col1,col2)
    if (length(myTable)<100) {
      barplot(myTable, main=paste(colnames(dataset)[i]," Categories"),xlab="Record Count",horiz=TRUE,col=plotclrs,cex.names=0.8)
      # 15, 16, 19, 7, 10, 12, 13, 22, 
      legend(x="topright", legend = rownames(myTable), col=plotclrs, pch=15,title=focusField)
    }
  }
  par(parBackup)
}

## Plot histograms of numeric fields in a dataset
## Input: dataset to plot, title prefix as string, colour vector(1)
## Output: 
vis_plotHistograms <- function(dataset, titleSuffix="",clrs=c("azure3")) {
  parBackup<-par(no.readonly = TRUE)
  par(lty="solid") # set line type
  par(las=0) # set axis lables parallel to axis
  par(mar=c(5,4,4,2)) # set margins
  for (i in 1:ncol(dataset)) {
    if (is.numeric(dataset[,i])) {
      hist(dataset[,i],main=paste("Histogram",titleSuffix),xlab=colnames(dataset)[i],col=clrs[1])
    }
  }
  par(parBackup)
}

## Plot histograms with overlay line of normal distribution - only for numeric fields
## Input: dataset, title prefix, colour vector(2)
## Output: displays histogram with normal distribution density curve based on mean and sd of given data
vis_plotHistogramsAndNormal <- function(dataset, titleSuffix="",clrs=c("lightblue","darkblue")) {
  parBackup<-par(no.readonly = TRUE)
  par(lty="solid") # set line type
  par(las=0) # set axis lables parallel to axis
  par(mar=c(5,4,4,2)) # set margins
  for (i in 1:ncol(dataset)) {
    if (is.numeric(dataset[,i])) {
      hist(dataset[,i],prob=TRUE,breaks=20,main=paste("Histogram & Normal Dist. Curve",titleSuffix),xlab=colnames(dataset)[i],col=clrs[1])
      curve(dnorm(x,mean(dataset[,i]),sd(dataset[,i])),add=TRUE,col=clrs[2],lwd=2)
    }
  }
  par(parBackup)
}

## Run linear regression and plot for each field against IsRoof with regression line
## Input: dataset to regress against, dependent variable
## Output: displays linear regression of dependent variable on each numeric (non-binary) field
vis_plotLinearRegressionForAllVars<- function(dataset, dependentVar) {
  if (is.numeric(dataset[,dependentVar])) {
    independentVars<-dataset[,-grep(dependentVar, colnames(dataset))]
    for (i in 1:ncol(independentVars)) {
      if (is.numeric(independentVars[,i])&length(levels(as.factor(independentVars[,i])))>2) {
        linMod<-lm(dataset[,dependentVar]~independentVars[,i])
        plot(independentVars[,i],dataset[,dependentVar],xlab=colnames(independentVars)[i],ylab=dependentVar,main=paste("Linear Regression:", dependentVar, "on", colnames(independentVars)[i]))
        abline(linMod,col="red",lwd=3)
      }
    }
  }
}

## output linear regression graphs and other visualisations on preprocessed data ready for machine learning
## input: preprocessed dataset
## output: samples the dataset and plots linear regression of IsRoof on all numeric fields
vis_visualiseAndRegressMLData<-function(ml_data) {
  # Create random sample subset of raw data for visualisations
  random_ml_data<-ml_data[order(runif(nrow(ml_data))),]
  records<-nrow(random_ml_data)*0.1
  sample_ml_data<-random_ml_data[1:records,]
  ## linear regression analysis for all numeric fields against dependent field
  vis_plotLinearRegressionForAllVars(sample_ml_data, "IsRoof")
}

