# NLSY-Income-Prediction-and-Depression-Classification

This was a final project for a course I took in the spring of 2023. I have included the introduction and conclusion in this README as well as the analysis and models that I authored. The rest of the project can be found in the full report.

## Introduction
 Our dataset, The National Longitudinal Survey of Youth (NLSY97), is a large dataset of 8,984 participants born between
 1980 and 1984. The survey first took place in 1997 where all participants were living in the United States, then interviews
 were held annually from 1997 until 2020. Survey participants were allowed to “skip” certain questions, and this is denoted
 for each question. There is data on mental health, employment, substance use, familial status, and education history. These
 answers are both numeric and categorical.
 Our two primary response variables that we are trying to predict with our model are depression and income. There are
 quite a few questions in the survey relating to depression but we decided to focus on one in particular. It asks the
 respondent to respond to the statement “I felt depressed” with four response options. We decided to engineer this variable
 into a binary response variable. We encoded no as a 0 and yes as a 1 for depression. Also, we decided to predict the
 incomes of respondents for our continuous variable. The question in the survey asks “TOTAL INCOME FROM WAGES
 ANDSALARYINPASTCALENDARYEAR.”
 Due to the fact that respondents were able to skip certain questions we had to impute or remove rows with these skips. We
 decided to set most skips to NA. For the “Valid Skips” we decided to either impute these to a zero or NA depending on the
 variable where we thought it made sense. After doing these imputations we then kept only complete cases of data and it
 reduced the number of observations from 8,984 to 4,280. Additionally, because we had so many categorical variables we
 decided to one hot encode them. In order to avoid the dummy variable trap due to the multicollinearity of the categories
 within each categorical variable, we included m-1 categories for our models (given m categories.) The left out category
 can then be considered the reference value. Predictor Variables are listed in the code appendix.

## Research Questions
 In this project we decided to address two main questions. First we examined the relationship between a number of
 predictors, such as employment, education, household & demographics and symptoms of depression (with classification
 with levels 0 and 1). Second, we addressed the relationship between respondent related predictors such as employment,
 education, household & demographics related factors and the income (continuous) of the respondents.

 ## EDA
