# pylint: disable=C0114
# TODO: Convert this into a function XD
from datetime import date
from datetime import timedelta as delta
import os, requests, sys

length = delta(days = 100)
today  = date.today()

# Sprint attributes:
# - start dates are 1/1, 5/1, and 9/1 (year dosen't matter)
# - end dates are 100 days after the start date
sprints = {
    1:{'start':date(today.year, 1, 1), 'end':date(today.year, 1, 1) + length},
    2:{'start':date(today.year, 5, 1), 'end':date(today.year, 5, 1) + length},
    3:{'start':date(today.year, 9, 1), 'end':date(today.year, 9, 1) + length},
    4:{'start':date(today.year+1, 1, 1)}
}

print("Date      : {}".format(today))

for sprint in sprints:
    if sprints[sprint]['start'] <= today <= sprints[sprint]['end']:
        current   = today - sprints[sprint]['start'] + delta(days = 1)
        remaining = sprints[sprint]['end'] - today - delta(days = 1)
        print("Sprint    : {}".format(sprint))
        print("Day       : {}".format(current.days))
        print("Remaining : {}".format(remaining.days))

        topic = "Sprint {}: Day {} ({} days remaining)".format(sprint, current.days, remaining.days)

        # TODO: Convert this into a function; arg would be the topic
        # Update Slack
        token    = os.getenv('SLACK_AUTH_TOKEN')
        channel  = os.getenv('SLACK_CHANNEL_ID')
        url      = 'https://slack.com/api/conversations.setTopic'
        payload  = {'channel':channel, 'topic': topic}
        headers  = {'Authorization': "Bearer {}".format(token)}
        response = requests.request("POST", url, headers=headers, data=payload)
        print(response.text.encode('utf8'))
        sys.exit(0)

print("No sprint in progress")

for sprint in range(1,4):
    if sprints[sprint]['end'] <= today <= sprints[sprint+1]['start']:
        next_sprint = sprints[sprint+1]['start'] - today
        print("Next sprint starts in {} days".format(next_sprint.days))
        break
