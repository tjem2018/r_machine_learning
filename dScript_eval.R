#######################################################
# Module: MANM354 - Machine Learning and Visualisations
# Author: Tim McKinnon-Lower
# Date: 29/04/2017
# Developed on R version 3.3.2
#######################################################

##############################
### Model Evaluation Functions
##############################

# convert probabilities from a model to a classification vector of values {0,1}
# input: probabilities matrix for positive and negative class membership, probability threshold
# output: classification vector with predicted class membership based on threshold
eval_probToClass<-function(probs, threshold) {
  ve<-vector()
  positiveProbs<-probs[,2]
  for(i in 1:length(positiveProbs)) {
    if (positiveProbs[i] >= threshold) {
      ve<-c(ve,1L)
    }
    else {
      ve<-c(ve,0L)
    }
  }
  return(ve)
}

## Calculate a confusion matrix for 2-class classifier
## Input: vector - expected - {0,1}, Expected outcome from each row (labels)
##        vector - predicted - {0,1}, Predicted outcome from each row (labels)
##        name of data being evaluated as a text string
## Return: list of confusion matrix information
eval_calcConfusion<-function(expected,predicted,dataName){
  # set up variables to store confusion matrix counts for each rate
  TP<-0
  FN<-0
  TN<-0
  FP<-0
  
  for (x in 1:length(predicted)){
    fire<-predicted[x]
    marked<-expected[x]
    
    toadd<-1L

    #In the case of a POSITIVE
    if (fire==TRUE){
      #A fraud transaction was expected and was correctly classified by the rules
      #TRUE POSITIVE
      if (marked==1.0){
        TP<-TP+toadd
      }
      else
      {
        #A genuine transaction was expected and was wrongly classified as fraud by the rules
        #FALSE POSITIVE
        FP<-FP+toadd
      }
    }
    else {
      #A genuine transaction was expected and was correctly classified by the rules
      #TRUE NEGATIVE
      if (marked==0.0){
        TN<-TN+toadd
      }
      else
      {
        #A fraud transaction was expected but was wrongly classified as genuine by the rules
        #FALSE NEGATIVE
        FN<-FN+toadd
      }
    }
  }
  
  RMSE<-round(eval_calcRMSE(expected,predicted),digits=2)
  
  retList<-list(  "dataName"=dataName,
                  "TP"=TP,
                  "TN"=TN,
                  "FP"=FP, 
                  "FN"=FN,
                  "TPR"=eval_calcTPR(TP,FP,TN,FN),
                  "TNR"=eval_calcTNR(TP,FP,TN,FN),
                  "FPR"=eval_calcFPR(TP,FP,TN,FN),
                  "FNR"=eval_calcFNR(TP,FP,TN,FN),
                  "errRate"=eval_calcErrorRate(TP,FP,TN,FN),
                  "accuracy"=eval_calcAccuracy(TP,FP,TN,FN),
                  "ppos"=eval_calcPrecisionPositive(TP,FP,TN,FN),
                  "pneg"=eval_calcPrecisionNegative(TP,FP,TN,FN),
                  "RMSE"=RMSE,
                  "expected"=expected,
                  "predicted"=predicted
  )
  return(retList)
}

## Evaluate confusion matrix and other stats output by a model
## Input: result set from a call to eval_calcConfusion function
## Output: prints confusion matrix and other model evaluation statistics to console
eval_printConfusionStats<-function(results){
  # print Confusion matrix info
  print(paste("CONFUSION MATRIX:",results$dataName))
  print(paste("| TN:",results$TN,"| FN:",results$FN,"|"))
  print(paste("| FP:",results$FP,"| TP:",results$TP,"|"))
  # print other evaluation statistics
  print("STATISTICS:")
  print(paste("True Positive Rate (Sensitivity): ",round(results$TPR,2)))
  print(paste("True Negative Rate (Specificity): ",round(results$TNR,2)))
  print(paste("False Negative Rate: ",round(results$FNR,2)))
  print(paste("False Positive Rate: ",round(results$FPR,2)))
  print(paste("Error Rate: ",round(results$errRate,2)))
  print(paste("Accuracy: ",round(results$accuracy,2)))
  print(paste("Precision Positive Predictions: ",round(results$ppos,2)))
  print(paste("Precision Negative Predictions: ",round(results$pneg,2)))
  print(paste("Calculated RMSE on test data for all fields =",results$RMSE))
}

