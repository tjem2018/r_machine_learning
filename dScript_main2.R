#######################################################
# Module: MANM354 - Machine Learning and Visualisations
# Author: Tim McKinnon-Lower
# Date: 29/04/2017
# Developed on R version 3.3.2
#######################################################

## *******************************************************************************************
## USER MODIFIABLE PARAMS START. Modify parameters in this section as per environment.
## *******************************************************************************************

## Set working dir
workingDir<-"/Users/tim/R/Diss/Project"
#workingDir<-"H:/TimsFiles/Semester2/MachineLearning/R_CODE/Project"

## Set output dir
outputDir <- "output"

## Set machine learning algorithms to use
# C50
RunBoostedC50 = FALSE;
new_c50 = TRUE;
# Random Forest
RunRF = FALSE;
new_rf = TRUE;
# Neural Network
RunANN = TRUE;
new_ann = FALSE;

## Define non-default path to packages install location if required
#.libPaths(c(.libPaths(),"C:/Users/tm00529/AppData/Local/Temp/RtmpEXbrE6/downloaded_packages"))

## To Install the required packages uncomment lines below and run, or install manually
#install.packages(c("ggplot2","lattice","caret","plotrix","outliers","corrplot","neuralnet","e1071", "randomForest","MASS","pROC"))
#install.packages(c("C50","stringr","partykit"))
#install.packages("dplyr") ## gains graph

## *******************************************************************************************
## USER MODIFIABLE PARAMS END. Do not modify code below this line.
## *******************************************************************************************

###################
## Initialisation
###################

## Initialise system clears console and objects in memory
init <- function () {
  # Remove all objects and functions from environment
  rm(list = setdiff(ls(), lsf.str()))
  # Clear the console
  cat("\014")
}

## Set working directory and load required packages
# Input: working directory (full path)
# Output: prints the newly set working directory location
setup<-function(wd) {
  # load required packages
  library(ggplot2)
  library(lattice)
  library(caret)
  library(plotrix)
  library(outliers)
  library(corrplot)
  library(neuralnet)
  library(e1071)
  library(randomForest)
  library(MASS)
  library(pROC)
  library(C50)
  library(stringr)
  library(partykit)
  library(dplyr)
  # Set the working directory
  setwd(wd)
  print(paste("Working directory is:",getwd()))
  # set seed for generating random numbers
  set.seed(123)
}

init()
setup(workingDir)

##################
### Source Required Scripts
##################
source("dScript_vis.R")
source("dScript_preProc.R")
source("dScript_ml.R")
source("dScript_eval.R")
source("dScript_gain.R")

## send console output to file
sink()
sink(file="console_out.txt",append=TRUE,type="output",split=TRUE)
logtime <- as.character(Sys.time())
print(paste("### Script Started:",logtime))

###################
## Global Variables
###################
# training data
#raw_train_data <- read.csv("PPDv4_TEST_2_10050100_ALL.csv", header=TRUE)
##raw_train_data <- read.csv("PPDv4p1_TEST_3_10050100_small.csv", header=TRUE)
#raw_train_data <- read.csv("PPDv4p1_TEST_2_1005070_ALL.csv", header=TRUE)
#raw_train_data <- read.csv("PPDv4p1_TEST_2_1005090_ALL.csv", header=TRUE)
#raw_train_data <- read.csv("PPDv4p1_TEST_2_10050100_ALL.csv", header=TRUE)
#raw_train_data <- read.csv("PPDv4p3_TEST_2p1_1005095_ALL.csv", header=TRUE)
#raw_train_data <- read.csv("PPDv4p3_TEST_2p1_10050100_ALL.csv", header=TRUE)
raw_train_data <- read.csv("PPDv4bp3_TEST_2p1_1005075_ALL.csv", header=TRUE)
# verification data
#raw_verify_data <- read.csv("PPDv4_VALIDATE_2_10050100_ALL.csv", header=TRUE)
#raw_verify_data <- read.csv("PPDv4p1_VALIDATE_2_1005070_ALL.csv", header=TRUE)
#raw_verify_data <- read.csv("PPDv4p1_VALIDATE_2_1005090_ALL.csv", header=TRUE)
#raw_verify_data <- read.csv("PPDv4p1_VALIDATE_2_10050100_ALL.csv", header=TRUE)
#raw_verify_data <- read.csv("PPDv4p3_VALIDATE_2_1005095_ALL.csv", header=TRUE)
#raw_verify_data <- read.csv("PPDv4p3_VALIDATE_2_10050100_ALL.csv", header=TRUE)
#raw_verify_data <- read.csv("PPDv4bp3_VALIDATE_2_1005075_ALL.csv", header=TRUE)
raw_verify_data <- read.csv("PPDv4bp3_UNSEEN_1005075_ALL.csv", header=TRUE)
# remove redundant fields
# train
lookup_table_train <- raw_train_data[,1:4]
raw_train_data <- cbind(raw_train_data[,1],raw_train_data[,5:ncol(raw_train_data)])
colnames(raw_train_data)[1]<-"ImageSegmentID"
# verify
lookup_table_verify <- raw_verify_data[,1:4]
raw_verify_data <- cbind(raw_verify_data[,1],raw_verify_data[,5:ncol(raw_verify_data)])
colnames(raw_verify_data)[1]<-"ImageSegmentID"

