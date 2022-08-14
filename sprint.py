# pylint: disable=C0114,C0206
'''
Just some code that calculates the dates for three 100-day sprints
'''
from datetime import date
from datetime import timedelta as delta
import os
import sys
import requests


def set_slack_channel_topic(channel_topic):
    '''
    A function for setting the topic of a slack channel
    Input t = the text to use for the topic
    '''
    token = os.getenv('SLACK_AUTH_TOKEN')
    channel = os.getenv('SLACK_CHANNEL_ID')
    url = 'https://slack.com/api/conversations.setTopic'
    payload = {'channel': channel, 'topic': channel_topic}
    headers = {'Authorization': f"Bearer {token}"}
    response = requests.request("POST", url, headers=headers, data=payload)
    print(response.text.encode('utf8'))


length = delta(days=100)
today = date.today()

# Sprint attributes:
# - start dates are 1/1, 5/1, and 9/1 (year dosen't matter)
# - end dates are 100 days after the start date
sprints = {
    1: {'start': date(today.year, 1, 1), 'end': date(today.year, 1, 1) + length},
    2: {'start': date(today.year, 5, 1), 'end': date(today.year, 5, 1) + length},
    3: {'start': date(today.year, 9, 1), 'end': date(today.year, 9, 1) + length},
    4: {'start': date(today.year+1, 1, 1)}
}

print(f"Date      : {today}")

for sprint in sprints:
    if sprints[sprint]['start'] <= today <= sprints[sprint]['end']:
        current = today - sprints[sprint]['start'] + delta(days=1)
        remaining = sprints[sprint]['end'] - today - delta(days=1)
        print(f"Sprint    : {sprint}")
        print(f"Day       : {current.days}")
        print(f"Remaining : {remaining.days}")

        TOPIC = f"Sprint {sprint}: Day {current.days} ({remaining.days} days remaining)"
        print(TOPIC)
        set_slack_channel_topic(TOPIC)
        sys.exit(0)

for sprint in range(1, 4):
    if sprints[sprint]['end'] <= today <= sprints[sprint+1]['start']:
        next_sprint = sprints[sprint+1]['start'] - today
        TOPIC = f"No sprint in progress. Next sprint starts in {next_sprint.days} days"
        print(TOPIC)
        set_slack_channel_topic(TOPIC)
        break
