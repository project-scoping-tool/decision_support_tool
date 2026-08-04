"""
Regenerate Clark and Washoe pedestrian crash-density shapefiles for 2019-2024.

Inputs expected in the same directory:
    crashes_pedestrian_19_24.csv
    CLARK_Pedestrian_Crash_Density.zip
    WASHOE_Pedestrian_Crash_Density.zip

Outputs:
    CLARK_Pedestrian_Crash_Density_2019_2024.zip
    WASHOE_Pedestrian_Crash_Density_2019_2024.zip

Method:
    1. Reuse the original density polygons.
    2. Treat X/Y crash coordinates as NAD83(2011) / UTM Zone 11N.
    3. Count pedestrian crashes within one mile of each polygon centroid.
    4. Recalculate density using the normalization inferred from the original
       layers: density = crash_count * 0.307920143566149.
    5. Preserve the original layer schema and geometry.

Requirements:
    pip install pandas geopandas pyogrio
"""

from pathlib import Path
import shutil
import zipfile

import geopandas as gpd
import pandas as pd


BASE_DIR = Path(__file__).resolve().parent
WORK_DIR = BASE_DIR / "pedestrian_density_regeneration_work"

PEDESTRIAN_CSV = BASE_DIR / "crashes_pedestrian_19_24.csv"

INPUT_ZIPS = {
    "CLARK": BASE_DIR / "CLARK_Pedestrian_Crash_Density.zip",
    "WASHOE": BASE_DIR / "WASHOE_Pedestrian_Crash_Density.zip",
}

DENSITY_PER_CRASH = 0.307920143566149
SEARCH_RADIUS_METERS = 1609.344
ANALYSIS_CRS = "EPSG:26911"


def load_points(csv_path: Path) -> gpd.GeoDataFrame:
    """Load pedestrian crash records and create point geometry from X/Y."""

    if not csv_path.exists():
        raise FileNotFoundError(f"Input CSV not found: {csv_path}")

    df = pd.read_csv(csv_path, low_memory=False)

    for field in ("X", "Y"):
        if field not in df.columns:
            raise ValueError(
                f"Missing required coordinate field '{field}' in {csv_path.name}."
            )

        df[field] = pd.to_numeric(df[field], errors="coerce")

    invalid_count = int(df[["X", "Y"]].isna().any(axis=1).sum())

    df = df.dropna(subset=["X", "Y"]).copy()

    points = gpd.GeoDataFrame(
        df,
        geometry=gpd.points_from_xy(df["X"], df["Y"]),
        crs=ANALYSIS_CRS,
    )

    print(
        f"{csv_path.name}: {len(points):,} valid pedestrian crash points; "
        f"{invalid_count:,} invalid-coordinate rows removed."
    )

    return points


def find_shapefile(extract_dir: Path, source_zip: Path) -> Path:
    """
    Find the source shapefile.

    Uses rglob so the ZIP may contain its shapefile directly or inside a folder.
    """

    shapefiles = list(extract_dir.rglob("*.shp"))

    if len(shapefiles) != 1:
        raise ValueError(
            f"Expected exactly one .shp file in {source_zip.name}; "
            f"found {len(shapefiles)}."
        )

    return shapefiles[0]


def regenerate_density(
    source_zip: Path,
    output_name: str,
    points: gpd.GeoDataFrame,
) -> Path:
    """Recalculate pedestrian crash density for an existing polygon layer."""

    if not source_zip.exists():
        raise FileNotFoundError(f"Source density ZIP not found: {source_zip}")

    extract_dir = WORK_DIR / f"{output_name}_source"
    output_dir = WORK_DIR / output_name

    shutil.rmtree(extract_dir, ignore_errors=True)
    shutil.rmtree(output_dir, ignore_errors=True)

    extract_dir.mkdir(parents=True)
    output_dir.mkdir(parents=True)

    with zipfile.ZipFile(source_zip, "r") as archive:
        archive.extractall(extract_dir)

    source_shp = find_shapefile(extract_dir, source_zip)

    original = gpd.read_file(source_shp)

    if original.crs is None:
        raise ValueError(
            f"The source layer in {source_zip.name} does not have a defined CRS."
        )

    if original.empty:
        raise ValueError(
            f"The source layer in {source_zip.name} contains no polygons."
        )

    projected = original.to_crs(ANALYSIS_CRS)

    if not projected.geometry.geom_type.isin(
        ["Polygon", "MultiPolygon"]
    ).all():
        raise ValueError(
            f"The source layer in {source_zip.name} contains non-polygon geometry."
        )

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

    # Preserve the original schema while replacing the existing density values.
    updated["density"] = (
        counts.to_numpy(dtype=float) * DENSITY_PER_CRASH
    )

    output_shp = output_dir / f"{output_name}.shp"

    updated.to_file(
        output_shp,
        driver="ESRI Shapefile",
        encoding="UTF-8",
        engine="pyogrio",
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

    maximum_density = (
        float(updated["density"].max()) if len(updated) else 0.0
    )

    print(f"\nCreated {output_zip.name}")
    print(f"  Polygons: {len(updated):,}")
    print(
        "  Neighborhood pedestrian crash-count total: "
        f"{int(counts.sum()):,}"
    )
    print(f"  Maximum density: {maximum_density:.6f}")

    return output_zip


def main() -> None:
    """Create updated Clark and Washoe pedestrian density ZIP files."""

    shutil.rmtree(WORK_DIR, ignore_errors=True)
    WORK_DIR.mkdir(parents=True)

    pedestrian_points = load_points(PEDESTRIAN_CSV)

    generated_files = []

    for region, source_zip in INPUT_ZIPS.items():
        output_zip = regenerate_density(
            source_zip=source_zip,
            output_name=(
                f"{region}_Pedestrian_Crash_Density_2019_2024"
            ),
            points=pedestrian_points,
        )

        generated_files.append(output_zip)

    print("\nPedestrian crash-density regeneration completed.")

    for output_zip in generated_files:
        print(f"  {output_zip}")


if __name__ == "__main__":
    main()