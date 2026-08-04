from pathlib import Path
import pandas as pd
from pyproj import Transformer

# Input files (change these paths if your filenames are different)
BICYCLIST_2019_2023 = Path("crashes_bicyclist.csv")
PEDESTRIAN_2019_2023 = Path("crashes_pedestrian.csv")
BIKEPED_2024 = Path("2024_BikePed_Crash_Data_ArcGISOnline.csv")

# Output files
BICYCLIST_OUTPUT = Path("crashes_bicyclist_19_24.csv")
PEDESTRIAN_OUTPUT = Path("crashes_pedestrian_19_24.csv")

OUTPUT_COLUMNS = [
    "CrashNum",
    "Street1",
    "Street1Other",
    "Street1Located",
    "Street2",
    "Street2Other",
    "Street2Located",
    "CrashDate",
    "CrashTime",
    "City",
    "County",
    "CountyLocated",
    "X",
    "Y",
]


def normalize_text(series: pd.Series) -> pd.Series:
    """Normalize text only for comparison; original values remain unchanged."""
    return series.fillna("").astype(str).str.strip().str.upper()


def prepare_2024(df: pd.DataFrame) -> pd.DataFrame:
    """Convert the 2024 data to the same schema as the 2019-2023 files."""
    df = df.copy()

    # Convert WGS84 longitude/latitude to NAD83(2011) / UTM Zone 11N.
    # This matches the coordinate style used by the existing crash CSV files.
    if "X" not in df.columns or "Y" not in df.columns:
        required = {"Longitude", "Latitude"}
        missing = required.difference(df.columns)
        if missing:
            raise ValueError(
                "The 2024 file must contain X/Y or Longitude/Latitude. "
                f"Missing: {sorted(missing)}"
            )

        transformer = Transformer.from_crs("EPSG:4326", "EPSG:26911", always_xy=True)
        valid = df["Longitude"].notna() & df["Latitude"].notna()
        df["X"] = pd.NA
        df["Y"] = pd.NA
        x, y = transformer.transform(
            df.loc[valid, "Longitude"].astype(float).to_numpy(),
            df.loc[valid, "Latitude"].astype(float).to_numpy(),
        )
        df.loc[valid, "X"] = x
        df.loc[valid, "Y"] = y
        df["X"] = pd.to_numeric(df["X"], errors="coerce")
        df["Y"] = pd.to_numeric(df["Y"], errors="coerce")

    # Make dates consistent with the earlier files: YYYY-MM-DDT00:00:00.000
    parsed_dates = pd.to_datetime(df["CrashDate"], errors="coerce", utc=True)
    df["CrashDate"] = parsed_dates.dt.strftime("%Y-%m-%dT00:00:00.000")

    # Existing files store time as HHMM integers.
    df["CrashTime"] = pd.to_numeric(df["CrashTime"], errors="coerce").round().astype("Int64")

    # Ensure all expected columns exist.
    for column in OUTPUT_COLUMNS:
        if column not in df.columns:
            df[column] = pd.NA

    return df


def append_and_clean(old_df: pd.DataFrame, new_df: pd.DataFrame) -> pd.DataFrame:
    """Append 2024 rows, preserve schema, and remove duplicate crash numbers."""
    combined = pd.concat(
        [old_df.reindex(columns=OUTPUT_COLUMNS), new_df.reindex(columns=OUTPUT_COLUMNS)],
        ignore_index=True,
    )

    # Normalize county text to match the earlier processing workflow.
    for column in ["County", "CountyLocated"]:
        combined[column] = combined[column].astype("string").str.upper()

    # Prefer the newest appended record if a CrashNum occurs more than once.
    combined = combined.drop_duplicates(subset="CrashNum", keep="last")
    return combined


def main() -> None:
    bicyclist_old = pd.read_csv(BICYCLIST_2019_2023, low_memory=False)
    pedestrian_old = pd.read_csv(PEDESTRIAN_2019_2023, low_memory=False)
    data_2024 = pd.read_csv(BIKEPED_2024, low_memory=False)

    data_2024 = prepare_2024(data_2024)

    harmful_event = normalize_text(data_2024["FirstHarmfulEventDesc"])
    pedestrian_flag = normalize_text(data_2024["PedestrianInvolved"])

    # Bicyclist crashes: the 2024 crash record identifies Pedal Cyclist.
    bicyclist_2024 = data_2024.loc[harmful_event.eq("PEDAL CYCLIST")].copy()

    # Pedestrian crashes: marked PedestrianInvolved=YES, excluding records
    # explicitly identified as Pedal Cyclist so the two outputs stay separate.
    pedestrian_2024 = data_2024.loc[
        pedestrian_flag.eq("YES") & ~harmful_event.eq("PEDAL CYCLIST")
    ].copy()

    bicyclist_all = append_and_clean(bicyclist_old, bicyclist_2024)
    pedestrian_all = append_and_clean(pedestrian_old, pedestrian_2024)

    bicyclist_all.to_csv(BICYCLIST_OUTPUT, index=False)
    pedestrian_all.to_csv(PEDESTRIAN_OUTPUT, index=False)

    print(f"2019-2023 bicyclist rows: {len(bicyclist_old):,}")
    print(f"2024 bicyclist rows added: {len(bicyclist_2024):,}")
    print(f"Combined bicyclist rows: {len(bicyclist_all):,}")
    print(f"Output: {BICYCLIST_OUTPUT.resolve()}")
    print()
    print(f"2019-2023 pedestrian rows: {len(pedestrian_old):,}")
    print(f"2024 pedestrian rows added: {len(pedestrian_2024):,}")
    print(f"Combined pedestrian rows: {len(pedestrian_all):,}")
    print(f"Output: {PEDESTRIAN_OUTPUT.resolve()}")


if __name__ == "__main__":
    main()