import datetime
import shlex
import subprocess  # nosemgrep: gitlab.bandit.B404
import sys
from ast import arg

import boto3

s3 = boto3.client("s3")


def main(argv):
    cmd = argv
    log_file_name = datetime.datetime.now().strftime("%m_%d_%Y") + "_logfile"
    kickoff_subprocess(cmd, log_file_name)
    upload_output_to_S3(log_file_name)


def kickoff_subprocess(cmd, log_file_name):
    safe_cmd = shlex.quote(cmd)
    process = subprocess.call(safe_cmd, shell=False)
    timestamp = datetime.datetime.now().strftime("%m/%d/%Y, %H:%M:%S")
    with open(log_file_name, "a+") as file:
        output = (
            timestamp
            + " Command: "
            + safe_cmd[0]
            + " | Return Code: "
            + str(process)
            + "\n"
        )
        file.write(output)


def upload_output_to_S3(log_file_name):
    with open(log_file_name, "rb") as f:
        s3.upload_fileobj(f, "<FMI1>", log_file_name)


if __name__ == "__main__":
    main(sys.argv[1:])
