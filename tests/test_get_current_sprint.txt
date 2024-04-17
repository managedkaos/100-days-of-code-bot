import pytest
from datetime import date, timedelta
from main import calculate_sprint_dates, get_current_sprint

def test_get_current_sprint():
    sprints = calculate_sprint_dates(2023)
    assert get_current_sprint(sprints, date(2023, 1, 10)) == (1, timedelta(days=10), timedelta(days=90))
    assert get_current_sprint(sprints, date(2023, 4, 11)) == (None, None, None)