######################
## Run visualisations
######################
print("*** Visualisation started... ***")
#vis_visAll(raw_train_data)
print("*** Visualisation complete. ***")

#####################
## Handle missing fields
#####################
## check for and replace missing fields with the field mean (numeric fields only)
#print("*** Check/Replace missing fields... ***")
train_data<-raw_train_data
#if(preProc_hasMissingFields(raw_train_data)) {
#  train_data<-raw_train_data[complete.cases(raw_train_data[,]),]
#}
## double check no missing values remain
#print(paste("Data has missing values in non-ordinal fields:",preProc_hasMissingFields(train_data)))

######################
## Run Preprocessing
######################
print("*** Preprocessing started... ***")
trainML_All<-preProc_preProcessTrainData(train_data,FALSE)
print("*** Preprocessing complete. ***")

# do visualisations and linear regression on prepreocessed data
print("*** Post Preprocessing visualisation started... ***")
#vis_visualiseAndRegressMLData(trainML_All)
print("*** Post Preprocessing visualisation complete. ***")

###################
## Split data into train and test data for ML
###################
## split data into train and test data sets
print("*** Splitting data into train and test... ***")
#Randomise the entire data set and split between train and test sets
trainML_All_randomised<-trainML_All[order(runif(nrow(trainML_All))),]
train_records<-round(nrow(trainML_All_randomised)*(70/100))
trainRange <- 1:train_records
testRange <- -trainRange
training_data <- trainML_All[trainRange,]
testing_data <- trainML_All[testRange,]
print("*** Train and test ready. ***")

# remove ImageSegmentID field prior to machine learning
print("*** Preparing data for machine learning algorithms... ***")
print("Removing customer ID from test and train sets prior to machine learning...")
ml_train_data <- training_data[,-grep("ImageSegmentID", colnames(training_data))]
ml_test_data <- testing_data[,-grep("ImageSegmentID", colnames(testing_data))]

# remove IsRoof field prior to machine learning (as required by some models)
print("Separating output fields from datasets prior to machine learning...")
train<-ml_train_data[,-grep("IsRoof", colnames(ml_train_data))] # Train dataset without the output field
train_expected<-ml_train_data[,grep("IsRoof", colnames(ml_train_data))] # Train dataset expected classes
test<-ml_test_data[,-grep("IsRoof", colnames(ml_test_data))] # Test dataset without output field
test_expected<-ml_test_data[,grep("IsRoof", colnames(ml_test_data))] # Test dataset expected classes
print("*** Data ready for machine learning. ***")

##################
## Machine Learning
##################
print("*** Start Machine Learning... ***")

# C5.0 Boosted
if (RunBoostedC50) {
  print("###################################")
  print("*** C5.0 Boosted start... ***")
  print("###################################")
  
  ## train model choosing optimal parameters
  if (new_c50) {
    ## train model choosing optimal parameters
    c5_all_out<-ml_c5(train_data,ml_train_data,train,train_expected,testing_data,ml_test_data,test,test_expected,14,14,1,0.01,0.01,0.1,750)
    # save output
    save(c5_all_out, list=as.character("c5_all_out"),ascii=TRUE,file="Bak_C50_AllOut")
    # save model
    c50_model <- c5_all_out$best_model
    save(c50_model, list=as.character("c50_model"),ascii=TRUE,file="Bak_C50_Model")
  }
  else {
    # load previously saved model
    load(file="/Users/tim/R/Diss/Project/Bak_C50_AllOut",verbose=TRUE)
  }
  
  ## Run Prediction on Verify dataset
  print("*** Verification data processing started... ***")
  processed_verify_data<-eval_predictUnseenData(raw_verify_data,c5_all_out$best_model,c5_all_out$best_thresh,lookup_table_verify,"C50",0)
  ## only required columns
  data_subset <- processed_verify_data[,1:6]
  data_subset <- cbind(processed_verify_data[,ncol(processed_verify_data)],data_subset[])
  colnames(data_subset)[1]<-"IsRoof"
  # create a file with all verification data, costs, predicted IsRoof and probabilities to the working dir
  write.table(data_subset,file=paste(outputDir,"/OUTPUT_C50_ClassificationResults.csv",sep=""),row.names=FALSE,col.names=TRUE, sep=",")
  print("*** Verification data processing complete. ***")
  
  print("###################################")
  print("*** C5.0 Boosted complete. ***")
  print("###################################")
}

