#######################################################
# Module: MANM354 - Machine Learning and Visualisations
# Author: Tim McKinnon-Lower
# Date: 29/04/2017
# Developed on R version 3.3.2
#######################################################

##############################
### Machine Learning Functions
##############################

##########
## C5.0 boosted Tree
##########
# INPUT: ml_test_data, train, train_expected, testing_data, test, test_expected, trials, retainCost, aquireCost
ml_c5<-function(train_data,ml_train_data,train,train_expected,testing_data,ml_test_data,test,test_expected,minTrials,maxTrials,trialSteps,minThresh,threshSteps,retainCost,aquireCost) {
  print("###")
  print("Training C5.0 boosted decision tree...")
  print("###")
  
  ## Optimise model params for profit
  optimisedParams<-ml_optimiseC5Params(train_data,testing_data,ml_train_data,ml_test_data,minTrials,maxTrials,trialSteps)
  print(paste("Optimised number of trials:",optimisedParams$best_trials))
  print(paste("Best drop in TP rate train - test:",optimisedParams$bestDropTrainTest))
  c5_final_model<-optimisedParams$best_model
  best_tp_drop<-optimisedParams$bestDropTrainTest
  
  #optimisedThresholdProfit<-ml_optimiseC5Profit(train_data,testing_data,ml_test_data,c5_final_model,minThresh,threshSteps,retainCost,aquireCost)
  #print(paste("Best threshold for profit:",optimisedThresholdProfit$best_thresh))
  #print(paste("Highest balance:",optimisedThresholdProfit$highest_bal))
  #c5_best_profit_thresh<-optimisedThresholdProfit$best_thresh

  # choose final threshold to use
  c5_final_thresh<-0.5
  print(paste("Threshold selected:",c5_final_thresh))

  print("###")
  print("Evaluating model...")
  print("###")
  # probabilities and classification for train data
  c5_tr_predict<-predict(c5_final_model,train,type="prob")
  c5_tr_predict_class<-eval_probToClass(c5_tr_predict,c5_final_thresh)
  # Train data Confusion matrix
  c5_tr_confStats<-eval_calcConfusion(train_expected,c5_tr_predict_class,"Train")
  eval_printConfusionStats(c5_tr_confStats)
  # Train Data ROC Curve
  eval_ROCcurve(train_expected,c5_tr_predict,"C5.0 ROC Curve: Train Data")
  
  print("###")
  print("Testing model...")
  print("###")
  # probabilities and classification for test data
  c5_tst_predict<-predict(c5_final_model,ml_test_data[,-grep("IsRoof", colnames(ml_test_data))],type="prob")
  c5_tst_predict_class<-eval_probToClass(c5_tst_predict,c5_final_thresh)
  # Test data Confusion matrix
  c5_tst_confStats<-eval_calcConfusion(test_expected,c5_tst_predict_class,"Test")
  eval_printConfusionStats(c5_tst_confStats)
  # Test Data ROC Curve
  eval_ROCcurve(test_expected,c5_tst_predict,"C5.0 ROC Curve: Test Data")
  # Test Data ROC Graph showing rates for optimal threshold
  c5_tst_roc<-eval_ROC(test_expected,c5_tst_predict_class,c5_final_thresh,"C5.0 ROC: Test Data Classified")
  
  print("###")
  print("Profit analysis (Test Data)...")
  print("###")
  ## gain graph
  dt = gain_lift(test_expected,c5_tst_predict_class, groups = 10)
  write.table(dt,file="OUTPUT_C50_Gains.csv",row.names=FALSE,col.names=TRUE, sep=",")
  graphics::plot(dt$bucket, dt$Cumlift, type="l", ylab="Cumulative lift", xlab="Bucket",main="Boosted C5.0 Lift Chart")
  # merge full test data set with predictions and customer IDs and costs
  test_predict<-cbind(ml_test_data,c5_tst_predict_class)
  colnames(test_predict)[ncol(test_predict)]<-"predictIsRoof"
  c5_all_test_data<-cbind(testing_data[,grep("ImageSegmentID", colnames(testing_data))],test_predict)
  colnames(c5_all_test_data)[1]<-"ImageSegmentID"
  #c5_all_data<-eval_addTotalCostsToDataset(c5_all_test_data,train_data)
  
  # Calculate Profit/Loss info and update highest bal/best thresh as required
  #results<-eval_profitLossFull(c5_all_data[,ncol(c5_all_data)-1],c5_all_data[,ncol(c5_all_data)],c5_all_data[,grep("ORIGTotalCharges", colnames(c5_all_data))],retainCost,aquireCost,"Test Data")
  #eval_printProfitLoss(results)
  #eval_graphProfitLoss(results,"C5.0", "Revenue, Expenses & Balance")
  #balance<-round((results$TPbal + results$FNbal + results$FPbal + results$TNbal),0)
  returnList<-list(
  "best_model" = c5_final_model,
  "best_tp_drop" = best_tp_drop,
  "best_thresh" = c5_final_thresh
  #,
  #"all_data" = c5_all_data,
  #"balance" = balance,
  #"ROI" = results$ROI
  )
  return(returnList)
}

