# Utility function which returns full data (subject, activity and features) for either
# the training or test category
# ASSUMPTION: The script is being executed within the 'UCI HAR Dataset' folder,
# and has the features.txt, activity_labels.txt, etc, files in the root of the
# current working dir
get_data <- function(category) {
  # Read the subject information (Nx1 table, where N is the number of observations)
  dat_sub <- read.table(
    file.path(category, paste("Subject_", category, ".txt", sep = "")), header = FALSE)
  # Read the feature data (NxM table, where M is the number of variables being measured)
  dat_X <- read.table(
    file.path(category, paste("X_", category, ".txt", sep = "")), header = FALSE)
  # Read the activity information (Nx1) table
  dat_y <- read.table(
    file.path(category, paste("y_", category, ".txt", sep = "")), header = FALSE)
  # Return a column-bind of the above tables (note that column-bind works here since
  # all the tables have N rows). The result is a Nx(M+2) table, with the first two
  # columns corresponding to the subject and activity and the remaining M columns
  # representing the variables being measured.
  cbind(dat_sub, dat_y, dat_X)
}

## ASSIGNMENT STEP 1: MERGE TRAINING AND TEST DATA-SETS

# Get the traning and test data-sets using the utility function above
train <- get_data("train")
test <- get_data("test")
# Do a row-bind on the training and test data-sets to get the merged data-sets
# Note that row-bind works here since the two data-sets each have M+2 columns,
# where M is the number of variables being measured.
mrg <- rbind(train, test)
rm("train")
rm("test")

## ASSIGNMENT STEP 2: EXTRACT ONLY THE MEAN AND STD DEVIATION MEASUREMENTS

# Read the mapping of the numeric activity ID to activity name
ac_lab <- read.table("activity_labels.txt", header = FALSE)
# Read the mapping of the feature number to feature name.
# The feature number here corresponds to the number of a column in
# X_train.txt/X_test.txt
feat_lab <- read.table("features.txt", header = FALSE)

# Extract the names of the features being mesured, which is simply the
# 2nd column of the feat_lab table above
feat_names <- feat_lab[, 2]
# Count the number of features being measured (which we call M henceforth)
nfeat <- length(feat_names)
# Within the feature name vector, find the indices of those features which
# correspond to a mean or standard deviation measurement. NOTE: as per features_info.txt,
# these feature names look like 'mean()' or 'std()', so that is the pattern we're
# grepping for here.
ms_idx <- grep("mean\\(\\)|std\\(\\)", feat_names)
# Count the number of mean/std dev features (which we call MSD henceforth)
nfeat_ms <- length(ms_idx)
# Extract the names of the features correspoding to mean/std dev measurements,
# and make these names more human-readable using R's make.names function
feat_ms_names <- make.names(feat_names[ms_idx])

# Subset the full merged data-set to retain only the subject and activity info
# (columns 1 and 2) and the mean/std dev features (whose indices can be computed by
# adding 2 to each index in the md_idx index vector computed above, given the structure
# of our merged data-set)
mrg_ms <- mrg[, c(1, 2, ms_idx + 2)]
rm("mrg")

## ASSIGNMENT STEP 3: USE DESCRIPTIVE ACTIVITY NAMES TO NAME THE ACTIVITES IN THE
## FILTERED DATA SET

# Use sapply to replace the numeric activity IDs in the filtered data-set with
# more descriptive activity names. Note that the name for activity ID n is
# simply given by the n'th row and 2nd column of the ac_lab table created above.
mrg_ms[, 2] <- sapply(mrg_ms[, 2], function (x) ac_lab[x, 2])

## ASSIGNMENT STEP 4: LABEL THE DATA-SET WITH DESCRIPTIVE VARIABLE NAMES

# Assign more descriptive names to the columns of the filtered data set.
# The first two columns are labelled 'subject' and 'activity' since that's
# what they correspond to, and the remaining columns are simply labelled based
# on the names in the feat_ms_names vector computed previously
names(mrg_ms) <- c("subject", "activity", feat_ms_names)

## ASSIGNMENT STEP 5: CREATE A NEW TIDY DATA-SET WITH THE AVERAGE OF EACH
## VARIABLE FOR EACH ACTIVITY AND EACH SUBJECT

# Split the filtered data-set into a list of smaller data-sets which are grouped
# by subject and activity
spl <- split(mrg_ms, list(mrg_ms$activity, mrg_ms$subject))
# Use lapply to compact each grouped data-set into a single row with first column = subject,
# second column = activity, and each subsequent column = the average of
# the corresponding column in the grouped data-set. Note that unique(x[1]) and
# unique(x[2]) will each return single values since subject and activity are grouping
# factors for the grouped data-sets.
spl_av <- lapply(spl, function (x) data.frame(
  c(unique(x[1]), unique(x[2]), colMeans(x[3:(nfeat_ms+2)]))))
# Row-bind the list of rows obtained above into a single data-frame which is our
# final result.
# Note that the resulting tidy data-set follows the WIDE FORMAT (one row for each
# subject-activity combination, a separate column for each measurement)
df_av <- do.call(rbind, spl_av)
# Just to make things more explicit, prefix the names of the measurement columns
# with 'average.' to indicate that these are AVERAGES of the original measurements.
names(df_av) <- c("subject", "activity", paste("average.", feat_ms_names, sep=""))

# Write the output tidy data-set to file
write.table(df_av, file="result.txt", row.name=FALSE)