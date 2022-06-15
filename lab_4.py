import boto3


def syncTables():
    source_ddb = boto3.client("dynamodb", "us-east-1")
    destination_ddb = boto3.client("dynamodb", "us-west-2")
    sync_ddb_table(source_ddb, destination_ddb)


def sync_ddb_table(source_ddb, destination_ddb):
    table = source_ddb.Table("<FMI1")
    scan_kwargs = {}
    done = False
    start_key = None
    while not done:
        if start_key:
            scan_kwargs["ExclusiveStartKey"] = start_key
        response = table.scan(**scan_kwargs)
        for item in response["Items"]:
            destination_ddb.put_item(TableName="<FMI2>", Item=item)
        start_key = response.get("LastEvaluatedKey", None)
        done = start_key is None


syncTables()