###############
## Random Forest
###############
ml_rf<-function(train_data,ml_train_data,train,train_expected,testing_data,ml_test_data,test,test_expected,minTrees,maxTrees,treeSteps,minThresh,threshSteps,retainCost,aquireCost) {
  print("###")
  print("Training Random Forest...")
  print("###")
  
  # optimise for test data
  optimisedParams<-ml_optimiseRandomForestParams(train_data,testing_data,ml_train_data,ml_test_data,minTrees,maxTrees,treeSteps)
  print(paste("Optimised number of trees:",optimisedParams$best_trees))
  print(paste("Optimised number of variables:",optimisedParams$best_vars))
  print(paste("Best drop in TP rate train - test:",optimisedParams$bestDropTrainTest))
  rf_final_model<-optimisedParams$best_model
  best_tp_drop<-optimisedParams$bestDropTrainTest
  
  #optimisedThresholdProfit<-ml_optimiseRandomForestProfit(train_data,testing_data,ml_test_data,rf_final_model,minThresh,threshSteps,retainCost,aquireCost)
  #print(paste("Best threshold for profit:",optimisedThresholdProfit$best_thresh))
  #print(paste("Highest balance:",optimisedThresholdProfit$highest_bal))
  #rf_best_profit_thresh<-optimisedThresholdProfit$best_thresh

  # choose final threshold to use
  rf_final_thresh<-0.62
  print(paste("Threshold selected:",rf_final_thresh))

  print("###")
  print("Evaluating model...")
  print("###")
  # predictions for train data
  rf_tr_predict<-predict(rf_final_model,train,type="prob")
  rf_tr_predict_class<-eval_probToClass(rf_tr_predict,rf_final_thresh)
  # Train data Confusion matrix
  rf_tr_confStats<-eval_calcConfusion(train_expected,rf_tr_predict_class,"Train")
  eval_printConfusionStats(rf_tr_confStats)
  # Train Data ROC Curve
  eval_ROCcurve(train_expected,rf_tr_predict,"Random Forest ROC Curve: Train Data")
  
  print("###")
  print("Testing model...")
  print("###")
  # predictions for test data
  rf_tst_predict<-predict(rf_final_model,test,type="prob")
  rf_tst_predict_class<-eval_probToClass(rf_tst_predict,rf_final_thresh)
  # Test data Confusion matrix
  rf_tst_confStats<-eval_calcConfusion(test_expected,rf_tst_predict_class,"Test")
  eval_printConfusionStats(rf_tst_confStats)
  # Test Data ROC Curve
  eval_ROCcurve(test_expected,rf_tst_predict,"Random Forest ROC Curve: Test Data")
  # ROC
  rf_tst_roc<-eval_ROC(test_expected,rf_tst_predict_class,rf_final_thresh,"Random Forest ROC: Test Data Classified")
  
  print("###")
  print("Profit analysis (Test Data)...")
  print("###")
  ## gain graph
  dt = gain_lift(test_expected,rf_tst_predict_class, groups = 10)
  write.table(dt,file="OUTPUT_RF_Gains.csv",row.names=FALSE,col.names=TRUE, sep=",")
  graphics::plot(dt$bucket, dt$Cumlift, type="l", ylab="Cumulative lift", xlab="Bucket",main="Random Forest Lift Chart")
  # Regroup test data with predictions and ImageSegmentIDs
  rf_all_test_data<-cbind(ml_test_data,rf_tst_predict_class)
  colnames(rf_all_test_data)[ncol(rf_all_test_data)]<-"predictIsRoof"
  rf_all_test_data<-cbind(testing_data[,grep("ImageSegmentID", colnames(testing_data))],rf_all_test_data)
  colnames(rf_all_test_data)[1]<-"ImageSegmentID"
  #rf_all_data<-eval_addTotalCostsToDataset(rf_all_test_data,train_data)
  # Profit/Loss
  #results<-eval_profitLossFull(rf_all_data[,ncol(rf_all_data)-1],rf_all_data[,ncol(rf_all_data)],rf_all_data[,grep("ORIGTotalCharges", colnames(rf_all_data))],retainCost,aquireCost,"Test Data")
  #eval_printProfitLoss(results)
  #eval_graphProfitLoss(results,"Random Forest", "Revenue, Expenses & Balance")
  #balance<-round((results$TPbal + results$FNbal + results$FPbal + results$TNbal),0)
  returnList<-list(
    "best_model" = rf_final_model,
    "best_tp_drop" = best_tp_drop,
    "best_thresh" = rf_final_thresh
    #,
    #"all_data" = rf_all_data,
    #"balance" = balance,
    #"ROI" = results$ROI
  )
  return(returnList)
}

