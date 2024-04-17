from datetime import date, timedelta
import os
import sys
import requests


def calculate_sprint_dates(year):
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
    for sprint_number, sprint_dates in sprints.items():
        start, end = sprint_dates["start"], sprint_dates.get("end", date.max)
        if start <= today <= end:
            return (
                sprint_number,
                today - start + timedelta(days=1),
                end - today - timedelta(days=1),
            )
    return None, None, None


def set_slack_channel_topic(channel_topic):
    token = os.getenv("SLACK_AUTH_TOKEN")
    channel = os.getenv("SLACK_CHANNEL_ID")
    url = "https://slack.com/api/conversations.setTopic"
    headers = {"Authorization": f"Bearer {token}"}
    payload = {"channel": channel, "topic": channel_topic}
    response = requests.post(url, headers=headers, data=payload, timeout=10)
    print(response.text)


def prepare_and_update_topic(today):
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
    set_slack_channel_topic(topic)


def main():
    today = date.today()
    print(f"Date: {today}")
    prepare_and_update_topic(today)


if __name__ == "__main__":
    main()
