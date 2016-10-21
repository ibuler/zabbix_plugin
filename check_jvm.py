#!/usr/bin/python
#
# Author: Guanghongwei <ibuler@qq.com>
# Date: 2016-10-12
#

import subprocess
import os
import shlex
import sys
import pickle

try:
    import simplejson as json
except ImportError:
    import json

project_dir = '/data/www/projects'


def get_jstat():
    jstat = '/data/server/java/default/bin/jstat'
    if not os.path.isfile(jstat):
        jstat = subprocess.Poen('which jstat', shell=True, stdout=subprocess.PIPE).stdout.read()
    
    if not jstat:
        return ''
    return jstat
    


def discovery_app_pid_map():
    proc_pid_map = {}

    apps = os.listdir(project_dir)
    # ps_all = subprocess.Popen(shlex.split('ps axu'), stdout=subprocess.PIPE).stdout.read()
    
   
    for app in apps:
        proc = subprocess.Popen('ps axu | grep -v grep | grep java | grep %s' % app, shell=True,
                                 stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        try:
            pid = proc.stdout.read().split()[1]
            proc_pid_map[app] = pid
        except IndexError:
            continue
 
    return proc_pid_map


def discovery_app():
    apps = discovery_app_pid_map().keys()
    results = []

    for app in apps:
        results.append({"{#VALUE}": app})

    print json.dumps({"data": results}, sort_keys=True, indent=7, separators=(',',':'))
        


def collect_perf(app):
    jstat = get_jstat()

    if not jstat:
        print "No jstat"
    
    all_perfs = {}
    app_pid_map = discovery_app_pid_map()
    cmd = []
    for option in ["-gccapacity", "-gc", "-gcutil"]:
        cmd.append("sudo")
        cmd.append("-uweb")
        cmd.append(jstat)
        cmd.append(option)
        pid = app_pid_map.get(app)
        cmd.append(pid)

        proc = subprocess.Popen(cmd, stdout=subprocess.PIPE)
        cmd = []
        
        keys = proc.stdout.readline().split()
        values = proc.stdout.readline().split()

        for key, value in zip(keys, values):
            all_perfs[key] = value

    with open('/dev/shm/.%s' % app, 'w') as f:
         pickle.dump(all_perfs, f)

    print 1
    return all_perfs


def get_app_perf_key(app, key):
    with open('/dev/shm/.%s' % app) as f:
        all_perfs = pickle.load(f)
    print all_perfs.get(key, '')


if __name__ == '__main__':
    if len(sys.argv) == 2 and sys.argv[1] == 'discovery':
        discovery_app()
    elif len(sys.argv) == 3 and sys.argv[1] == 'collect':
        app = sys.argv[2]
        if app in discovery_app_pid_map().keys():
            collect_perf(app)
        else:
            print "Not in all apps"
    elif len(sys.argv) == 4 and sys.argv[1] == 'perf':
        app = sys.argv[2]
        key = sys.argv[3]
        get_app_perf_key(app, key)
    else:
        print("Usage %s: discovery | collect app | perf app key" % sys.argv[0])
