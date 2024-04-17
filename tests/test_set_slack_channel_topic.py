import pytest
from unittest.mock import patch
from main import set_slack_channel_topic

@patch('main.requests.post')
def test_set_slack_channel_topic(mock_post):
    mock_post.return_value.text = "Success"
    set_slack_channel_topic("Test Topic")
    mock_post.assert_called_once_with(
        "https://slack.com/api/conversations.setTopic",
        headers={'Authorization': 'Bearer None'},
        data={'channel': None, 'topic': "Test Topic"},
        timeout=10
    )