###############
## Neural Network
###############
ml_ann<-function(train_data,ml_train_data,train,train_expected,testing_data,ml_test_data,test,test_expected,minTrees,maxTrees,treeSteps,minThresh,threshSteps,retainCost,aquireCost) {
  print("###")
  print("Training Neural Network...")
  print("###")
  # best thresholds
  best_model<-NULL
  best_tp_drop<-500
  best_thresh<-0.5
  # set random seed start point
  set.seed(100)
  # formulate parameters for model
  predictors <- colnames(ml_train_data)
  f <- as.formula(paste("IsRoof ~", paste(predictors[!predictors %in% "IsRoof"], collapse = "+")))
  nnode <- round(sqrt(ncol(ml_train_data)))
  #nnode <- 5
  # run model
  ann_model <- neuralnet(f,data=ml_train_data,hidden=nnode,threshold=0.5,stepmax=2e+05,rep=1,
                        lifesign="full",lifesign.step=1e+04,algorithm="rprop+",err.fct="sse",linear.output = FALSE)
  best_model<-ann_model
  
  returnList<-list(
    "best_model" = best_model,
    "best_tp_drop" = best_tp_drop,
    "best_thresh" = best_thresh,
    "formula" = f
  )
  return(returnList)
}

## Optimise C5
## Optimise Random Forest model by varying the classification and checking savde costs for each
## input: original data for total amounts, full test data set for customer IDs, machine learning data for train and test
##        number of trees to train with, from, to and step increments for threshold, cost to retain as decimal, cost to aquire
## output: prints status for each threhsold iteration, returns list of best threshold and best balance
ml_optimiseC5Params<-function(orig_data,all_test_data,ml_train_data,ml_test_data,minTrials,maxTrials,trialSteps) {
  print("Optimising C5 parameters...")
  
  # best thresholds
  best_trials<-0
  bestDropTP_TrainTest<-200
  best_model<-NULL

  # train model
  trialSeq<-seq(minTrials,maxTrials,trialSteps)
  for (trialNum in 1:length(trialSeq)) {
    # set random start point
    set.seed(100)
    print(paste("Testing with",trialSeq[trialNum], "trials. Stopping optimisation tests at ",maxTrials,"trials."))
    c5_out<-C50::C5.0(x=ml_train_data[,-grep("IsRoof", colnames(ml_train_data))], factor(ml_train_data[,grep("IsRoof", colnames(ml_train_data))]), trials=trialSeq[trialNum])
    
    # predict probabilities and classes on train data
    c5_tr_predict<-predict(c5_out,ml_train_data[,-grep("IsRoof", colnames(ml_train_data))],type="prob")
    c5_tr_predict_class<-eval_probToClass(c5_tr_predict,0.5)
    # generate Confusion matrix stats on Train data
    c5_tr_confStats<-eval_calcConfusion(ml_train_data[,grep("IsRoof", colnames(ml_train_data))],c5_tr_predict_class,"Train")
    
    # predict probabilities and classes on test data
    c5_tst_predict<-predict(c5_out,ml_test_data[,-grep("IsRoof", colnames(ml_test_data))],type="prob")
    c5_tst_predict_class<-eval_probToClass(c5_tst_predict,0.5)
    # generate Confusion matrix stats on Test data
    c5_tst_confStats<-eval_calcConfusion(ml_test_data[,grep("IsRoof", colnames(ml_test_data))],c5_tst_predict_class,"Test")
    
    dropTrainTest<-round((c5_tr_confStats$TPR-c5_tst_confStats$TPR),2)
    
    if (dropTrainTest < bestDropTP_TrainTest) {
      best_trials<-trialSeq[trialNum]
      bestDropTP_TrainTest<-dropTrainTest
      best_model<-c5_out
    }
  }
  
  # return list of best thresholds for model and the model object
  returnList<- list(
    "best_trials" = best_trials,
    "bestDropTrainTest" = bestDropTP_TrainTest,
    "best_model" = best_model
  )
  return(returnList)
}

