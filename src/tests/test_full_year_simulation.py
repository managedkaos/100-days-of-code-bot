"""
Test functions for the main.py script
"""

import os
from datetime import date, timedelta

from main import get_topic


def test_full_year_simulation():
    """
    This test function simulates a full year of running the main.py script
    by calling the prepare_and_update_topic function
    """
    year = int(os.getenv("TEST_YEAR", "2025"))

    results = []

    print()

    for day in (date(year, 1, 1) + timedelta(n) for n in range(365)):
        topic = get_topic(day)
        results.append((day, topic))
        print(f"Day: {day}, Topic: {topic}")  # Print each day's result

    assert len(results) > 0  # Ensure that we have at least some results

    print("\nTotal Days Covered:", len(results))


def test_random_days():
    """
    This test function simulates a few random days of running the main.py
    script, by calling the prepare_and_update_topic function
    """
    test_values = {
        date(2024, 4, 8): "2024-04-08 - Sprint 1: Day 99 (1 days remaining)",
        date(
            2024, 4, 23
        ): "2024-04-23 - No sprint in progress. Next sprint starts in 8 days",
        date(2024, 5, 5): "2024-05-05 - Sprint 2: Day 5 (95 days remaining)",
    }

    for test_day, expected_topic in test_values.items():
        topic = get_topic(test_day)
        print(f"\n\tExpected:\t{expected_topic}\n\tActual: \t{topic}")
        assert topic == expected_topic
