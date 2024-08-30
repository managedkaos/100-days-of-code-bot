"""
This test script simulates a full year of running the main.py script, by calling the prepare_and_update_topic function
"""

import os
from datetime import date, timedelta
from main import get_topic


def test_full_year_simulation():
    """
    This test function simulates a full year of running the main.py script, by calling the prepare_and_update_topic function
    """
    year = int(os.getenv("TEST_YEAR", "2024"))

    results = []

    print()

    for day in (date(year, 1, 1) + timedelta(n) for n in range(365)):
        topic = get_topic(day)
        results.append((day, topic))
        print(f"Day: {day}, Topic: {topic}")  # Print each day's result

    assert len(results) > 0  # Ensure that we have at least some results

    print("\nTotal Days Covered:", len(results))
