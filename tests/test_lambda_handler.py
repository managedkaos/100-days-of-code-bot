"""
Test the lambda_handler function locally.
"""

import os
import json

from unittest import TestCase
from main import lambda_handler


class TestLambdaFunction(TestCase):
    """
    Test the lambda_handler function.
    """

    def setUp(self):
        # Store the original SLACK_AUTH_TOKEN to restore it later
        self.original_slack_auth_token = os.environ.get("SLACK_AUTH_TOKEN")
        os.environ["SLACK_CHANNEL_ID"] = os.environ.get("SLACK_CHANNEL_ID_TEST")

    def tearDown(self):
        # Restore the original SLACK_AUTH_TOKEN after each test
        if self.original_slack_auth_token is not None:
            os.environ["SLACK_AUTH_TOKEN"] = self.original_slack_auth_token
        else:
            del os.environ["SLACK_AUTH_TOKEN"]

    def test_successful_response(self):
        """
        Test the successful response of the lambda_handler function.

        Expect:
            statusCode == 200
            response["body"]["ok"] == True
        """
        response = lambda_handler(event=None, context=None)

        print(response)

        body = json.loads(response["body"])

        self.assertEqual(response.get("statusCode"), 200)
        self.assertTrue(body.get("ok"))

    def test_failure_response(self):
        """
        Test the failure response of the lambda_handler function.

        Expect:
            statusCode == 500
            response["body"]["ok"] == False
        """
        os.environ["SLACK_AUTH_TOKEN"] = "SUPER_FAKE"
        response = lambda_handler(event=None, context=None)

        print(response)

        body = json.loads(response["body"])

        self.assertEqual(response.get("statusCode"), 500)
        self.assertFalse(body.get("ok"))
