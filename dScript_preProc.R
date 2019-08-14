#######################################################
# Module: MANM354 - Machine Learning and Visualisations
# Author: Tim McKinnon-Lower
# Date: 29/04/2017
# Developed on R version 3.3.2
#######################################################

###########################
### Preprocessing Functions
###########################

## Full preprocessing of a training dataset. can remove fields to achieve better data for training
## Input: training dataset to preprocess, boolean to indicate if outliers should be removed
## Return: Dataset preprocessed ready for machine learning
preProc_preProcessTrainData<-function(train_data,removeOutliers) {
  
  ## Determine field types of raw data (numeric/symbolic)
  print("Preprocessing: Determining Field Types")
  fieldTypes <- preProc_fieldTypes(train_data)
  ## Update numeric fields to separate them between ordinal and discreet
  fieldTypes <- preProc_numeric(train_data,fieldTypes,6,11,TRUE)
  
  ## separate ordinal fields
  ordinals <- train_data[,which(fieldTypes=="ORDINAL")]
  
  if (removeOutliers) {
    print("Preprocessing: Removing outliers...")
    # vis data before outlier removal
    preProc_plotSortedRecords(ordinals,"Sorted Records Before Outlier Removal",c("skyblue"))
    #vis_barplotsForOrdinals(train_data,c("skyblue","orange"))
    # remove outliers
    ordinals <- preProc_outlier(ordinals, 0.99)
    # vis data after outlier removal
    preProc_plotSortedRecords(ordinals,"Sorted Records After Outlier Removal",c("darkseagreen2"))
    #vis_barplotsForOrdinals(train_data,c("darkseagreen2","pink1"))
  }
  
  # convert ordinals to z-scale
  print("Preprocessing: Converting ordinals to z-scale...")
  zscaled <- apply(ordinals, MARGIN = 2, FUN = function(X) (scale(X,center=TRUE, scale=TRUE)))
  # scale ordinals to range [0.0,1.0]
  ordinalML <- rescale(zscaled,range(0,1))
  
  ## preprocess symbolic/discreet fields
  print("Preprocessing: Converting categorical/symbolic fields to binary or one-hot encoded fields")
  categoricalML <- preProc_categorical(train_data,fieldTypes,10)
  # merge ordinal and categorical data
  trainML <- cbind(ordinalML, categoricalML)
  
  ## check missing fields
  #fieldsMissing<-preProc_hasMissingFields(trainML)
  #print(paste("Preprocessing: Preprocessed data has missing fields:",fieldsMissing, sep=" "))
  #if (fieldsMissing) {
  #  trainML<-preProc_replaceMissingFields(trainML)
  #}
  
  # remove non numeric customer ID field for pre-processing
  trainML1 <- trainML[,-grep("ImageSegmentID", colnames(trainML))]
  
  # plot correlation of all fields pre correlation removal
  print("Preprocessing: Checking for and removing correlated fields...")
  preProc_plotCorrelagram(cor(trainML1, use="everything"))
  # remove one correlated field from each pair of correlated fields
  trainCorrML <- preProc_correlation(trainML1, 0.85)
  # plot correlation of all fields post correlation removal
  preProc_plotCorrelagram(cor(trainCorrML, use="everything"))
  
  # merge customer ID with preprocessed data
  print("Preprocessing: Prepare final data set for machine learning...")
  trainML_All <- cbind(trainML[,grep("ImageSegmentID", colnames(trainML))],trainCorrML[,])
  colnames(trainML_All)[1]<-"ImageSegmentID"
  
  # strip colnames of special chars
  print("Preprocessing: Stripping column names of special characters...")
  trainML_All<-preProc_stripColnames(trainML_All)
  print("*** Preprocessing complete. ***")
  return(trainML_All)
}