![EDA](https://github.com/Owenp25/NLSY-Income-Prediction-and-Depression-Classification/assets/77632947/0b5caed7-1167-4089-b4d8-ccb06029ff8d)

Found major underrepresentation of respondents categorized as having symptoms of depression. To address the minority class, SMOTE (Systematic Minority Oversampling Technique) was used. 
This function created synthetic observations based on k nearest neighbors within the minority class. Based on current literature, the optimal choice is to balance the minority and majority classes evenly so this was the goal.

## Analyzing Effect of SMOTE on the data

![Smote vs original](https://github.com/Owenp25/NLSY-Income-Prediction-and-Depression-Classification/assets/77632947/8d517abe-16a0-4dee-a55d-4a78034fa8ff)

As can be seen here, SMOTE created synthetic observations proportionate to the original data in terms of the amount of people categorized as depressed. The change in response counts with SMOTE can be seen in the two images below. 

Original Depression Response Counts:
![table original dep](https://github.com/Owenp25/NLSY-Income-Prediction-and-Depression-Classification/assets/77632947/bbea277f-cbd2-4de0-b1a4-01a750be8ba0)

SMOTE Depression Response Counts:
![smote data balance](https://github.com/Owenp25/NLSY-Income-Prediction-and-Depression-Classification/assets/77632947/ebb3a58f-97ca-43f3-bac4-acdc852bfb1d)

## Depression Classification
 1. Logistic Regression (lasso/ridge)

 Initially a model predicting depression using all 49 predictor variables (once one hot encoded) was trained and tested but
 this model only returned one true positive prediction correctly. This is due to there being only 71 people labeled as
 depressed, which is what we want to predict, versus 4209 people labeled as not depressed. Two problems needed to be
 addressed: the extreme minority class of respondents labeled as depressed (5-7 days in the past week) and the abundance
 of unnecessary predictor variables. As mentioned before, SMOTE was used to deal with the minority class. To deal with
 the abundance of predictors, LASSO regression was implemented. This returned coefficients for the most important
 variables and set the other predictor variable’s coefficients to zero (Figure 1). Combining these two techniques, a final
 logistic regression model was built with the subset of important predictors and a balanced sampling of depressed and
 non-depressed individuals (1846 and 1863, respectively.) This model performed quite well as will be discussed later on.

![LASSO](https://github.com/Owenp25/NLSY-Income-Prediction-and-Depression-Classification/assets/77632947/89f89194-4bee-4061-94f3-6e1ea1152d34)

Figure 1.

 The logistic regression model using SMOTE had a final accuracy of 78.77% and a recall of 72.73% which were computed
 from the decision matrix in Figure 2. We care about recall because this is the proportion of respondents truly labeled as
 depressed that we successfully predicted to be depressed. Further evaluating this model, McFadden’s Pseudo R-Squared
 was calculated. This value is 0.37 which shows that the model is an excellent fit (lower values are expected for
 McFadden’s R-squared.) The most important features in this model were not being employed in 2019, being injured 4 or
 more times in the past year, and household size were the most important variables in this model. Despite this performance,
 it is vital to realize that overfitting could be present since there were so many synthetic minority observations generated
 (about 1800.)
 
![CM_LOGREG](https://github.com/Owenp25/NLSY-Income-Prediction-and-Depression-Classification/assets/77632947/a58c1a51-1a43-47ff-9697-e9bdb66fc575)

Figure 2. 


2. Naive Bayes Classifier

 Naive Bayes classifier was relatively accurate with an accuracy score of 72.31%. However, as shown by the confusion
 matrix in Figure 4, there was a high number of false negatives. This means that out of all actual people with symptoms of
 depression, we are not predicting enough people to have symptoms of depression.

![Naive bayes CM](https://github.com/Owenp25/NLSY-Income-Prediction-and-Depression-Classification/assets/77632947/734fc23d-2c09-4969-a297-bdb7e82630a2)

Figure 4.

3. Random Forest Classifier

The final random forest classification model had an extremely high accuracy of 96.34% and a recall of 93.33%. This was
 trained and tested on the SMOTE data and was our best performing model, however with such a high accuracy this model
 may be very prone to overfitting. Household size, being injured 4 times in the past year, and weight were the most
 important variables in this model for predicting depression (figure 3.)

![VarImpPlotRF](https://github.com/Owenp25/NLSY-Income-Prediction-and-Depression-Classification/assets/77632947/937871b4-db5a-4c8c-97b8-0ffe26b68203)

FIgure 3.

## Income Prediction

These parts were completed by group members and are included in the full report.

## Conclusion
 Depression:
 The naive bayes model performed fairly well in terms of accuracy, but did not perform well in terms of recall as it yielded
 a high number of false negatives. This suggests the Naive Bayes model is not ideal for interpretation of feature
 importances and predictions. The best performing model was the random forest model with above 90% accuracy. The
 baseline random forest with no smote did not correctly predict any people with depression correctly so this jump up in
 accuracy must be taken with a grain of salt (due to overfitting.) The logistic regression model also performed well but not
 to the same standard. Overall, it appears that household size, not being employed, being injured frequently, and weight
 seem to be the most significant variables for predicting depression.
 
 Income:
 All models predicting income were assessed in terms of root mean squared error (RMSE). With regards to the four linear
 models performed, the best performing model was lasso regression with a RMSE of $44,815.46. The most important
predictors in all four models were heavily related to highest degree received. With regards to the boosting and random
 forest models, there were unfortunately no well performing models. The Random Forest model was the best performing
 model overall with a RMSE of $44782.52. However, there were still valuable findings such as what variables are most
 relevant to the responses. Given our models’ poor performance, one should be cautious gleaning any solid insights from
 variable importance plots; however it may be telling that both the boosting and random forest models selected marital
 status, highest degree received, and weeks worked as the most influential variables. These are not surprises, as one would
 expect income to rise with education level and typically the more one works the more they earn. Additionally, marriage
 status could potentially be explained by people having to earn more to have an established family and marriage

Attached are files with my portion of the R code, the final presentation slides, and the final report that I helped write.
