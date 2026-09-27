import json
import os

import boto3

table = boto3.resource("dynamodb").Table(os.environ["TABLE_NAME"])


def handler(event, context):
    # Atomically add 1 to the counter for this path and return the new value.
    path = event.get("rawPath", "/")
    result = table.update_item(
        Key={"pk": path},
        UpdateExpression="ADD visits :one",
        ExpressionAttributeValues={":one": 1},
        ReturnValues="UPDATED_NEW",
    )
    visits = int(result["Attributes"]["visits"])
    return {
        "statusCode": 200,
        "headers": {"content-type": "application/json"},
        "body": json.dumps({"path": path, "visits": visits}),
    }
