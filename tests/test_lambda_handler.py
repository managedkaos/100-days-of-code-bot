"""
Test the lambda_handler function locally.
"""

import json
import unittest
from main import lambda_handler


class TestLambdaFunction(unittest.TestCase):
    """
    Test the lambda_handler function.
    """

    def test_response(self):
        """
        Test the response of the lambda_handler function.
        """
        response = lambda_handler(event=None, context=None)
        print(json.dumps(response, indent=4))

        # Convert the body to a Python dictionary for easier access
        body = json.loads(response["body"])

        self.assertTrue(body.get("ok"))


if __name__ == "__main__":
    unittest.main()
