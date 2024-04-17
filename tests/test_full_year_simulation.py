import pytest
from datetime import date, timedelta
from unittest.mock import patch
from main import prepare_and_update_topic

def test_full_year_simulation():
    year = 2023
    results = []
    for day in (date(year, 1, 1) + timedelta(n) for n in range(365)):
        with patch('main.set_slack_channel_topic') as mock_topic:
            prepare_and_update_topic(day)
            if mock_topic.call_args:
                results.append((day, mock_topic.call_args[0][0]))
    assert len(results) > 0  # Basic check to ensure we have outputs