# Random Forest
if (RunRF) {
  print("###################################")
  print("*** Random Forest start... ***")
  print("###################################")
  
  ## train model choosing optimal parameters
  if (new_rf) {
    ## train model choosing optimal parameters
    ml_all_out<-ml_rf(train_data,ml_train_data,train,train_expected,testing_data,ml_test_data,test,test_expected,2000,2000,250,0.01,0.01,0.1,750)
    # save output
    save(ml_all_out, list=as.character("ml_all_out"),ascii=TRUE,file="Bak_RF_AllOut")
    # save model
    rf_model <- ml_all_out$best_model
    save(rf_model, list=as.character("rf_model"),ascii=TRUE,file="Bak_RF_Model")
  }
  else {
    # load previously saved model
    load(file="/Users/tim/R/Diss/Project/Bak_RF_AllOut",verbose=TRUE)
  }
  
  ## Run Prediction on Verify dataset
  print("*** Verification data processing started... ***")
  processed_verify_data<-eval_predictUnseenData(raw_verify_data,ml_all_out$best_model,ml_all_out$best_thresh,lookup_table_verify,"RF",0)
  ## only required columns
  data_subset <- processed_verify_data[,1:6]
  data_subset <- cbind(processed_verify_data[,ncol(processed_verify_data)],data_subset[])
  colnames(data_subset)[1]<-"IsRoof"
  # create a file with all verification data, costs, predicted IsRoof and probabilities to the working dir
  write.table(data_subset,file=paste(outputDir,"/OUTPUT_RF_ClassificationResults.csv",sep=""),row.names=FALSE,col.names=TRUE, sep=",")
  print("*** Verification data processing complete. ***")
  
  print("###################################")
  print("*** Random Forest complete. ***")
  print("###################################")
}

if (RunANN) {
  print("###################################")
  print("*** Neural Network start... ***")
  print("###################################")
  
  ## train model choosing optimal parameters
  if (new_ann) {
    ann_all_out<-ml_ann(train_data,ml_train_data,train,train_expected,testing_data,ml_test_data,test,test_expected,500,500,500,0.01,0.01,0.1,750)
    # save output
    save(ann_all_out, list=as.character("ann_all_out"),ascii=TRUE,file="Bak_ANN_AllOut")
    # save model
    ann_model <- ann_all_out$best_model
    save(ann_model, list=as.character("ann_model"),ascii=TRUE,file="Bak_ANN_Model")
  }
  else {
    # load previously saved model
    load(file="/Users/tim/R/Diss/Project/Bak_ANN_AllOut",verbose=TRUE)
    ann_model <- ann_all_out$best_model
  }
  
  # predict probabilities
  ann_tr_predict<-ann_model$net.result[[1]]
  # Train Data ROC Curve
  tr_best_thresh <- eval_ROCcurve(train_expected,ann_tr_predict,"ANN ROC Curve: Train Data")
  # determine classes based on best thresh
  ann_tr_predict_class<-ifelse(ann_tr_predict>0.5,1,0)
  # generate Confusion matrix stats on Train data
  ann_tr_confStats<-eval_calcConfusion(train_expected,ann_tr_predict_class,"Train")
  eval_printConfusionStats(ann_tr_confStats)
  
  # predict probability and classes on test data
  ann_tst_predict<-neuralnet:::compute(ann_model,ml_test_data[,-grep("IsRoof", colnames(ml_test_data))],rep=1)
  # Test Data ROC Curve
  tst_best_thresh <- eval_ROCcurve(test_expected,ann_tst_predict$net.result,"ANN ROC Curve: Test Data")
  ann_tst_predict_class<-ifelse(ann_tst_predict$net.result>0.5,1,0)
  # generate Confusion matrix stats on Test data
  ann_tst_confStats<-eval_calcConfusion(test_expected,ann_tst_predict_class,"Test")
  eval_printConfusionStats(ann_tst_confStats)
  dropTrainTest<-round((ann_tr_confStats$TPR-ann_tst_confStats$TPR),2)
  print(paste("Neural Network Drop in TP rate Train to Test:",dropTrainTest))
  ## gain graph test
  dt = gain_lift(test_expected,as.vector(ann_tst_predict_class), groups = 10)
  write.table(dt,file="OUTPUT_ANN_Gains.csv",row.names=FALSE,col.names=TRUE, sep=",")
  graphics::plot(dt$bucket, dt$Cumlift, type="l", ylab="Cumulative lift", xlab="Bucket",main="ANN Lift Chart Test")
  
  ## Run Prediction on Verify dataset
  print("*** Verification data processing started... ***")
  processed_verify_data<-eval_predictUnseenData(raw_verify_data,ann_model,0.1,lookup_table_verify,"ANN",1,ann_all_out$formula)
  ## only required columns
  print("OUT")
  data_subset <- processed_verify_data[,1:6]
  data_subset <- cbind(processed_verify_data[,ncol(processed_verify_data)],data_subset[])
  colnames(data_subset)[1]<-"IsRoof"
  # create a file with all verification data, costs, predicted IsRoof and probabilities to the working dir
  write.table(data_subset,file=paste(outputDir,"/OUTPUT_ANN_ClassificationResults.csv",sep=""),row.names=FALSE,col.names=TRUE, sep=",")
  print("*** Verification data processing complete. ***")
  
  print("###################################")
  print("*** Neural Network complete. ***")
  print("###################################")
}

logtime <- as.character(Sys.time())
print(paste("### Script Complete:",logtime))
# end output to file
sink()
