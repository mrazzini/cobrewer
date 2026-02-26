"""Rule-based recommendation engine.

Input: bean (origin, process, roast_level) + equipment (brewer, grinder)
Output: grind_setting_clicks, dose_g, ratio, water_temp_c, brew_time_range

Grind settings normalised to Comandante C40 clicks, then converted per grinder model.
"""

from typing import Any


def get_recommendation(
    origin: str | None,
    process: str | None,
    roast_level: str | None,
    brewer: str,
    grinder: str | None,
) -> dict[str, Any]:
    # TODO: implement rule-based logic from CLAUDE.md
    raise NotImplementedError
