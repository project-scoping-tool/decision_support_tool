
# Crash Data Processing

This directory contains data-processing-related files for The [Infrastructure for Healthy Living Project Scoping Tool (PST)](https://pst.rtcsnv.com/intro/). This processes the public 2019-2023 Nevada crash data, provided by the Nevada Department of Transportation (NDOT).

Here is the link to request crash data: https://survey123.arcgis.com/share/2361c89935aa497183387106ec46e18d

This README will cover the files in this directory, overview of the data, and the process used to extract pedestrian crash data and bicyclist crash data from the dataset. The goal of this README is to give future maintainers an idea of how to process the crash data in a reproducible manner.

## Files Overview

The following are the main files of the directory:

- **5 YR 2019-2023 STATEWIDE CRASH DATA.xlsx**: 2019-2023 crash data provided by NDOT.
- **crashes_bicyclist.csv**, **crashes_pedestrian.csv**: Bicyclist and pedestrian crash data produced by *process.ipynb*
- **process.ipynb**: Jupyter notebook used to process and extract the pedestrian and bicyclist crash data.
- **README.md**: This file.

There are also other miscellaneous files as well:

- **scratch.ipynb**: Jupyter notebook used for some scratch work.
- **sheet_crashes.parquet**, **sheet_persons.parquet**: File for the crashes and persons involved tables; acts like a cache for faster loading. If this file is not present, then *process.ipynb* loads from *5 YR 2019-2023 STATEWIDE CRASH DATA.xlsx* instead and regenerates both files.

## Data Overview

The data in *5 YR 2019-2023 STATEWIDE CRASH DATA.xlsx* is an Excel file containing three tables. Each table has a key, but there may be rows with duplicate key values (called duplicate rows). Here are the three tables:

- **2019-2023 STATEWIDE**: Here referred to as the "crashes table". Each row contains information about a single crash.
  - Key: `CrashNum`
  - `X` and `Y` give the coordinates
- **PERSONS INVOLVED**: Each row is about a person involved in a crash. `CrashNum` identifies which crash the row is associated with, and `pplNo` identifies the person.
  - Key: `CrashNum` and `pplNo`
- **VEHICLES INVOLVED**: Each row is about a vehicle involved in a crash. `CrashNum` identifies which crash the row is associated with. This table is not used in *process.ipynb*.
  - Key: `CrashNum` and `vcNo`

## Processing Overview

The process to produce **crashes_bicyclist.csv** and **crashes_pedestrian.csv** is divided into two main parts: Preprocessing and extraction.

### Preprocessing Part

For the crashes table, I took the following two preprocessing steps:

* Remove completely identical duplicate rows.
* Remove rows with duplicate `CrashNum` where `SecondaryCrash` is null.
  * The rows with less nulls had `SecondaryCrash` columns which were null.
* Convert the `County` column to uppercase.

For the persons involved table, I took the following preprocessing steps.

* Remove completely identical duplicate rows
* Remove rows manually; rows with more nulls were removed.
  * One pair of rows had an equal number of nulls, but there was one different column (`'APPARENTLY NORMAL;'` vs. `'Apparently Normal'`). I just chose one of them.

### Extraction Part

After the preprocessing step, I produced the pedestrian crash data through a filter. *Either* one of three conditions have to be true:

1. The `PedestrianInvolved` value equals `'YES'`
2. Persons involved includes `'Pedestrian'`
3. Persons involved includes `'Wheelchair'`

Condition 2 was added because a few rows with `PedestrianInvolved='NO'` still had persons marked as `'Pedestrian'`, and Condition 3 was added so that persons marked as `'Wheelchair'` were not excluded (most were excluded.)

For the bicylist crash data, I used a filter that checked one condition:

* Persons involved includes `'Pedal Cyclist'`.

Afterward, the extracted data is written to *crashes_bicyclist.csv* and *crashes_pedestrian.csv*.

It should be noted that the coordinate system that may be used (based off of appearance) is `NAD_1983_2011_UTM_Zone_11N` in ArcGIS. The points should land on roads on the map.