## Function to render and display an ROC graph at a given threshold
## Input: expected classes as vector, predicted classes as vector, threshold used for classification, graph title
## Output: renders and displays an ROC graph
eval_ROC <- function(expected,predicted,thresh,graphTitle){
  parBackup<-par(no.readonly = TRUE)
  par(mar=c(0,0,1.5,0))
  rr<-roc(expected,predicted,plot=FALSE,percent=TRUE,partial.auc=c(100, 75), partial.auc.correct=TRUE,partial.auc.focus="sens",uc.polygon=TRUE,
          max.auc.polygon=TRUE, grid=TRUE,print.auc=TRUE, show.thres=TRUE,add=FALSE,xlim=c(1,0))
  plot(rr,xlim=c(100,0),xaxs="i")
  title(graphTitle)
  
  #Selects the "best" threshold for lowest FPR and highest TPR
  analysis<-coords(rr, x="best",best.method="closest.topleft",
                   ret=c("specificity", "sensitivity"))
  
  threshold<-thresh
  specificity<-analysis[1L]
  sensitivity<-analysis[2L]
  fpr<-round(100.0-specificity,digits=2L)
  
  #Add crosshairs to the graph
  abline(h=sensitivity,col="sienna1",lty=3,lwd=2)
  abline(v=specificity,col="sienna1",lty=3,lwd=2)
  
  #Annote with text
  text(x=70,y=5, adj = c(0.2,0),cex=1,col="blue",
       paste("Threshold (selected): ",round(threshold,digits=2L),
             " TPR: ",round(sensitivity,digits=2L),
             "% FPR: ",fpr,"%",sep=""))
  par(parBackup)
}

## Function to render and display an ROC curve
## Input: expected classes as vector, predicted probabilities as vector, graph title
## Output: renders and displays an ROC curve using the probabilities and expected values provided
## Return: Optimal threshold based on closest to top left criteria
eval_ROCcurve<-function(expected,probs,graphTitle) {
  parBackup<-par(no.readonly = TRUE)
  par(mar=c(0,0,1.5,0))
  expected<-expected[order(probs, decreasing=TRUE)]
  probs<-probs[order(probs, decreasing=TRUE)]
  rr<-roc(response=expected,predictor=probs,plot=FALSE,percent=TRUE,partial.auc=c(100, 75), partial.auc.correct=TRUE,partial.auc.focus="sens",uc.polygon=TRUE,
          max.auc.polygon=TRUE, grid=TRUE,print.auc=TRUE, show.thres=TRUE,add=FALSE,xlim=c(1,0))
  plot(rr,xlim=c(100,0),xaxs="i")
  title(graphTitle)
  
  #Selects the "best" threshold for lowest FPR and highest TPR
  analysis<-coords(rr, x="best",best.method="closest.topleft",
                   ret=c("threshold", "specificity", "sensitivity","accuracy", "tn", "tp", "fn", "fp", "npv","ppv"))
  
  threshold<-analysis[1L]
  specificity<-analysis[2L]
  sensitivity<-analysis[3L] #same as TPR
  fpr<-round(100.0-specificity,digits=2L)
  
  #Add crosshairs to the graph
  abline(h=sensitivity,col="mediumaquamarine",lty=3,lwd=2)
  abline(v=specificity,col="mediumaquamarine",lty=3,lwd=2)
  
  #Annote with text
  text(x=70,y=5, adj = c(0.2,0),cex=1,col="blue",
       paste("Threshold (closest to top left): ",round(threshold,digits=2L),
             " TPR: ",round(sensitivity,digits=2L),
             "% FPR: ",fpr,"%",sep=""))
  par(parBackup)
  return(threshold)
}

