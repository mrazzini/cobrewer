"""Rule-based recommendation engine.

Input: bean (origin, process, roast_level) + equipment (brewer, grinder)
Output: grind_setting_clicks, dose_g, ratio, water_temp_c, brew_time_range

Grind settings normalised to Comandante C40 clicks, then converted per grinder model.
"""

from typing import Any


class UnsupportedBrewerError(ValueError):
    """Raised when no rules exist for the requested brewer."""


# Base parameters per brewer, grind expressed in Comandante C40 clicks.
BREWER_BASE_PARAMS: dict[str, dict[str, Any]] = {
    "espresso": {
        "grind_c40_clicks": 10,
        "dose_g": 18.0,
        "ratio": 2.0,  # 1:2, adjustable up to 1:2.5
        "water_temp_c": 93.0,
        "brew_time_seconds": {"min": 25, "max": 30},
        "pressure_bar": 9,
    },
    "v60": {
        "grind_c40_clicks": 24,
        "dose_g": 15.0,
        "ratio": 16.0,
        "water_temp_c": 93.0,
        "brew_time_seconds": {"min": 180, "max": 210},
    },
    "french_press": {
        "grind_c40_clicks": 30,
        "dose_g": 30.0,
        "ratio": 15.0,
        "water_temp_c": 95.0,
        "brew_time_seconds": {"min": 240, "max": 240},
    },
}

BREWER_ALIASES: dict[str, str] = {
    "espresso": "espresso",
    "espresso_machine": "espresso",
    "v60": "v60",
    "hario_v60": "v60",
    "pour_over": "v60",
    "pourover": "v60",
    "french_press": "french_press",
    "frenchpress": "french_press",
    "press": "french_press",
}

# Conversion from Comandante C40 clicks (industry reference) to other grinders.
# converted_setting = round(c40_clicks * factor + offset)
GRINDER_CONVERSIONS: dict[str, dict[str, Any]] = {
    "comandante_c40": {"label": "Comandante C40", "factor": 1.0, "offset": 0.0, "unit": "clicks"},
    "1zpresso_jx": {"label": "1Zpresso JX", "factor": 1.2, "offset": 0.0, "unit": "clicks"},
    "1zpresso_jx_pro": {"label": "1Zpresso JX-Pro", "factor": 3.0, "offset": 0.0, "unit": "clicks"},
    "1zpresso_k_plus": {"label": "1Zpresso K-Plus", "factor": 3.0, "offset": 0.0, "unit": "clicks"},
    "timemore_c2": {"label": "Timemore C2", "factor": 0.75, "offset": 0.0, "unit": "clicks"},
    "timemore_c3": {"label": "Timemore C3", "factor": 0.75, "offset": 0.0, "unit": "clicks"},
    "baratza_encore": {"label": "Baratza Encore", "factor": 0.9, "offset": 0.0, "unit": "setting"},
    "baratza_virtuoso": {
        "label": "Baratza Virtuoso+",
        "factor": 0.9,
        "offset": 0.0,
        "unit": "setting",
    },
    "fellow_ode_gen2": {
        "label": "Fellow Ode Gen 2",
        "factor": 0.28,
        "offset": 0.0,
        "unit": "setting",
    },
    "niche_zero": {"label": "Niche Zero", "factor": 1.6, "offset": 0.0, "unit": "setting"},
    "wilfa_uniform": {"label": "Wilfa Uniform", "factor": 1.3, "offset": 0.0, "unit": "setting"},
    "hario_skerton": {"label": "Hario Skerton", "factor": 0.4, "offset": 0.0, "unit": "clicks"},
}

ROAST_LEVEL_ALIASES: dict[str, str] = {
    "light": "light",
    "medium_light": "medium_light",
    "medium": "medium",
    "medium_dark": "medium_dark",
    "dark": "dark",
}

# (grind click delta, water temp delta °C) relative to the brewer baseline.
ROAST_ADJUSTMENTS: dict[str, tuple[int, float]] = {
    "light": (-2, +2.5),
    "medium_light": (-1, +1.5),
    "medium": (0, 0.0),
    "medium_dark": (+1, -1.5),
    "dark": (+2, -3.0),
}

# Grind click delta relative to washed process at the same roast level.
PROCESS_ADJUSTMENTS: dict[str, int] = {
    "washed": 0,
    "natural": +2,
    "honey": +1,
    "anaerobic": +1,
    "wet_hulled": +1,
}

# Water temperature bounds by brewer keep adjustments inside sane brewing ranges.
TEMP_BOUNDS: dict[str, tuple[float, float]] = {
    "espresso": (90.0, 96.0),
    "v60": (88.0, 96.0),
    "french_press": (90.0, 96.0),
}

MIN_C40_CLICKS = 5


def _normalize(value: str | None) -> str | None:
    if value is None:
        return None
    return value.strip().lower().replace(" ", "_").replace("-", "_")


def normalize_brewer(brewer: str) -> str:
    key = _normalize(brewer)
    if key is None or key not in BREWER_ALIASES:
        supported = ", ".join(sorted(BREWER_BASE_PARAMS))
        raise UnsupportedBrewerError(f"Unsupported brewer '{brewer}'. Supported: {supported}")
    return BREWER_ALIASES[key]


def convert_grind_setting(c40_clicks: int, grinder: str | None) -> dict[str, Any]:
    """Convert a Comandante C40 click count to the target grinder's scale."""
    key = _normalize(grinder)
    if key is None or key not in GRINDER_CONVERSIONS:
        return {
            "grinder": grinder,
            "value": c40_clicks,
            "unit": "clicks",
            "reference": "comandante_c40",
            "converted": False,
        }
    conv = GRINDER_CONVERSIONS[key]
    return {
        "grinder": conv["label"],
        "value": round(c40_clicks * conv["factor"] + conv["offset"]),
        "unit": conv["unit"],
        "reference": "comandante_c40",
        "converted": True,
    }


def get_recommendation(
    origin: str | None,
    process: str | None,
    roast_level: str | None,
    brewer: str,
    grinder: str | None,
) -> dict[str, Any]:
    brewer_key = normalize_brewer(brewer)
    base = BREWER_BASE_PARAMS[brewer_key]

    clicks = int(base["grind_c40_clicks"])
    temp = float(base["water_temp_c"])
    notes: list[str] = []
    confidence = 0.9

    roast_key = ROAST_LEVEL_ALIASES.get(_normalize(roast_level) or "")
    if roast_key is not None:
        click_delta, temp_delta = ROAST_ADJUSTMENTS[roast_key]
        clicks += click_delta
        temp += temp_delta
        if click_delta or temp_delta:
            notes.append(
                f"{roast_key.replace('_', '-')} roast: "
                f"{click_delta:+d} C40 clicks, {temp_delta:+.1f}°C"
            )
    else:
        confidence -= 0.15
        notes.append("Roast level unknown — using brewer baseline")

    process_key = _normalize(process)
    if process_key in PROCESS_ADJUSTMENTS:
        process_delta = PROCESS_ADJUSTMENTS[process_key]
        clicks += process_delta
        if process_delta:
            notes.append(f"{process_key.replace('_', ' ')} process: {process_delta:+d} C40 clicks")
    else:
        confidence -= 0.1
        notes.append("Process unknown — assuming washed")

    if origin is None or not origin.strip():
        confidence -= 0.05

    low, high = TEMP_BOUNDS[brewer_key]
    temp = min(max(temp, low), high)
    clicks = max(clicks, MIN_C40_CLICKS)

    grind = convert_grind_setting(clicks, grinder)
    if not grind["converted"] and grinder:
        confidence -= 0.1
        notes.append("Grinder not in conversion table — setting given in Comandante C40 clicks")

    dose = float(base["dose_g"])
    ratio = float(base["ratio"])
    parameters: dict[str, Any] = {
        "brewer": brewer_key,
        "grind_setting": grind,
        "grind_setting_c40_clicks": clicks,
        "dose_g": dose,
        "ratio": f"1:{ratio:g}",
        "yield_g": round(dose * ratio, 1),
        "water_temp_c": round(temp, 1),
        "brew_time_seconds": dict(base["brew_time_seconds"]),
        "notes": notes,
    }
    if "pressure_bar" in base:
        parameters["pressure_bar"] = base["pressure_bar"]

    return {
        "parameters": parameters,
        "confidence_score": round(max(confidence, 0.1), 2),
        "generated_by": "rules",
    }
