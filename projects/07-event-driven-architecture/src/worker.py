import json


def handler(event, context):
    # Report failures per message so only failed messages are retried
    # (requires function_response_types = ["ReportBatchItemFailures"]).
    failures = []
    for record in event["Records"]:
        try:
            order = json.loads(record["body"])
            if order.get("status") == "broken":
                raise ValueError("cannot process broken order")
            print(json.dumps({"processed": order}))
        except Exception as error:  # noqa: BLE001 - demo: report and continue
            print(json.dumps({"failed": record["messageId"], "error": str(error)}))
            failures.append({"itemIdentifier": record["messageId"]})
    return {"batchItemFailures": failures}
