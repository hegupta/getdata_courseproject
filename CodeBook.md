## Overview

This code book attempts to provide a brief overview of the structure of the tidy data-set generated as output for the Getting and Cleaning Data course-project. The data-set is a transformation of the raw Samsung Human Activity Recognition data, where features corresponding to mean and standard deviation measurements are first extracted from the raw data, then grouped by subject and activity, and finally averaged. The final data-set is thus a representation of the average mean and standard deviation measurements for every subject and activity combination in the raw data.

## High-level structure

The tidy data-set follows a wide format, with the average of each mean and standard deviation measurement in a separate column. The data-set has as many rows as there are subject-activity combinations, which is 180 in the case of the Samsung data (30 subjects x 6 activities). The data-set also has 68 columns, with 2 columns containing the subject and activity for which averages are being taken, and each of the remaining 66 columns corresponding to the average of a specific measurement for the current subject-activity combination.

## Column details

The following is a brief overview of the columns in the tidy data-set:

### Column 1
The first column ("subject") contains the subject information, which is simply an *integer* identifying a specific unnamed subject.

### Column 2
The second column ("activity") contains the activity information, which is a human-readable activity-description *string* such as WALKING, LAYING, etc.

### Columns 3-68
Each column in columns 3-68 has a name of the form "average.*xxx*", and contains the *numeric* averages of values for measurement *xxx* grouped by the different subject-activity combinations. *xxx* corresponds to a mean or standard deviation measurement in the original data (e.g. "tBodyAcc.mean...X" corresponds to measurement "tBodyAcc-mean()-X" in the Samsung data). The mapping between the names of measurement columns in the tidy data-set and the names in the original data is 1-1 and fairly intuitive, since the former were obtained by simply running the latter through make.names() in order to obtain a slightly more human-readable representation.
The units of the measurement columns in the tidy data-set are also the same as the units of the corresponding measurements in the original Samsung data. For more details around these measurements and their units, see http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones