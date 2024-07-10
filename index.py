"""
This script updates the topic of a Slack channel with the current sprint information.
"""

from datetime import date, timedelta
import os
import requests


def calculate_sprint_dates(year):
    """
    Returns a dictionary with the start and end dates for each sprint in the year.
    """
    length = timedelta(days=100)
    return {
        1: {"start": date(year, 1, 1), "end": date(year, 1, 1) + length},
        2: {"start": date(year, 5, 1), "end": date(year, 5, 1) + length},
        3: {"start": date(year, 9, 1), "end": date(year, 9, 1) + length},
        4: {
            "start": date(year + 1, 1, 1)
        },  # Only start date for the next year's first sprint
    }


def get_current_sprint(sprints, today):
    """
    Returns the current sprint number, the number of days since the sprint started,
    """
    for sprint_number, sprint_dates in sprints.items():
        start, end = sprint_dates["start"], sprint_dates.get("end", date.max)

        # To fix the 101 bug, use `<` instead of `<=` :)
        if start <= today <= end:
            return (
                sprint_number,
                today - start + timedelta(days=1),
                end - today - timedelta(days=1),
            )
    return None, None, None


def set_slack_channel_topic(topic):
    """
    Sets the topic of the Slack channel.
    """

    # Check the SKIP_SLACK varible to be present and set to any non-empty value
    # If there is no need to interact with Slack, just return the topic
    if os.getenv("SKIP_SLACK") and os.getenv("SKIP_SLACK") != "":
        print("Slack: skipped")
        return {
            "ok": True,
            "channel": {
                "topic": {"value": topic},
            },
        }

    url = "https://slack.com/api/conversations.setTopic"
    token = os.getenv("SLACK_AUTH_TOKEN")
    channel = os.getenv("SLACK_CHANNEL_ID")
    headers = {"Authorization": f"Bearer {token}"}
    payload = {"channel": channel, "topic": topic}

    response = requests.post(url, headers=headers, data=payload, timeout=10)

    print(f"Slack: {response.text}")

    return response.text


def prepare_and_update_topic(today):
    """
    Prepares the topic message and updates the Slack channel topic.
    """
    sprints = calculate_sprint_dates(today.year)
    sprint_number, current_day, days_remaining = get_current_sprint(sprints, today)

    if sprint_number:
        topic = f"{today} - Sprint {sprint_number}: Day {current_day.days} ({days_remaining.days} days remaining)"
    else:
        for i in range(1, 4):
            if sprints[i]["end"] <= today < sprints[i + 1]["start"]:
                days_until_next_sprint = (sprints[i + 1]["start"] - today).days
                topic = f"{today} - No sprint in progress. Next sprint starts in {days_until_next_sprint} days"
                break

    print(f"Topic: {topic}")

    response = set_slack_channel_topic(topic)

    return response


def handler(event, context):
    """
    AWS Lambda handler function.
    """
    del event, context  # Unused

    today = date.today()

    print(f"Date: {today}")

    response = prepare_and_update_topic(today)

    print(response)

    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json",
        },
        "body": response,
    }


if __name__ == "__main__":
    handler(None, None)
