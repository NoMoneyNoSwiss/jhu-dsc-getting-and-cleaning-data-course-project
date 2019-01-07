require(dplyr)

# read in feature names

measurement_names <- read.csv('features.txt', header = FALSE, sep = '', col.names = c('index', 'columnNames'), stringsAsFactors = FALSE)$columnNames
activity_labels <- read.csv('activity_labels.txt', header = FALSE, sep = '', col.names = c('index', 'activityNames'), stringsAsFactors = FALSE)$activityNames

# find labels with 'mean()' or 'std()' in them, as we will only keep these columns

mean_cols <- grep('mean\\(\\)', measurement_names)
std_cols <- grep('std\\(\\)', measurement_names)
keep_cols <- sort(union(mean_cols, std_cols))

# prepare measurement names for use as column names

measurement_names <- gsub('-', '_', measurement_names)
measurement_names <- gsub('\\(\\)', '', measurement_names)

# load measurement features

train_measurement <- read.csv('train/X_train.txt', header = FALSE, sep = '', col.names = measurement_names) 
test_measurement <- read.csv('test/X_test.txt', header = FALSE, sep = '', col.names = measurement_names)

# keep only columns with means or standard deviations in them

train_measurement <- train_measurement[, keep_cols]
test_measurement <- test_measurement[, keep_cols]

# load activity features

train_activity <- read.csv('train/y_train.txt', header = FALSE, sep = '', col.names = 'activity')
test_activity <- read.csv('test/y_test.txt', header = FALSE, sep = '', col.names = 'activity')

train_activity$activity <- factor(train_activity$activity, labels = activity_labels)
test_activity$activity <- factor(test_activity$activity, labels = activity_labels)

# load subject features

train_subject <- read.csv('train/subject_train.txt', header = FALSE, sep = '', col.names = 'subject')
test_subject <- read.csv('test/subject_test.txt', header = FALSE, sep = '', col.names = 'subject')

# concatenate columns

train_set <- cbind(train_measurement, train_activity, train_subject)
test_set <- cbind(test_measurement, test_activity, test_subject)

# merge training and test sets

merged_set <- rbind(train_set, test_set)

# finally, create analysis set using dplyr

analysis_set <- merged_set %>%
    group_by(activity, subject) %>%
    summarize_all(mean)