## Full preprocessing of a new dataset. Should not remove any fields or outliers.
## Input: new dataset to preprocess
## Return: Dataset preprocessed ready for classification
preProc_preProcessNewData<-function(new_data) {
  
  ## Determine field types of raw data (numeric/symbolic)
  print("Preprocessing: Determining Field Types")
  fieldTypes <- preProc_fieldTypes(new_data)
  ## Update numeric fields to separate them between ordinal and discreet
  fieldTypes <- preProc_numeric(new_data,fieldTypes,6,11)
  
  ## Separate ordinal fields
  ordinals <- new_data[,which(fieldTypes=="ORDINAL")]
  
  # convert ordinals to z-scale
  print("Preprocessing: Converting ordinals to z-scale...")
  zscaled <- apply(ordinals, MARGIN = 2, FUN = function(X) (scale(X,center=TRUE, scale=TRUE)))
  # scale ordinals to range [0.0,1.0]
  ordinalML <- rescale(zscaled,range(0,1))
  
  ## preprocess symbolic/discreet fields
  print("Preprocessing: Converting catagorical/symbolic fields to binary or one-hot encoded fields")
  categoricalML <- preProc_categorical(new_data,fieldTypes,10)
  # merge ordinal and categorical data
  verifyML <- cbind(ordinalML, categoricalML)
  
  ## check missing fields
  #fieldsMissing<-preProc_hasMissingFields(verifyML)
  #print(paste("Preprocessing: Preprocessed data has missing fields:",fieldsMissing))
  #if (fieldsMissing) {
  #  verifyML<-preProc_replaceMissingFields(verifyML)
  #}
  
  # strip colnames of special chars
  print("Preprocessing: Stripping column names of special characters...")
  verifyML<-preProc_stripColnames(verifyML)
  print("*** Preprocessing complete. ***")
  return(verifyML)
}

## Strip column names of special characters
## Input: dataset to process
## Return: processed dataset with special chars removed from field names
preProc_stripColnames <- function(dataset){
  names(dataset)<-gsub(" ", "", names(dataset), fixed = TRUE)
  names(dataset)<-gsub("-", "", names(dataset), fixed = TRUE)
  names(dataset)<-gsub("(", "", names(dataset), fixed = TRUE)
  names(dataset)<-gsub(")", "", names(dataset), fixed = TRUE)
  return(dataset)
}

## Objective: Check if a dataset has missing (null or na) fields
## Input: dataset
## Return: Boolean value - false if no missing fields, true otherwise
preProc_hasMissingFields <- function(dataset){
  print("Checking for missing values...")
  hasMissing<-FALSE
  for(dcol in 1:ncol(dataset)){
    for(drow in 1:nrow(dataset)) {
      if (is.na(dataset[drow,dcol]) || is.null(dataset[drow,dcol])) {
        #print(paste("Data has missing value at row:", drow, "; col:", dcol, sep=" "))
        hasMissing<-TRUE
      }
    }
  }
  return(hasMissing)
}

## Function to replace missing (ordinal) values (NA or NULL) in a dataset with the field's mean value
## Input: dataset
## Return: the updated dataset with missing (ordinal) fields replaced with the mean.
preProc_replaceMissingFields <- function(dataset) {
  print("Replacing missing values (ordinal fields only)...")
  for(dcol in 1:ncol(dataset)) {
    if (is.numeric(dataset[,dcol])) {
      for(drow in 1:nrow(dataset)) {
        if(is.na(dataset[drow,dcol]) || is.null(dataset[drow,dcol])) {
          dataset[drow,dcol] <- mean(dataset[,dcol], na.rm=TRUE)
        }
      }
    }
  }
  return(dataset)
}

## Function to determine initial field types of a given dataset
## Input: dataset
## Return: field types as a vector
preProc_fieldTypes <- function(dataset){
  field_types<-vector()
  for(field in 1:(ncol(dataset))){
    if (is.numeric(dataset[,field]))
      field_types[field]<-"NUMERIC"
    else
      field_types[field]<-"SYMBOLIC"
  }
  return(field_types)
}