## Optimise Random Forest model by varying the classification and checking savde costs for each
## input: original data for total amounts, full test data set for customer IDs, machine learning data for train and test
##        number of trees to train with, from, to and step increments for threshold, cost to retain as decimal, cost to aquire
## output: prints status for each threhsold iteration, returns list of best threshold and best balance
ml_optimiseRandomForestParams<-function(orig_data,all_test_data,ml_train_data,ml_test_data,minTrees,maxTrees,treeSteps) {
  print("Optimising Random Forest parameters...")
  nVarsMax<-ceiling(sqrt(ncol(ml_train_data)))
  nVarsMin<-floor(nVarsMax/2)
  nVarsMax<-3
  nVarsMin<-3
  # best thresholds
  best_trees<-0
  best_vars<-0
  bestDropTP_TrainTest<-500
  best_model<-NULL
  
  # train model, selecting optimal parameters for min drop in TP rate from train to test
  treeSeq<-seq(minTrees,maxTrees,treeSteps)
  for (var in nVarsMin:nVarsMax) {
    for (trees in 1:length(treeSeq)) {
      # set random start point and run model
      set.seed(100)
      print(paste("Testing with",treeSeq[trees], "trees,",var,"variables. Stopping optimisation tests at ",maxTrees,"trees,",nVarsMax,"variables."))
      rf_model<-randomForest(ml_train_data[,-grep("IsRoof", colnames(ml_train_data))], factor(ml_train_data[,grep("IsRoof", colnames(ml_train_data))]), mtry=var, ntree=treeSeq[trees])
      
      # predict probabilities and classes on train data
      rf_tr_predict<-predict(rf_model,ml_train_data[,-grep("IsRoof", colnames(ml_train_data))],type="prob")
      rf_tr_predict_class<-eval_probToClass(rf_tr_predict,0.5)
      # generate Confusion matrix stats on Train data
      rf_tr_confStats<-eval_calcConfusion(ml_train_data[,grep("IsRoof", colnames(ml_train_data))],rf_tr_predict_class,"Train")
      
      # predict probability and classes on train data
      rf_tst_predict<-predict(rf_model,ml_test_data[,-grep("IsRoof", colnames(ml_test_data))],type="prob")
      rf_tst_predict_class<-eval_probToClass(rf_tst_predict,0.5)
      # generate Confusion matrix stats on Test data
      rf_tst_confStats<-eval_calcConfusion(ml_test_data[,grep("IsRoof", colnames(ml_test_data))],rf_tst_predict_class,"Test")
      
      dropTrainTest<-round((rf_tr_confStats$TPR-rf_tst_confStats$TPR),2)
      
      if (dropTrainTest < bestDropTP_TrainTest) {
        best_trees<-treeSeq[trees]
        best_vars<-var
        bestDropTP_TrainTest<-dropTrainTest
        best_model<-rf_model
      }
    }
  }
  # return list of best thresholds for model and the model object
  returnList<- list(
    "best_trees" = best_trees,
    "best_vars" = best_vars,
    "bestDropTrainTest" = bestDropTP_TrainTest,
    "best_model" = best_model
  )
  return(returnList)
}

