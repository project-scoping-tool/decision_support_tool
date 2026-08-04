"""
Create separate bicyclist and pedestrian point shapefiles from merged crash CSVs.

Requirements:
    pip install pandas geopandas pyogrio

Input files expected in the same folder as this script:
    crashes_bicyclist_19_24.csv
    crashes_pedestrian_19_24.csv

Outputs:
    crashes_bicyclist_19_24.zip
    crashes_pedestrian_19_24.zip

Coordinate system:
    NAD83(2011) / UTM Zone 11N (EPSG:26911)
"""

from pathlib import Path
import shutil
import zipfile
import pandas as pd
import geopandas as gpd

BASE_DIR = Path(__file__).resolve().parent

INPUTS = {
    "bicyclist": BASE_DIR / "crashes_bicyclist_19_24.csv",
    "pedestrian": BASE_DIR / "crashes_pedestrian_19_24.csv",
}

# Shapefile field names cannot exceed 10 characters.
FIELD_MAP = {
    "CrashNum": "CrashNum",
    "Street1": "Street1",
    "Street1Other": "St1Other",
    "Street1Located": "St1Locate",
    "Street2": "Street2",
    "Street2Other": "St2Other",
    "Street2Located": "St2Locate",
    "CrashDate": "CrashDate",
    "CrashTime": "CrashTime",
    "City": "City",
    "County": "County",
    "CountyLocated": "CntyLocate",
    "X": "X",
    "Y": "Y",
}


def create_shapefile(csv_path: Path, output_name: str) -> None:
    if not csv_path.exists():
        raise FileNotFoundError(f"Input file not found: {csv_path}")

    df = pd.read_csv(csv_path, low_memory=False)

    required_fields = {"X", "Y"}
    missing = required_fields - set(df.columns)
    if missing:
        raise ValueError(
            f"{csv_path.name} is missing required fields: {sorted(missing)}"
        )

    df["X"] = pd.to_numeric(df["X"], errors="coerce")
    df["Y"] = pd.to_numeric(df["Y"], errors="coerce")

    invalid_count = int(df[["X", "Y"]].isna().any(axis=1).sum())
    if invalid_count:
        print(f"{csv_path.name}: removing {invalid_count} rows with invalid coordinates.")

    df = df.dropna(subset=["X", "Y"]).copy()

    if "CrashDate" in df.columns:
        df["CrashDate"] = pd.to_datetime(
            df["CrashDate"], errors="coerce"
        ).dt.date

    available_map = {
        old_name: new_name
        for old_name, new_name in FIELD_MAP.items()
        if old_name in df.columns
    }
    df = df[list(available_map)].rename(columns=available_map)

    geometry = gpd.points_from_xy(df["X"], df["Y"])
    gdf = gpd.GeoDataFrame(
        df,
        geometry=geometry,
        crs="EPSG:26911",
    )

    output_folder = BASE_DIR / output_name
    if output_folder.exists():
        shutil.rmtree(output_folder)
    output_folder.mkdir(parents=True)

    shapefile_path = output_folder / f"{output_name}.shp"
    gdf.to_file(
        shapefile_path,
        driver="ESRI Shapefile",
        encoding="UTF-8",
    )

    zip_path = BASE_DIR / f"{output_name}.zip"
    if zip_path.exists():
        zip_path.unlink()

    with zipfile.ZipFile(
        zip_path,
        "w",
        compression=zipfile.ZIP_DEFLATED,
    ) as archive:
        for component in sorted(output_folder.iterdir()):
            archive.write(component, arcname=component.name)

    print(f"Created: {zip_path.name}")
    print(f"Features: {len(gdf):,}")
    print(f"CRS: {gdf.crs}")


def main() -> None:
    for crash_type, csv_path in INPUTS.items():
        create_shapefile(
            csv_path=csv_path,
            output_name=f"crashes_{crash_type}_19_24",
        )


if __name__ == "__main__":
    main()