## Objective: Convert numeric field types in a dataset to discreet or ordninal. Type is determined when a numeric 
##            field has more than "cutoff" empty "bins" between data points
## Input: dataset, field types as a vector, cut-off point, number of bins, boolean flag for histogram display
## Output: Plots barplots of bins for each field
## Return: An updated vector of field types
preProc_numeric <- function(dataset,field_types,cutoff,nbin,displayGraphs=FALSE){
  # For every column in dataset
  for(field in 1:(ncol(dataset))){
    #Only for fields marked NUMERIC
    if (field_types[field]=="NUMERIC") {
      #Scale the whole field (column) to between 0 and 1
      scaled_column<-rescale(dataset[,field],range(0,1))
      
      #Generate the "cutoff" points for each of 10 bins
      #so we will get 0-0.1, 0.1-0.2...0.9-1.0
      cutpoints<-seq(0,1,length=nbin)
      
      #This creates an empty vector that will hold the counts of ther numbers in the bin range
      bins<-vector()
      
      #Now we count how many numbers fall within the range
      for (i in 2:nbin){
        if(i!=nbin) {sub_vector<-scaled_column[(scaled_column<cutpoints[i])&(scaled_column>=cutpoints[i-1])]}
        else {sub_vector<-scaled_column[(scaled_column<=cutpoints[i])&(scaled_column>=cutpoints[i-1])]}
        ln<-length(sub_vector)
        bins<-append(bins,ln)
      }
      
      # determine if field types should be discreet or ordinal based on number of empty bins and cutoff
      if (length(which(bins<1.0))>cutoff) {
        field_types[field]<-"DISCREET"
      }
      else {
        field_types[field]<-"ORDINAL"
      }
      
      # sclae bin counts as percentages for display purposes
      bins<-(bins/length(scaled_column))*100
      # Plot bar chart of field bins and percentages
      if(displayGraphs){barplot(bins, main=paste(names(dataset[field]),"-",field_types[field]),xlab="Bins",ylab="Percent")}
    }
  }
  return(field_types)
}

## Function to check for outliers above a confidnece threshold and replaces them with the field's mean.
## Input: dataset of ordinal fields, confidence level
## Return: an updated dataset with outliers replaced with the mean
preProc_outlier <- function(ordinals,confidence){
  new_ords<-ordinals
  #For every ordinal field in our dataset
  for(field in 1:(ncol(ordinals))){
    # sort field into unique list of records and generate scores based on confidence to determine outlier values
    uniqueSorted<-unique(sort(ordinals[,field],decreasing=TRUE))
    outlierIndexes<-which(scores(uniqueSorted,type="chisq",prob=confidence))
    # plot unique records and highlight outliers identified
    preProc_plotOutliers(uniqueSorted,outlierIndexes,colnames(ordinals)[field],"Unique Sorted Records (Outliers in Red)",c("blue","red"))
    # if outliers exist, replace with the mean
    if (length(outlierIndexes)>0){
      ordinalsNoOutliers<-rm.outlier(ordinals[,field],fill=TRUE)
      uniqueSortedNoOutliers<-unique(sort(ordinalsNoOutliers,decreasing=TRUE))
      new_ords[,field]<-ordinalsNoOutliers #Put in the values with the outliers replaced by means
    }
  }
  return(new_ords)
}

## Function to plot unique records in a field and outliers highlighted in red
## Input: sorted vector of unique field values, vector of outlier indexes, graph title, vector(2) of graph colours
## Output: Plots the unique sorted data and overlays the outliers in a different colour.
preProc_plotOutliers<-function(sorted,outliers,fieldName,title,clrs=c("black","orange")){
  plot(1:length(sorted),sorted,pch=1,xlab="Unique Record",ylab=paste("Unique Value:",fieldName),main=title,col=clrs[1])
  if (length(outliers)>0)
    points(outliers,sorted[outliers],col=clrs[2],pch=19)
  
}

## Function to plot all sorted records from each numeric field in a dataframe
## Input: dataframe, title, colour vector(1)
## Output: plot of sorted records for each field
preProc_plotSortedRecords <- function(dataframe,title,clrs=c("blue")){
  for(field in 1:(ncol(dataframe))){
    if (is.numeric(dataframe[,field])) {
      sorted<-sort(dataframe[,field],decreasing=TRUE)
      plot(1:length(sorted),sorted,pch=1,xlab="Record Number",ylab=paste("Value: ",colnames(dataframe)[field]),main=title,col=clrs[1])
    }
  }
}

