import zipfile
from pathlib import Path
import geopandas as gpd

input_zip = Path("2024 BikePed Crash Data.zip")
extract_folder = Path("extracted_2024_bikeped")

# 1. Extract ZIP
with zipfile.ZipFile(input_zip, "r") as zip_ref:
    zip_ref.extractall(extract_folder)

# 2. Find the .gdb folder
gdb_list = list(extract_folder.rglob("*.gdb"))

if not gdb_list:
    raise FileNotFoundError("No .gdb folder found inside the ZIP file.")

gdb_path = gdb_list[0]
print("Found geodatabase:", gdb_path)

# 3. Read the feature layer
gdf = gpd.read_file(gdb_path, layer="BikePedCrashData")

print("Original CRS:", gdf.crs)
print("Number of records:", len(gdf))

# 4. Convert from UTM Zone 11N to WGS84
gdf = gdf.to_crs("EPSG:4326")

# 5. Create Longitude and Latitude fields
gdf["Longitude"] = gdf.geometry.x
gdf["Latitude"] = gdf.geometry.y

# 6. Export CSV for ArcGIS Online
df = gdf.drop(columns="geometry")
df.to_csv("2024_BikePed_Crash_Data_ArcGISOnline.csv", index=False)

print("Done.")
print("Output file: 2024_BikePed_Crash_Data_ArcGISOnline.csv")