## function to print out information on processed unseen data
## Input: a processed dataset (unseen data that has been run through the model)
## Output: prints various information
eval_printInfoProcessedNewData<-function(all_verify_data){
  IsRoofYes<-length(which(all_verify_data[,grep("predictIsRoof", colnames(all_verify_data))]==1))
  IsRoofNo<-length(which(all_verify_data[,grep("predictIsRoof", colnames(all_verify_data))]==0))
  print("###")
  print("VERIFICATION DATA INFO:")
  print("###")
  print(paste("Total Records in Verify Data:",nrow(all_verify_data)))
  print(paste("Amount IsRoof predicted as Yes",IsRoofYes))
  print(paste("Amount IsRoof predicted as No",IsRoofNo))
  print(paste("Percent of customers to entice",round(100*IsRoofYes/nrow(all_verify_data),2)))
}

## Function to process and unseen data and generate predicted IsRoof and probability alongside total charges
## Input: raw unseen data, model to use to evaluate the data, probability to use for classification, 
##        model used description, pmode (predict=0/compute=1)
## Return: Data sorted by (1)IsRoof prediction, (2)IsRoof probability, (3)customer's total charges (all descending)
eval_predictUnseenData<-function(raw_verify_data,final_model,final_thresholds,lookup_table,modelUsed,pmode,fmla="y~x1+x2") {
  
  ## Handle missing fields
  ## check for and replace missing fields with the field mean (numeric fields only)
  print("###")
  print("Processing verification data...")
  print("###")
  print("*** Check/Replace missing fields (verification data)... ***")
  verify_data<-raw_verify_data
  #if(preProc_hasMissingFields(verify_data)) {
  #  verify_data<-preProc_replaceMissingFields(verify_data)
  #}
  ## double check no missing values remain
  #print(paste("Verification data has missing values in non-ordinal fields:",preProc_hasMissingFields(verify_data)))
  
  ## Run Preprocessing
  print("*** Preprocessing started (verification data)... ***")
  verify_pp_data<-preProc_preProcessNewData(verify_data)
  print("*** Preprocessing complete (verification data). ***")
  
  ## Prep verification data for predictions
  ml_verify_data <- verify_pp_data[,-grep("ImageSegmentID", colnames(verify_pp_data))]
  
  ## Predictions for verification data
  print("*** Running model on verification data... ***")
  if (pmode==0) {
    verify_predict<-predict(final_model,ml_verify_data,type="prob")
    verify_predict_class<-eval_probToClass(verify_predict,final_thresholds)
  }
  else {
    modelFrame <- model.frame(fmla,data=ml_verify_data)
    verify_predict<-neuralnet:::compute(final_model,modelFrame[,-grep("IsRoof", colnames(modelFrame))],rep=1)
    verify_predict <- verify_predict$net.result
    verify_predict_class<-ifelse(verify_predict>final_thresholds,1,0)
  }
  
  ## Print and display verification data stats
  expected<-raw_verify_data[,grep("IsRoof", colnames(raw_verify_data))]
  # Confusion matrix
  verify_confStats<-eval_calcConfusion(expected,verify_predict_class,"Verify")
  eval_printConfusionStats(verify_confStats)
  # ROC Curve
  eval_ROCcurve(expected,verify_predict,paste(modelUsed,":ROC Curve: Verify Data"))
  
  ## gain graph verify/validation data
  dt = gain_lift(expected,as.vector(verify_predict_class), groups = 10)
  write.table(dt,file="OUTPUT_ANN_Gains_verify.csv",row.names=FALSE,col.names=TRUE, sep=",")
  graphics::plot(dt$bucket, dt$Cumlift, type="l", ylab="Cumulative lift", xlab="Bucket",main="ANN Lift Chart Unseen Data")
  
  # Regroup verification data with predictions, ImageSegmentIDs, total costs
  all_verify_data<-cbind(verify_predict_class,ml_verify_data)
  colnames(all_verify_data)[1]<-"predictIsRoof"
  if (pmode==0) {
    all_verify_data<-cbind(verify_predict[,2],all_verify_data)
    colnames(all_verify_data)[1]<-"probabilityIsRoof"
  }
  else {
    all_verify_data<-cbind(verify_predict[,1],all_verify_data)
    colnames(all_verify_data)[1]<-"probabilityIsRoof"
  }
  all_verify_data<-cbind(verify_pp_data[,grep("ImageSegmentID", colnames(verify_pp_data))],all_verify_data)
  colnames(all_verify_data)[1]<-"ImageSegmentID"
  #all_verify_data<-eval_addTotalCostsToDataset(all_verify_data,verify_data)
  #all_verify_data<-all_verify_data[,-grep("ORIGImageSegmentID", colnames(all_verify_data))]
  
  # add back the I and J matrix postion fields and image name fields
  all_verify_data <- addMatrixPositions(lookup_table,all_verify_data)
  
  # sort predicted records by IsRoof descending, then TotalCharges descending
  # generate and print column indexes and lengths
  predictIsRoofIndex<-grep("predictIsRoof", colnames(all_verify_data))
  probIsRoofIndex<-grep("probabilityIsRoof",colnames(all_verify_data))
  #totalChargesIndex<-grep("ORIGTotalCharges", colnames(all_verify_data))
  
  #print(paste("Predict IsRoof Index:",predictIsRoofIndex,"; Probabilities Index: ",probIsRoofIndex,"; TotalCharges Index:",totalChargesIndex))
  #print(paste("Predict IsRoof col length:",length(all_verify_data[,predictIsRoofIndex])))
  #print(paste("Probabilities col length: ",length(all_verify_data[,probIsRoofIndex])))
  #print(paste("TotalCharges length:",length(all_verify_data[,totalChargesIndex])))
  
  # order columns
  all_verify_data<-all_verify_data[order(all_verify_data[,predictIsRoofIndex],all_verify_data[,probIsRoofIndex],decreasing=c(TRUE,TRUE),method="radix"),]
  
  # return data
  return(all_verify_data)
}

