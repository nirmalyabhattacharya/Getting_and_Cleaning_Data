# Getting and Cleaning Data  

## Codebook
This is a Codebook that describes the different variables used in the R program _"run_analysis.R"_ and also describes the data, and any transformations or work that were performed to clean up the data.


***
## The Data

### Human Activity Recognition Using Smartphones Dataset        
###### _Version 1.0_  

L. Reyes-Ortiz, Davide Anguita, Alessandro Ghio, Luca Oneto.  
Smartlab - Non Linear Complex Systems Laboratory  
DITEN - Universit‡ degli Studi di Genova.  
Via Opera Pia 11A, I-16145, Genoa, Italy.  
[activityrecognition@smartlab.ws](mailto:activityrecognition@smartlab.ws)  
[www.smartlab.ws](http://www.smartlab.ws)  



The experiments have been carried out with a group of 30 volunteers within an age bracket of 19-48 years. Each person performed six activities (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING) wearing a smartphone (Samsung Galaxy S II) on the waist. Using its embedded accelerometer and gyroscope, we captured 3-axial linear acceleration and 3-axial angular velocity at a constant rate of 50Hz. The experiments have been video-recorded to label the data manually. The obtained dataset has been randomly partitioned into two sets, where 70% of the volunteers was selected for generating the training data and 30% the test data. 

The sensor signals (accelerometer and gyroscope) were pre-processed by applying noise filters and then sampled in fixed-width sliding windows of 2.56 sec and 50% overlap (128 readings/window). The sensor acceleration signal, which has gravitational and body motion components, was separated using a Butterworth low-pass filter into body acceleration and gravity. The gravitational force is assumed to have only low frequency components, therefore a filter with 0.3 Hz cutoff frequency was used. From each window, a vector of features was obtained by calculating variables from the time and frequency domain. See 'features_info.txt' for more details. 

For each record it is provided:

- Triaxial acceleration from the accelerometer (total acceleration) and the estimated body acceleration.
- Triaxial Angular velocity from the gyroscope. 
- A 561-feature vector with time and frequency domain variables. 
- Its activity label. 
- An identifier of the subject who carried out the experiment.

The dataset includes the following files:


- **'README.txt'**

- **'features_info.txt'**: Shows information about the variables used on the feature vector.

- **'features.txt'**: List of all features.

- **'activity_labels.txt'**: Links the class labels with their activity name.

- **'train/X_train.txt'**: Training set.

- **'train/y_train.txt'**: Training labels.

- **'test/X_test.txt'**: Test set.

- **'test/y_test.txt'**: Test labels.

The following files are available for the train and test data. Their descriptions are equivalent. 

- **'train/subject_train.txt'**: Each row identifies the subject who performed the activity for each window sample. Its range is from 1 to 30. 

- **'train/Inertial Signals/total_acc_x_train.txt'**: The acceleration signal from the smartphone accelerometer X axis in standard gravity units 'g'. Every row shows a 128 element vector. The same description applies for the 'total_acc_x_train.txt' and 'total_acc_z_train.txt' files for the Y and Z axis. 

- **'train/Inertial Signals/body_acc_x_train.txt'**: The body acceleration signal obtained by subtracting the gravity from the total acceleration. 

- **'train/Inertial Signals/body_gyro_x_train.txt'**: The angular velocity vector measured by the gyroscope for each window sample. The units are radians/second. 

##### Notes: 

- Features are normalized and bounded within [-1,1].
- Each feature vector is a row on the text file.

For more information about this dataset contact: [activityrecognition@smartlab.ws](mailto:activityrecognition@smartlab.ws)

***

## Processing the Data

#### Pre-requisites:
1.  Downloaded the zipped dataset manually from the [location](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip), unzip it and save the datafiles in a folder named _"UCI HAR Dataset"_ in your local workspace.
2.  Copy the R program file _"run_analysis.R"_ in the same folder where the folder _"UCI HAR Dataset"_ from Step 1 was created.
3.  Ensure that you have the packages **_"data.table"_** and **_"reshape2"_** installed.  

#### Walkthrough of the code:  

####### The following code ensures that the working directoiry is set to the current working directory.  
```{r}
# Change the current working directory to the directory this script is  
thisdir<-getSrcDirectory(function(x) {x}) #Anonymous function to get the source directory. The anonymous function is dummy.

setwd(file.path(thisdir))

```

####### The following code reads the data from the relevant text files (the _test_ data files are read first and the same procedure would be repeted for the _train_ data files as well) and extracts the columns that are _useful_ to us. 
```{r}

# Read the relevant columns in the text files

activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt")[,2]
features <- read.table("./UCI HAR Dataset/features.txt")[,2]

features_mean_sd<-grepl("mean|std", features) # Look for Mean and Standard Deviation only

# Read the test tables and process them
X_test <- read.table("./UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")
names(X_test) = features


X_test = X_test[,features_mean_sd]


y_test[,2] = activity_labels[y_test[,1]]
names(y_test) = c("Activity_ID", "Activity_Label")
names(subject_test) = "Subject_ID"


test_data <- cbind(as.data.table(subject_test), y_test, X_test)
```
####### Repeat the above procedure for the _train_ data.  

```{r}
# Read the train tables and process them

X_train <- read.table("./UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./UCI HAR Dataset/train/y_train.txt")

subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")

names(X_train) = features


X_train = X_train[,features_mean_sd]


y_train[,2] = activity_labels[y_train[,1]]
names(y_train) = c("Activity_ID", "Activity_Label")
names(subject_train) = "Subject_ID"


train_data <- cbind(as.data.table(subject_train), y_train, X_train)
```
####### Combine the the _test_ and the _train_ data.   

```{r}

#Combine the test and train data into one

combined = rbind(test_data, train_data)
```

####### Set column headers for the combined dataset.  
```{r}
id_labels   = c("Subject_ID", "Activity_ID", "Activity_Label")
data_labels = setdiff(colnames(combined), id_labels)
```

####### _**"Melt"**_ the combined data into long format.  
```{r}
melted_data = melt(combined, id = id_labels, measure.vars = data_labels)
```
####### _**"Cast"**_ the combined data into wide format and also apply the mean function. Store the resulting data into the data frame _"tidy_dataset"_. This data frame is the final tidy data.   
```{r}
# Apply mean function to dataset using dcast function
tidy_dataset   = dcast(melted_data, Subject_ID+Activity_ID+Activity_Label ~ variable, mean)
```
####### Write the table into a new text file with the name _**"Independent_Tidy_Dataset.txt"**_.  
```{r}
write.table(tidy_dataset, file = "./Independent_Tidy_Dataset.txt",sep ="\t",row.names=FALSE)
```