## Optimise C5 Probability threshold for max profits
## Optimise model threshold by varying the classification threshold and checking saved costs for each
## input: original data for total amounts, full test data set for customer IDs, machine learning data for train and test
##        number of trees to train with, from, to and step increments for threshold, cost to retain as decimal, cost to aquire
## output: prints status for each threhsold iteration, returns list of best threshold and best balance
ml_optimiseC5Profit<-function(orig_data,all_test_data,ml_test_data,model,minThresh,threshSteps,retainCost,aquireCost) {
  print("Optimising C5 probability threshold for maximum profits...")
  
  # best thresholds
  best_thresh<-0
  highest_bal<-(-1000000)
  
  # loop through sequence to determine best threshold parameter for model
  thresholdSteps<-seq(minThresh,1,threshSteps)
  for (i in 1:length(thresholdSteps)) {
    test_thresh<-thresholdSteps[i]
    
    # predict probabilities and classes on test data
    c5_tst_predict<-predict(model,ml_test_data[,-grep("IsRoof", colnames(ml_test_data))],type="prob")
    c5_tst_predict_class<-eval_probToClass(c5_tst_predict,test_thresh)
    
    # cost/profit analysis on Test data
    # merge full test data set with predictions and customer IDs and costs
    test_predict<-cbind(ml_test_data,c5_tst_predict_class)
    colnames(test_predict)[ncol(test_predict)]<-"predictIsRoof"
    c5_all_test_data<-cbind(all_test_data[,grep("ImageSegmentID", colnames(all_test_data))],test_predict)
    colnames(c5_all_test_data)[1]<-"ImageSegmentID"
    c5_all_data<-eval_addTotalCostsToDataset(c5_all_test_data,orig_data)
    # Calculate Profit/Loss info and update highest bal/best thresh as required
    res<-eval_profitLossFull(c5_all_data[,ncol(c5_all_data)-1],c5_all_data[,ncol(c5_all_data)],c5_all_data[,grep("ORIGTotalCharges", colnames(c5_all_data))],retainCost,aquireCost,"Test Data")
    
    balance<-round((res$TPbal+res$FPbal+res$TNbal+res$FNbal),0)
    custCount<-(res$TPcount+res$FPcount+res$TNcount+res$FNcount)
    custContacted<-(res$TPcount+res$FPcount)
    
    if (balance > highest_bal) {
      best_thresh<-test_thresh
      highest_bal<-balance
    }
  }
  # return list of best thresholds for model and the model object
  returnList<- list(
    "best_thresh" = best_thresh,
    "highest_bal" = highest_bal
  )
  return(returnList)
}

## Optimise Random Forest probability threshold and by checking saved cost/profit balance for each
## input: original data for total amounts, full test data set for customer IDs, machine learning data for train and test
##        number of trees to train with, from, to and step increments for threshold, cost to retain as decimal, cost to aquire
## output: prints status for each threhsold iteration, returns list of best threshold and best balance
ml_optimiseRandomForestProfit<-function(orig_data,all_test_data,ml_test_data,model,minThresh,threshSteps,retainCost,aquireCost) {
  print("Optimising Random Forest probability threshold for maximum profits...")
  # best thresholds
  best_thresh<-0
  highest_bal<-(-1000000)
  
  # loop through sequence to determine best threshold parameter for model
  thresholdSteps<-seq(minThresh,1,threshSteps)
  for (i in 1:length(thresholdSteps)) {
    test_thresh<-thresholdSteps[i]
    # and convert to classes based on test threshold
    # predict probabilities and classes on test data
    rf_tst_predict<-predict(model,ml_test_data[,-grep("IsRoof", colnames(ml_test_data))],type="prob")
    rf_tst_predict_class<-eval_probToClass(rf_tst_predict,test_thresh)
    
    # merge full test data set with predictions and customer IDs and costs
    test_predict<-cbind(ml_test_data,rf_tst_predict_class)
    colnames(test_predict)[ncol(test_predict)]<-"predictIsRoof"
    rf_all_test_data<-cbind(all_test_data[,grep("ImageSegmentID", colnames(all_test_data))],test_predict)
    colnames(rf_all_test_data)[1]<-"ImageSegmentID"
    rf_all_data<-eval_addTotalCostsToDataset(rf_all_test_data,orig_data)
    
    # Calculate Profit/Loss info and update highest bal/best thresh as required
    res<-eval_profitLossFull(rf_all_data[,ncol(rf_all_data)-1],rf_all_data[,ncol(rf_all_data)],rf_all_data[,grep("ORIGTotalCharges", colnames(rf_all_data))],retainCost,aquireCost,"Test Data")
    
    balance<-round((res$TPbal+res$FPbal+res$TNbal+res$FNbal),0)
    custCount<-(res$TPcount+res$FPcount+res$TNcount+res$FNcount)
    custContacted<-(res$TPcount+res$FPcount)
    
    if (balance > highest_bal) {
      best_thresh<-test_thresh
      highest_bal<-balance
    }
  }
  # return list of best thresholds for model and the model object
  returnList<- list(
    "best_thresh" = best_thresh,
    "highest_bal" = highest_bal
  )
  return(returnList)
}