# function to add back the image name and classified tile matrix positions
addMatrixPositions<-function(lookup_table,all_verify_data){
  # get indexes of the unique identifiers in each dataset
  lookupIName<-grep("ImageSegmentID", colnames(lookup_table))
  dataIName<-grep("ImageSegmentID",colnames(all_verify_data))
  
  # sort data by unique ID in each dataset
  lookup_table<-lookup_table[order(lookup_table[,lookupIName],decreasing=c(TRUE),method="radix"),]
  all_verify_data<-all_verify_data[order(all_verify_data[,dataIName],decreasing=c(TRUE),method="radix"),]
  
  lookup_jpos<-lookup_table[,grep("JPos", colnames(lookup_table))]
  lookup_ipos<-lookup_table[,grep("IPos", colnames(lookup_table))]
  lookup_name<-lookup_table[,grep("ImageName", colnames(lookup_table))]
  
  all_verify_data<-cbind(lookup_jpos,all_verify_data[])
  colnames(all_verify_data)[1]<-"JPos"
  all_verify_data<-cbind(lookup_ipos,all_verify_data[])
  colnames(all_verify_data)[1]<-"IPos"
  all_verify_data<-cbind(lookup_name,all_verify_data[])
  colnames(all_verify_data)[1]<-"ImageName"
  
  # return data
  return(all_verify_data)
}

## Calculate the RMSE
## Input: actual classes and predicted classes in vectors
## Output: the Rot Mean Square Errors between actual and predicted values
eval_calcRMSE<-function(actual_y,y_predicted){
  return(sqrt(mean((actual_y-y_predicted)^2)))
}

## functions to calculate stats based on a confusion matrix
# True Positive Rate / Sensitivity
eval_calcTPR<-function(TP,FP,TN,FN){return(100.0*(TP/(TP+FN)))}
# True Negative Rate / Specificity
eval_calcTNR<-function(TP,FP,TN,FN){return(100.0*(TN/(TN+FP)))}
# False Postive Rate
eval_calcFPR<-function(TP,FP,TN,FN){return(100.0*(FP/(FP+TN)))}
# False Negative Rate
eval_calcFNR<-function(TP,FP,TN,FN){return(100.0*(FN/(FN+TP)))}
# Error Rate
eval_calcErrorRate<-function(TP,FP,TN,FN){return(100.0*((FP+FN)/(TP+FP+FN+TN)))}
# Accuracy
eval_calcAccuracy<-function(TP,FP,TN,FN){return(100.0*((TP+TN)/(TP+FP+FN+TN)))}
# Precision for good/positive predictions
eval_calcPrecisionPositive<-function(TP,FP,TN,FN){return(100.0*(TP/(TP+FP)))}
# Precision for bad/negative predictions
eval_calcPrecisionNegative<-function(TP,FP,TN,FN){return(100.0*(TN/(TN+FN)))}

