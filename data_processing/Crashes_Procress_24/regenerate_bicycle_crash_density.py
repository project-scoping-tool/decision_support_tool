"""
Regenerate Clark and Washoe bicycle crash-density shapefiles for 2019-2024.

Inputs expected in the same directory:
    crashes_bicyclist_19_24.csv
    CLARK_Bicycle_Crash_Density.zip
    WASHOE_Bicycle_Crash_Density.zip

Outputs:
    CLARK_Bicycle_Crash_Density_2019_2024.zip
    WASHOE_Bicycle_Crash_Density_2019_2024.zip

Method:
    1. Reuse the original density polygons.
    2. Treat X/Y crash coordinates as NAD83(2011) / UTM Zone 11N.
    3. Count bicyclist crashes within one mile of each polygon centroid.
    4. Recalculate density using the normalization inferred from the original
       layers: density = crash_count * 0.307920143566149.
    5. Preserve the original layer schema and geometry.

Requirements:
    pip install pandas geopandas pyogrio
"""

from pathlib import Path
import shutil
import zipfile
import pandas as pd
import geopandas as gpd

BASE_DIR = Path(__file__).resolve().parent
WORK_DIR = BASE_DIR / "density_regeneration_work"

BICYCLE_CSV = BASE_DIR / "crashes_bicyclist_19_24.csv"
INPUT_ZIPS = {
    "CLARK": BASE_DIR / "CLARK_Bicycle_Crash_Density.zip",
    "WASHOE": BASE_DIR / "WASHOE_Bicycle_Crash_Density.zip",
}

DENSITY_PER_CRASH = 0.307920143566149
SEARCH_RADIUS_METERS = 1609.344
ANALYSIS_CRS = "EPSG:26911"


def load_points(csv_path: Path) -> gpd.GeoDataFrame:
    if not csv_path.exists():
        raise FileNotFoundError(f"Input CSV not found: {csv_path}")

    df = pd.read_csv(csv_path, low_memory=False)

    for field in ("X", "Y"):
        if field not in df.columns:
            raise ValueError(f"Missing required coordinate field: {field}")
        df[field] = pd.to_numeric(df[field], errors="coerce")

    invalid_count = int(df[["X", "Y"]].isna().any(axis=1).sum())
    df = df.dropna(subset=["X", "Y"]).copy()

    points = gpd.GeoDataFrame(
        df,
        geometry=gpd.points_from_xy(df["X"], df["Y"]),
        crs=ANALYSIS_CRS,
    )

    print(
        f"{csv_path.name}: {len(points):,} valid crash points; "
        f"{invalid_count:,} invalid-coordinate rows removed."
    )
    return points


def regenerate_density(
    source_zip: Path,
    output_name: str,
    points: gpd.GeoDataFrame,
) -> Path:
    if not source_zip.exists():
        raise FileNotFoundError(f"Source density ZIP not found: {source_zip}")

    extract_dir = WORK_DIR / f"{output_name}_source"
    output_dir = WORK_DIR / output_name

    shutil.rmtree(extract_dir, ignore_errors=True)
    shutil.rmtree(output_dir, ignore_errors=True)
    extract_dir.mkdir(parents=True)
    output_dir.mkdir(parents=True)

    with zipfile.ZipFile(source_zip) as archive:
        archive.extractall(extract_dir)

    shapefiles = list(extract_dir.glob("*.shp"))
    if len(shapefiles) != 1:
        raise ValueError(
            f"Expected exactly one .shp file in {source_zip.name}; "
            f"found {len(shapefiles)}."
        )

    original = gpd.read_file(shapefiles[0])
    projected = original.to_crs(ANALYSIS_CRS)

    search_areas = gpd.GeoDataFrame(
        {"polygon_index": projected.index},
        geometry=projected.geometry.centroid.buffer(SEARCH_RADIUS_METERS),
        crs=ANALYSIS_CRS,
    )

    joined = gpd.sjoin(
        search_areas,
        points[["geometry"]],
        how="left",
        predicate="contains",
    )

    counts = (
        joined.groupby("polygon_index")["index_right"]
        .count()
        .reindex(projected.index, fill_value=0)
        .astype(int)
    )

    updated = original.copy()
    updated["density"] = counts.to_numpy(dtype=float) * DENSITY_PER_CRASH

    output_shp = output_dir / f"{output_name}.shp"
    updated.to_file(
        output_shp,
        driver="ESRI Shapefile",
        encoding="UTF-8",
    )

    output_zip = BASE_DIR / f"{output_name}.zip"
    if output_zip.exists():
        output_zip.unlink()

    with zipfile.ZipFile(
        output_zip,
        "w",
        compression=zipfile.ZIP_DEFLATED,
    ) as archive:
        for component in sorted(output_dir.iterdir()):
            archive.write(component, arcname=component.name)

    print(f"Created {output_zip.name}")
    print(f"  Polygons: {len(updated):,}")
    print(f"  Neighborhood crash-count total: {int(counts.sum()):,}")
    print(f"  Maximum density: {updated['density'].max():.6f}")

    return output_zip


def main() -> None:
    shutil.rmtree(WORK_DIR, ignore_errors=True)
    WORK_DIR.mkdir(parents=True)

    bicycle_points = load_points(BICYCLE_CSV)

    for region, source_zip in INPUT_ZIPS.items():
        regenerate_density(
            source_zip=source_zip,
            output_name=f"{region}_Bicycle_Crash_Density_2019_2024",
            points=bicycle_points,
        )


if __name__ == "__main__":
    main()