import json
import os


def handler(event, context):
    # print() output goes to the function's CloudWatch log group.
    print(json.dumps({"greeting": os.environ["GREETING"], "source": event.get("source")}))
    return {"ok": True}
