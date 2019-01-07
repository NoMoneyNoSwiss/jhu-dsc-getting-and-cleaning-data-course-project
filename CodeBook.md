# Code book for Getting and Cleaning Data Course Project

We start by loading the `dplyr` package which we will use in the final step.

    require(dplyr)

Next, we want to set the correct names for the measurement columns and replace the activity numbers by their descriptive labels, so we load these into `R` as vectors.

    measurement_names <- read.csv('features.txt', header = FALSE, sep = '', col.names = c('index', 'columnNames'), stringsAsFactors = FALSE)$columnNames
    activity_labels <- read.csv('activity_labels.txt', header = FALSE, sep = '', col.names = c('index', 'activityNames'), stringsAsFactors = FALSE)$activityNames

As the exercise requires us to only keep the mean and standard deviations of the measurements, we find labels with `mean()` or `std()` in them.

    mean_cols <- grep('mean\\(\\)', measurement_names)
    std_cols <- grep('std\\(\\)', measurement_names)
    keep_cols <- sort(union(mean_cols, std_cols))

Finally, we replace special characters in the measurement feature names so that we will have nice column names in our data frame once we import it.

    measurement_names <- gsub('-', '_', measurement_names)
    measurement_names <- gsub('\\(\\)', '', measurement_names)

We can then load the measurement features, and keep only the columns with means and std deviations.

    # load measurement features

    train_measurement <- read.csv('train/X_train.txt', header = FALSE, sep = '', col.names = measurement_names) 
    test_measurement <- read.csv('test/X_test.txt', header = FALSE, sep = '', col.names = measurement_names)

    # keep only columns with means or standard deviations in them

    train_measurement <- train_measurement[, keep_cols]
    test_measurement <- test_measurement[, keep_cols]

Also, we load the activity features in separate data frames and cast the integers into factor variables, where we use the descriptive labels we used earlier.

    # load activity features

    train_activity <- read.csv('train/y_train.txt', header = FALSE, sep = '', col.names = 'activity')
    test_activity <- read.csv('test/y_test.txt', header = FALSE, sep = '', col.names = 'activity')

    train_activity$activity <- factor(train_activity$activity, labels = activity_labels)
    test_activity$activity <- factor(test_activity$activity, labels = activity_labels)

Finally, we also load the subject features, which we will group by in Step 5.

    # load subject features

    train_subject <- read.csv('train/subject_train.txt', header = FALSE, sep = '', col.names = 'subject')
    test_subject <- read.csv('test/subject_test.txt', header = FALSE, sep = '', col.names = 'subject')

We can then concatenate the measurement, activity and subject columns together, and bind the rows of the training and test sets together to form the first tidy data set.

    # concatenate columns

    train_set <- cbind(train_measurement, train_activity, train_subject)
    test_set <- cbind(test_measurement, test_activity, test_subject)

    # merge training and test sets

    merged_set <- rbind(train_set, test_set)

We perform some analysis on this set for every activity and subject by taking the mean, so we create our second data set, which we also write to the working directory.

    # finally, create analysis set using dplyr

    analysis_set <- merged_set %>%
        group_by(activity, subject) %>%
        summarize_all(mean)

    # write analysis set as simple table

    write.table(analysis_set, 'analysis_set.txt', row.name = FALSE)