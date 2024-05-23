"""
Test the lambda_handler function locally.
"""

import json
from main import lambda_handler


def test_lambda_handler():
    """
    Test the lambda_handler function locally.
    """
    # Simulate a basic event and context
    event = {}
    context = {}

    # Invoke the lambda_handler function
    response = lambda_handler(event, context)

    # Print the response for inspection
    print(json.dumps(response, indent=4))
