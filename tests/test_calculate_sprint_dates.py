"""
This file contains the test cases for the function calculate_sprint_dates
"""

from datetime import date, timedelta
from main import calculate_sprint_dates


def test_calculate_sprint_dates():
    """
    This test function tests the calculate_sprint_dates function
    """
    year = 2023
    expected = {
        1: {"start": date(year, 1, 1), "end": date(year, 1, 1) + timedelta(days=100)},
        2: {"start": date(year, 5, 1), "end": date(year, 5, 1) + timedelta(days=100)},
        3: {"start": date(year, 9, 1), "end": date(year, 9, 1) + timedelta(days=100)},
        4: {"start": date(year + 1, 1, 1)},
    }
    assert calculate_sprint_dates(year) == expected
