import taskcluster
import tcbuild
import requests.packages.urllib3
import os.path
import sys

def fetch_log(task, run):
  auth = tcbuild.read_tc_auth(os.path.expanduser('~/.tcauth'))
  queue = taskcluster.Queue({'credentials': auth})
  url = queue.buildUrl('getArtifact', task, run, 'public/logs/live.log')
  return requests.get(url, stream=True)

if __name__ == '__main__':
  for line in fetch_log(sys.argv[1], 0).iter_lines():
    print(line)
