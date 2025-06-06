# ������������� ��������� k-������


#
# ��������� ��� ���������� ��� ���������� �� ���� ����������� ������ (Root Mean Squared Error 
# - RMSE) 
# predictedValues: �������� �� ����� ��� ����������� ���������� ��� ��������� �� ������� 
#                  �������������
# actualValues: �������� �� ��� ����������� ����� ��� ����������� ��-��������
# ���������� �� ���� ����������� ������ ���������
calculateRMSE<-function(predictedValues, actualValues){
  err<- sqrt( mean((actualValues - predictedValues)^2)  )
  return( err )
}


# ��������� ��� �������� ��� ��������� ��� ������������� ���������� k-������.
# � ��������� ����� ����� ��� ����� ������������ ��������� (RMSE) �� ������� ���������.
# ���������� ����������:
# data: �� ������ ��������� ��� �� �������� �� ������� �������� �� �����������
# frml: �� �������� ������� ������������� ��� �� ����������� � ����-���� ��������� ���
# k: � ���� k ��� �������������� ���������� k-������ ��� ������� �� ���� ������� �� �����������
#    �� ������ ������ ���������
# ������������� ����:
# � ��������� ���������� ��� ���� ��� ��� ����� ������������ ���������
kFoldCrossValidation<-function(data, frml, k){
  # ������ ���������� ��� ������������ ��� ������� ���������
  dataset<-data[sample(nrow(data)),]
  #���������� k �� ������ �������� ��� ������� ��������� �� ������� ��� ������ 
  # ������������ �� ���� �����.
  folds <- cut(seq(1,nrow(dataset)), breaks=k, labels=FALSE)
  # �������� ���� ������������ �� ���� ��
  RMSE<-vector()
  # ������������� ���������� ���� ���� ��� ��� �� k ������� �� �����-��������� ���������
  # �� ������ ������� ��� �� ������� ������������� ��� ��� �� �������� �� ������ �����������. 
  # � ���������� �� ���������� ��� ��� �� ������� ����� �������������� �� ������ �������.
  for(i in 1:k){
    # ���������� ��� �������� ������� ��� ��� �������� ��������� 
    testIndexes <- which(folds==i,arr.ind=TRUE)
    # ���������� ������� ������� ��������
    testData <- dataset[testIndexes, ]
    # ���������� ������� ����������� ��������, ��� �� ����� ��� �� ��������
    # ���� ��� ��������� ��� ��������������� ��� ������
    trainData <- dataset[-testIndexes, ]
    # �������� ����������� ��� �������� ������������� ��������������� �� ������ �����������
    candidate.linear.model<-lm( frml, data = trainData)
    # ����������� ��� ����� ��� ����������� ���������� ��� ��������� �� ������� 
    # ��� ��� ����� ��� ��������� ������� ������� 
    predicted<-predict(candidate.linear.model, testData)
    # ����������� ��������� RMSE
    error<-calculateRMSE(predicted, testData[, "mpg"])
    # ���������� ����� ���������
    RMSE<-c(RMSE, error)
  }
  # ��������� ����� ����� ��� ��������� ��� ��������� ��'��� �� �����-�� �������
  return( mean(RMSE) )
}


# �������� ���������
# �� ������ ��������� �������� ������� �������������� ����������� �������� �������������
carData<-read.csv("auto-mpg.csv", sep=";", header=T, stringsAsFactors = F, quote = "\"")


# ������� ��� �������� ��� ������� (missing values) ��� �������� ��������� �������
# �� ��������� ��� ��� ����������� ��������� ���� missing value
carData<-na.omit(carData)

# ������ �� ���������� horsepower ��� mpg ����� missing values, ������ ����� �� 
# ����������� ���� ����� ���� ��������� (numeric), ������ ����� ���������� �� ������������� 
# (character) �������� ��� missing value
carData[,"horsepower"] <- as.numeric(carData[,"horsepower"])
carData[,"mpg"] <- as.numeric(carData[,"mpg"])

# �� ������� �������� ������� ��� ������ �� ����������� � ��������� ��������� ��� ����������� ��������
# (mpg - miles per gallon) �� �� ������ ��� �������������� ���������� 10-�����. 
# �� ������� ������������� ������������� ��� �������� �� ������������� ��� �� �����������
# �� ������ (formula) ��� R

predictionModels<-vector()
predictionModels[1]<-"mpg ~ horsepower+weight"
predictionModels[2]<-"mpg ~ horsepower+acceleration+displacement"
predictionModels[3]<-"mpg ~ horsepower+displacement+weight"

# ����������������� ��� ������� ��� ������� ����������� ��� ������ 2 weight^2. � �������� �������
# ���� ��� ������� ������� �� ����� ��� ���������� I() ��� ����� � ��������� Inhibit Interpretation ���
# ���� ��� ���������� �� ��� ���������� � �������� ^ ��� ������� ��� �����.
# ���� ����� � �������� ^ ���� ����� ������� ��� ������ ��� �� �����-���������� �� �������� ����� ��
# ����� ��� I() ��� �� ���������� �� � �������� ����� �� ������.
predictionModels[4]<-"mpg ~ horsepower+displacement+weight + I(weight^2)"

# ���� ��� ���� ������������� ���������, � ����� ���� ��� ����� �����-������� 
# ��������� ���� �������� �� ����������� �� ��������.
modelMeanRMSE<-vector()

# ������������� ��������� 10-����� ��� ���� ��� ��� �� 
# ������� �������� �������.
for (k in 1:length(predictionModels)){
  # ������������ ��������� 10-������ ��� �� �������� ������� �����-�������� k
  modelErr<-kFoldCrossValidation(carData, as.formula(predictionModels[k]), 10)
  # ���������� ��� ����� ���������
  modelMeanRMSE<-c(modelMeanRMSE, modelErr)
  print( sprintf("Linear regression model [%s]: prediction error [%f]", predictionModels[k], modelErr ) )
}



# ���� ������� ���� �� ���������� ���� ����������� ������;
bestModelIndex<-which( modelMeanRMSE == min(modelMeanRMSE) )
# �������� �������� �� �� ��������� ���� ����������� ����� ������ �� ���������� ��������

print( sprintf("Model with best accuracy was: [%s] error: [%f]", predictionModels[bestModelIndex], modelMeanRMSE[bestModelIndex]) )

# ��� �� ������� �� �� ���������� ���� ������, ���������� �� �������-���� ��� 
# ����������� ����� �������� �� ������ ��������� �� ������ �����������
final.linear.model<-lm( as.formula(predictionModels[bestModelIndex]), data=carData )
