"""
This file contains the test cases for the function get_sprint_dates
"""

import os
from datetime import date, timedelta

from main import get_sprint_dates


def test_get_sprint_dates():
    """
    This test function tests the get_sprint_dates function
    """
    year = os.getenv("TEST_YEAR", "2024")

    expected = {
        1: {
            "start": date(int(year), 1, 1),
            "end": date(int(year), 1, 1) + timedelta(days=100),
        },
        2: {
            "start": date(int(year), 5, 1),
            "end": date(int(year), 5, 1) + timedelta(days=100),
        },
        3: {
            "start": date(int(year), 9, 1),
            "end": date(int(year), 9, 1) + timedelta(days=100),
        },
        4: {"start": date(int(year) + 1, 1, 1)},
    }

    print(f"\n## Expected:\n{expected}")
    print(f"\n## Actual:\n{get_sprint_dates(year)}")

    assert get_sprint_dates(year) == expected
