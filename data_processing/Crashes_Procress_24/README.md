# Crash Data Merge (2019–2024)

This directory contains a script for merging the existing 2019–2023 pedestrian and bicyclist crash datasets with the processed 2024 crash dataset.

The script produces updated crash datasets covering **2019–2024** while preserving the same schema used by the previous datasets. These files are intended for use in the Infrastructure for Healthy Living Project Scoping Tool (PST) and ArcGIS Online applications.

---

## Files

| File | Description |
|------|-------------|
| `merge_crashes_2019_2024.py` | Python script that merges the existing 2019–2023 crash datasets with the processed 2024 dataset. |
| `crashes_bicyclist.csv` | Existing bicyclist crash dataset (2019–2023). |
| `crashes_pedestrian.csv` | Existing pedestrian crash dataset (2019–2023). |
| `2024_BikePed_Crash_Data_ArcGISOnline.csv` | Processed 2024 crash dataset generated from the official NDOT geodatabase. |
| `crashes_bicyclist_19_24.csv` | Output bicyclist crash dataset (2019–2024). |
| `crashes_pedestrian_19_24.csv` | Output pedestrian crash dataset (2019–2024). |

---

## Requirements

- Python 3.10+
- pandas
- pyproj

Install dependencies if needed:

```bash
pip install pandas pyproj
```

---

## Input Data

The script requires the following input files to be located in the same directory:

```
crashes_bicyclist.csv
crashes_pedestrian.csv
2024_BikePed_Crash_Data_ArcGISOnline.csv
```

The first two files are the existing 2019–2023 datasets. The third file is the processed 2024 crash dataset produced from the official NDOT 2024 crash geodatabase.

---

## Processing Steps

The script performs the following operations:

1. Loads the existing 2019–2023 pedestrian and bicyclist crash datasets.
2. Loads the processed 2024 crash dataset.
3. Converts the 2024 crash coordinates from geographic coordinates (longitude/latitude, WGS84) to **NAD 1983 (2011) UTM Zone 11N (EPSG:26911)** so they match the coordinate system used by the previous datasets.
4. Extracts bicyclist crashes where the first harmful event is **Pedal Cyclist**.
5. Extracts pedestrian crashes where **PedestrianInvolved = YES**.
6. Appends the extracted 2024 records to the corresponding 2019–2023 datasets.
7. Removes duplicate crashes based on `CrashNum`.
8. Preserves the original column order and schema.
9. Writes the merged datasets to new CSV files.

---

## Output Files

After running the script, the following files are generated:

```
crashes_bicyclist_19_24.csv
crashes_pedestrian_19_24.csv
```

These datasets maintain the same structure as the original 2019–2023 files, making them directly compatible with existing ArcGIS Online layers, Experience Builder widgets, and downstream processing workflows.

---

## Running the Script

Execute:

```bash
python merge_crashes_2019_2024.py
```

---

## Notes

- The script does **not** modify the original input files.
- Duplicate crashes are identified using the `CrashNum` field.
- The output datasets preserve the same coordinate system and schema as the existing 2019–2023 crash datasets.
- The 2024 dataset should already be processed into `2024_BikePed_Crash_Data_ArcGISOnline.csv` before running this script.

---

## Workflow

```
2019–2023 Bicyclist CSV  ──┐
                           │
2019–2023 Pedestrian CSV ──┼──► merge_crashes_2019_2024.py
                           │
2024 Processed Crash CSV ──┘
                                   │
                                   ▼
                  ┌─────────────────────────────┐
                  │ crashes_bicyclist_19_24.csv │
                  │ crashes_pedestrian_19_24.csv│
                  └─────────────────────────────┘
```