"""
This script updates the topic of a Slack channel with the current sprint information.
"""

from datetime import date, timedelta
import os
import json
import requests


def get_sprint_dates(year):
    """
    Returns a dictionary with the start and end dates for each sprint in the year.
    Sprints:
        - are assumed to be 100 days long.
        - start on the 1st of January, May, and September.
    """
    length = timedelta(days=100)
    return {
        1: {"start": date(int(year), 1, 1), "end": date(int(year), 1, 1) + length},
        2: {"start": date(int(year), 5, 1), "end": date(int(year), 5, 1) + length},
        3: {"start": date(int(year), 9, 1), "end": date(int(year), 9, 1) + length},
        4: {
            "start": date(int(year) + 1, 1, 1)
        },  # Only start date for the next year's first sprint
    }


def get_current_sprint(sprints, today):
    """
    Returns the current sprint number, the number of days since the sprint started,
    and the number of days remaining in the sprint.
    """
    for sprint_number, sprint_dates in sprints.items():
        start, end = sprint_dates["start"], sprint_dates.get("end", date.max)

        # To fix the "Day 101" bug, use `<` instead of `<=`
        # Personally, I like having yet another day to finish the sprint ~ MJ :D
        if start <= today <= end:
            return (
                sprint_number,
                today - start + timedelta(days=1),
                end - today - timedelta(days=1),
            )
    return None, None, None


def get_topic(today):
    """
    Returns the topic string.
    """
    sprints = get_sprint_dates(today.year)
    sprint_number, current_day, days_remaining = get_current_sprint(sprints, today)

    if sprint_number:
        topic = f"{today} - Sprint {sprint_number}: Day {current_day.days} ({days_remaining.days} days remaining)"
        print(f"\n\n{topic}\n\n")
    else:
        for i in range(1, 4):
            if sprints[i]["end"] <= today < sprints[i + 1]["start"]:
                days_until_next_sprint = (sprints[i + 1]["start"] - today).days
                topic = f"{today} - No sprint in progress. Next sprint starts in {days_until_next_sprint} days"
                break
    return topic


def set_slack_channel_topic(channel_topic):
    """
    Sets the topic of the Slack channel.
    Returns the response text.
    """
    token = os.getenv("SLACK_AUTH_TOKEN")
    channel = os.getenv("SLACK_CHANNEL_ID")
    url = os.getenv("SLACK_API_URL", "https://slack.com/api/conversations.setTopic")

    headers = {"Authorization": f"Bearer {token}"}
    payload = {"channel": channel, "topic": channel_topic}
    response = requests.post(url, headers=headers, data=payload, timeout=10)

    return response.json()


def main():
    """
    Main function.
    """
    today = date.today()

    topic = get_topic(today)

    response = set_slack_channel_topic(topic)

    return response


def lambda_handler(event, context):
    """
    AWS Lambda handler function.
    """

    # Delete unused parameters
    del event, context

    response = main()

    if response["ok"]:
        return {"statusCode": 200, "body": json.dumps(response)}

    return {
        "statusCode": 500,
        "body": json.dumps(
            {"error": "Failed to set Slack channel topic", "response": response}
        ),
    }


if __name__ == "__main__":
    if os.getenv("TEST_LAMBDA_HANDLER"):
        print("## Running lambda_handler()")
        output = lambda_handler(None, None)
    else:
        print("## Running main()")
        output = main()

    print(output)
