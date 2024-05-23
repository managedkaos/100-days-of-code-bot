import pytest
from datetime import date, timedelta
from unittest.mock import patch
from main import prepare_and_update_topic
import os

def test_full_year_simulation():
    year = int(os.getenv('TEST_YEAR', '2023'))
    results = []
    print()
    for day in (date(year, 1, 1) + timedelta(n) for n in range(365)):
        with patch('main.set_slack_channel_topic') as mock_topic:
            prepare_and_update_topic(day)
            if mock_topic.call_args:
                # Retrieving the first argument passed to set_slack_channel_topic, which is the topic text
                topic_message = mock_topic.call_args[0][0]
                results.append((day, topic_message))
                print(f"Day: {day}, Topic: {topic_message}")  # Print each day's result

    assert len(results) > 0  # Ensure that we have at least some results
    print("\nTotal Days Covered:", len(results))
