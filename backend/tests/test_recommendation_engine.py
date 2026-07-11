import pytest

from app.services.recommendation_engine import (
    UnsupportedBrewerError,
    convert_grind_setting,
    get_recommendation,
)


def test_v60_baseline():
    rec = get_recommendation(
        origin="Colombia", process="washed", roast_level="medium", brewer="v60", grinder=None
    )
    params = rec["parameters"]
    assert params["dose_g"] == 15.0
    assert params["ratio"] == "1:16"
    assert params["yield_g"] == 240.0
    assert params["water_temp_c"] == 93.0
    assert params["grind_setting_c40_clicks"] == 24
    assert params["brew_time_seconds"] == {"min": 180, "max": 210}
    assert rec["generated_by"] == "rules"
    assert rec["confidence_score"] == 0.9


def test_espresso_baseline_has_pressure():
    rec = get_recommendation(
        origin="Brazil", process="natural", roast_level="dark", brewer="espresso", grinder=None
    )
    params = rec["parameters"]
    assert params["pressure_bar"] == 9
    assert params["dose_g"] == 18.0
    assert params["ratio"] == "1:2"


def test_french_press_baseline():
    rec = get_recommendation(
        origin=None, process="washed", roast_level="medium", brewer="French Press", grinder=None
    )
    params = rec["parameters"]
    assert params["dose_g"] == 30.0
    assert params["water_temp_c"] == 95.0
    assert params["ratio"] == "1:15"


def test_light_roast_hotter_and_finer():
    base = get_recommendation(None, "washed", "medium", "v60", None)["parameters"]
    light = get_recommendation(None, "washed", "light", "v60", None)["parameters"]
    assert light["water_temp_c"] > base["water_temp_c"]
    assert light["grind_setting_c40_clicks"] < base["grind_setting_c40_clicks"]
    assert 93 <= light["water_temp_c"] <= 96


def test_dark_roast_cooler_and_coarser():
    base = get_recommendation(None, "washed", "medium", "v60", None)["parameters"]
    dark = get_recommendation(None, "washed", "dark", "v60", None)["parameters"]
    assert dark["water_temp_c"] < base["water_temp_c"]
    assert dark["grind_setting_c40_clicks"] > base["grind_setting_c40_clicks"]


def test_natural_coarser_than_washed():
    washed = get_recommendation(None, "washed", "light", "v60", None)["parameters"]
    natural = get_recommendation(None, "natural", "light", "v60", None)["parameters"]
    assert natural["grind_setting_c40_clicks"] == washed["grind_setting_c40_clicks"] + 2


def test_espresso_temp_clamped():
    rec = get_recommendation(None, "washed", "light", "espresso", None)
    assert rec["parameters"]["water_temp_c"] <= 96.0


def test_unknown_fields_lower_confidence():
    full = get_recommendation("Kenya", "washed", "light", "v60", "comandante_c40")
    sparse = get_recommendation(None, None, None, "v60", None)
    assert sparse["confidence_score"] < full["confidence_score"]


def test_unsupported_brewer_raises():
    with pytest.raises(UnsupportedBrewerError):
        get_recommendation(None, None, None, "moka_pot", None)


def test_grinder_conversion_c40_identity():
    grind = convert_grind_setting(24, "Comandante C40")
    assert grind["converted"] is True
    assert grind["value"] == 24


def test_grinder_conversion_scales():
    grind = convert_grind_setting(24, "1zpresso_jx_pro")
    assert grind["converted"] is True
    assert grind["value"] == 72


def test_unknown_grinder_falls_back_to_c40():
    grind = convert_grind_setting(24, "some_random_grinder")
    assert grind["converted"] is False
    assert grind["value"] == 24
    assert grind["unit"] == "clicks"
