# NLSY-Income-Prediction-and-Depression-Classification

This was a final project for a course I took in the spring of 2023. The dataset, The National Longitudinal Survey of Youth (NLSY97), is a large dataset of 8,984 participants born between 1980 and 1984. The survey first took place in 1997 where all participants were living in the United States, then interviews were held annually from 1997 until 2020. Survey participants were allowed to “skip” certain questions, and this is denoted for each question. There is data on mental health, employment, substance use, familial status, and education history. These answers are both numeric and categorical.

## Introduction
In this project we decided to address two main questions. First we examined the relationship between a number of predictors, such as employment, education, household & demographics and symptoms of depression (with classification with levels 0 and 1). Second, we addressed the relationship between respondent related predictors such as employment, education, household & demographics related factors and the income (continuous) of the respondents.

## Depression Classification

## Income Prediction

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
