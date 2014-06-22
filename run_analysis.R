# This R script does the following:
## 1. Merges the training and the test sets to create one data set.
## 2. Extracts only the measurements on the mean and standard deviation for each measurement.
## 3. Uses descriptive activity names to name the activities in the data set
## 4. Appropriately labels the data set with descriptive activity names.
## 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject.

if (!require("data.table")) {
    install.packages("data.table")
}

if (!require("reshape2")) {
    install.packages("reshape2")
}

require("data.table")
require("reshape2")

# Load: activity Labels
activity_labels <- read.table("./dataset/activity_labels.txt")[,2]

# Load: features' names
feature_names <- read.table("./dataset/features.txt") [,2]  

# Extract only the required columns(mean and std cols) from dataset (mergedDataSet)
extract_features <- grepl("mean|std", feature_names)

# Load: train Data and train Labels
X_train <- read.table("./dataset/train/X_train.txt")
y_train <- read.table("./dataset/train/y_train.txt")
subject_train <- read.table("./dataset/train/subject_train.txt")

names(X_train) = feature_names

# Extract only the measurements on the mean and std for each measurement
X_train = X_train[,extract_features]

# Replace the activity id in y_train (training labels) by its matching activity name in activity_labels
y_train[,2] = activity_labels[y_train[,1]]
names(y_train) = c("Activity_ID", "Activity_Name")
names(subject_train)= "subject"

# Bind data
train_data <- cbind(as.data.table(subject_train), y_train, X_train)

# Load: test Data and test Labels
X_test <- read.table("./dataset/test/X_test.txt")
y_test <- read.table("./dataset/test/y_test.txt")
subject_test <- read.table("./dataset/test/subject_test.txt")

names(X_test) = feature_names

# Extract only the measurements on the mean and std for each measurement
X_test = X_test[,extract_features]

# Replace the activity id in y_train (training labels) by its matching activity name in activity_labels
y_test[,2] = activity_labels[y_test[,1]]
names(y_test) = c("Activity_ID", "Activity_Name")
names(subject_test)= "subject"

# Bind data
test_data <- cbind(as.data.table(subject_test), y_test, X_test)

# Merge test and train data
merged_data = rbind(test_data, train_data)


# molten data: each row will represent one observation of one variable 
id_labels = c("subject", "Activity_ID", "Activity_Name")
data_labels = setdiff(colnames(merged_data), id_labels)
# melt function of the R package reshape2
melt_data = melt(merged_data, id=id_labels, measure.vars = data_labels, na.rm=TRUE)

# Creates a second, independent tidy data set with the average of each variable
# for each activity and each subject.
# Apply the mean function using dcast function
# We can reshape a molten data into a data frame using dcast function
# Note: ~ variable gives us the mean of all variables in data frame (melt_data)
# grouped by the vairables specified before the ~
tidy_data = dcast(melt_data, formula = subject + Activity_Name ~ variable, mean)

write.table(tidy_data, file="./tidy_data.txt")