## Function for symbolic/categorical field pre-processing. Uses binary encoding for fields with only 2 literals 
## or one-hot encoding for fields with more than 2 literals but less than mlit
## Input: Dataset and vector of field types, mlit determines max literals that will be converted to one-hot
## Returns: Updated dataset with binary and one-hot encoded fields where literals was less than the limit
preProc_categorical <- function(dataset,field_types,mlit){
  
  #This is a dataframe of the transformed categorical fields
  categorical <- data.frame(first=rep(NA,nrow(dataset)),stringsAsFactors=FALSE)

  #store failed field names to add back
  failedFields <- vector()
  
  #For every field in our dataset
  for(field in 1:(ncol(dataset))){
    
    #Only for catagorical/symbolic fields
    if ((field_types[field]=="SYMBOLIC")||(field_types[field]=="DISCREET")) {
      
      #Create a list of unique values in the field (each is a literal)
      literals <- as.vector(unique(dataset[,field]))
      numberLiterals <- length(literals)
      
      #if there are just two literals in the field we can convert to 0 and 1
      if (numberLiterals==2){
        transformed <- ifelse(dataset[,field]==literals[1],0.0,1.0)
        categorical <- cbind(categorical,transformed)
        colnames(categorical)[ncol(categorical)]<-colnames(dataset)[field]

      } else if (numberLiterals<mlit){
        #We have now to one-hot encoding FOR SMALL NUMBER of literals
        for(num in 1:numberLiterals){
          nameOfLiteral<-literals[num]
          hotEncoding<-ifelse (dataset[,field]==nameOfLiteral,1.0,0.0)
          categorical<-cbind(categorical,hotEncoding)
          colnames(categorical)[ncol(categorical)]<-paste(colnames(dataset)[field],nameOfLiteral)
        }
      } else if (numberLiterals>=mlit) {
        failedFields <- append(failedFields, colnames(dataset)[field])
        print(paste("Field",colnames(dataset)[field],"has too many literals:",numberLiterals,"- Field will not be one-hot encoded.",sep=" "))
      }
    }
  }
  
  #print(paste('COL NAME2:',colnames(categorical)))
  # remove first column of NA values
  categorical <- categorical[,-1, drop = FALSE]
  #print(paste('COL NAME3:',colnames(categorical)))
  
  # add back fields that had too many literals
  if (length(failedFields)>0) {
    for (i in 1:length(failedFields)) {
      categorical <- cbind(dataset[i],categorical)
    }
  }
  return(categorical)
}

## Redundant Fields removal
## Input: dataset of fields to check for correlation, correltion probability cutoff
## Return: processed dataset with positively correlated fields above the threshold removed
preProc_correlation <- function(dataset,cutoff){
  
  print(paste("Before redundancy check Fields=",ncol(dataset)))
  
  #Remove any fields that have a stdev of zero (i.e. they are all the same)
  xx <- which(apply(dataset, 2, function(x) sd(x, na.rm=TRUE))==0)+1
  
  if (length(xx)>0L) {
    print(paste("Fields with sdev equal to 0 removed:", xx, sep=" "))
    dataset<-dataset[,-xx]
  }
  
  #Kendall is more robust for data do not necessarily come from a bivariate normal distribution.
  cr <- cor(dataset, use="everything")
  cr[(which(cr<0))]<-0 #Positive correlation coefficients only
  print("before plot correl")
  preProc_plotCorrelagram(cr)
  
  correlated<-which(abs(cr)>=cutoff,arr.ind = TRUE)
  list_fields_correlated<-correlated[which(correlated[,1]!=correlated[,2]),]
  
  if (length(list_fields_correlated)>0){
    
    #We have to check if one of these fields is correlated with another as cant remove both!
    v<-vector()
    numc<-nrow(list_fields_correlated)
    for (i in 1:numc){
      if (length(which(list_fields_correlated[i,1]==list_fields_correlated[i:numc,2]))==0) {
        v<-append(v,list_fields_correlated[i,1])
      }
    }
    print("Removing the following correlated fields")
    print(unique(names(dataset)[v]))
    
    return(dataset[,-v]) #Remove the first field that is correlated with another
  }
  return(dataset)
}

## Plotting function to show correlation
## Input: dataset to display correlated fields of
## Output: displays correlated fields of the data
preProc_plotCorrelagram <- function(cr){
  #To fit on screen, convert field names to a numeric
  rownames(cr)<-1:length(rownames(cr))
  colnames(cr)<-rownames(cr)
  parBackup<-par(no.readonly = TRUE)
  corrplot(cr, method="circle",title="Correlation Matrix",mar=c(1,0,1.5,0))
  par(parBackup)
}
