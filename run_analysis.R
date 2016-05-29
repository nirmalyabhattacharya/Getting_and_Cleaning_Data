#______________________________________________________________________________________________________________________________________

#   You should create one R script called run_analysis.R that does the following.

#   1. Merges the training and the test sets to create one data set.
#   2. Extracts only the measurements on the mean and standard deviation for each measurement.
#   3. Uses descriptive activity names to name the activities in the data set
#   4. Appropriately labels the data set with descriptive variable names.
#   5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

#______________________________________________________________________________________________________________________________________

suppressMessages(require("data.table"))
suppressMessages(require("reshape2"))


# Change the current working directory to the directory this script is  
thisdir<-getSrcDirectory(function(x) {x}) #Anonymous function to get the source directory. The anonymous function is dummy.

setwd(file.path(thisdir))


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



#Combine the test and train data into one

combined = rbind(test_data, train_data)


id_labels   = c("Subject_ID", "Activity_ID", "Activity_Label")
data_labels = setdiff(colnames(combined), id_labels)
melted_data = melt(combined, id = id_labels, measure.vars = data_labels)

# Apply mean function to dataset using dcast function
tidy_dataset   = dcast(melted_data, Subject_ID+Activity_ID+Activity_Label ~ variable, mean)

write.table(tidy_dataset, file = "./Independent_Tidy_Dataset.txt",sep ="\t",row.names=FALSE)


