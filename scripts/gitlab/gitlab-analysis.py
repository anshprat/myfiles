import requests
import datetime
import pprint
import os
import pickle
import concurrent.futures
import threading
from secretsdata import *
import sys
import argparse

userfile = "users.txt"

bool_true = [1, "1", "True", "true", "TRUE"]

parser = argparse.ArgumentParser()
# Add the argument
parser.add_argument("--user", help="Specify the username,[grab username]")
parser.add_argument("--userfile", help="Specify the userfile")
parser.add_argument("--print_commits", help="Print commits")
parser.add_argument("--print_events_all", help="Print events all")
parser.add_argument("--ignore-terraformer-all", help="Ignore Terraformer")
parser.add_argument("--override-run-date", help="Override run date")
# Parse the arguments
args = parser.parse_args()

# Potentially insecure, but we're not using this for anything important
if len(sys.argv) > 1:
    userfile = sys.argv[1]

get_stats = True


use_threads_events = False
use_threads_users = False
print_info = False
print_info2 = False
print_debug = False
print_debug2 = False
print_debug3 = False
print_events = False
override_run_date = False
terraform_repos = [4755]
cache_file_extension = ".p"
other_events = {}
global_other_events = {}
user_stats = {}
print_user_stats = False


run_date = datetime.datetime.now().strftime("%Y%m%d")

if args.override_run_date:
    override_run_date = args.override_run_date


if bool(int(override_run_date)):
    run_date = override_run_date

basepath = os.path.expanduser('~')+"/tmp/gitlab-analysis/"
run_folder = basepath+run_date
os.makedirs(run_folder, exist_ok=True)

# Using merge_dicts instead of update or copy to update the values as well.


def merge_dicts(dict1, dict2):
    for key, value in dict2.items():
        if key in dict1:
            if isinstance(dict1[key], dict) and isinstance(value, dict):
                # Recursively merge sub-dictionaries
                dict1[key] = merge_dicts(dict1[key], value)
            else:
                # Add values if both are numeric, otherwise, overwrite
                if isinstance(dict1[key], (int, float)) and isinstance(value, (int, float)):
                    dict1[key] += value
                else:
                    dict1[key] = value
        else:
            dict1[key] = value
    return dict1

# To get the keys with value as 0


def reset_dict_to_zero(d):
    for key, value in d.items():
        if isinstance(value, dict):
            # If the value is a dictionary, recursively reset it
            reset_dict_to_zero(value)
        else:
            # Set the value to zero
            d[key] = 0

def get_values_in_order(d):
    values = []

    for key, value in d.items():
        if isinstance(value, dict):
            values.extend(get_values_in_order(value))
        else:
            values.append(value)

    return values

# Example usage:
my_dict = {
    'a': {
        'b': {
            'c': 1,
            'd': 2
        },
        'e': 3
    },
    'f': 4
}


def get_data(url, headers, cache, params="", return_response=False):
    if print_debug:
        print(f"URL: {url}, params: {params}, cache: {cache}")
    if not os.path.exists(cache):
        response = requests.get(url, headers=headers, params=params)
        os.makedirs(os.path.dirname(cache), exist_ok=True)
        with open(cache, "wb") as file:
            pickle.dump(response, file)
        file.close()
    else:
        file = open(cache, "rb")
        response = pickle.load(file)
        file.close()

    if return_response:
        return response
    else:
        return response.json()


def get_events(events_url, headers, params, events_cache, username, stats_commits=0, stats_add=0, stats_del=0, stats_total=0):
    print("get_events_called")
    orig_username = username
    username, git_username = get_usernames(username)
    events_response = get_data(events_url, headers, events_cache, params, True)
    events = events_response.json()
    cache_user_base = run_folder+"/users/"+username
    for event in events:
        if print_debug:
            pprint.pprint(event)
        if (print_info):
            print(f"Event: {event['action_name']}")
            print(f"project_id: {event['project_id']}")

        # GET /projects/:id
        project_api = f"/projects/{event['project_id']}"
        project_url = f"{gitlab_url}{project_api}"
        project_cache = cache_user_base + \
            "/project-"+str(event['project_id'])+".p"

        if (print_info):
            project = get_data(project_url, headers, project_cache)
            print(f"Project with namespace: {project['name_with_namespace']}")
            print("\n")

        if ("pushed" in event['action_name']):
            commit_sha = event['push_data']['commit_to']
            #  /projects/:id/repository/commits/:sha
            if (get_stats) and commit_sha is not None:
                commit_api = f"{project_api}/repository/commits/{commit_sha}"
                commit_url = f"{gitlab_url}{commit_api}"
                commit_cache = cache_user_base+"/commits/commit-"+commit_sha+".p"
                commit = get_data(commit_url, headers, commit_cache)
                if (print_commits in bool_true):
                    pprint.pprint(commit)

                try:
                    email_name = (commit["author_email"]).split("@")[0]
                    if (email_name == git_username):
                        if event['project_id'] in terraform_repos and ignore_terraform_commits in bool_true:
                            break
                        if (print_info2):
                            # Print out the relevant information about the commits
                            try:
                                pprint.pprint(commit)
                            except:
                                pass
                        try:
                            stats_add += commit['stats']['additions']
                            stats_del += commit['stats']['deletions']
                            stats_total = stats_add - stats_del
                        except:
                            pass
                        stats_commits += 1
                    else:
                        if (print_debug2):
                            print(email_name, username)
                            print(
                                f" {username}\t{stats_commits}\t{stats_add}\t{stats_del}\t{stats_total} ")
                except:
                    pass

        else:
            if (print_debug2):
                print("Not a push event", event['action_name'])
            action_name = event['action_name']
            target_type = event['target_type']

            # Create inner dictionary if action_name doesn't exist in other_events
            if action_name not in other_events:
                other_events[action_name] = {}

            # Assign target_type to the inner dictionary
            other_events[action_name][target_type] = other_events[action_name].get(
                target_type, 0) + 1
        # TODO: convert to debug level rather?
        if (print_events_all in bool_true):
            pprint.pprint(event)
            # print(print_events,bool(print_events))

    if (events_response.headers['X-Next-Page']):
        params['page'] = events_response.headers['X-Next-Page']
        if (print_debug2):
            print(params)
        events_cache = cache_user_base + \
            "/events/events-"+str(params['page'])+".json"
        if (use_threads_events):
            threading.Thread(target=get_events, args=(events_url, headers, params, events_cache,
                             username, stats_commits, stats_add, stats_del, stats_total), daemon=True).start()
        else:
            get_events(events_url, headers, params, events_cache,
                       username, stats_commits, stats_add, stats_del, stats_total)

    else:
        stats = f"{username}\t{stats_commits}\t{stats_add}\t{stats_del}\t{stats_total}\t"
        # print(other_events)
        user_stats.update({username: {"c": stats_commits, "a": stats_add,
                          "d": stats_del, "t": stats_total, "o": other_events.copy()}})
        
        # print(user_stats,"\n\n")
        # print(len(user_stats))
        if print_user_stats:
            print(user_stats)
            print(stats, other_events)
            
        # print(stats)
        # pprint.pprint(other_events)
        # print()
        global global_other_events
        global_other_events = merge_dicts(global_other_events, other_events)
        # user_other_events_store.update({username:other_events.copy()})
        other_events.clear()
        output_fh = open(output_file, 'a')
        output_fh.write(stats+"\n")
        output_fh.flush()
        if print_user_stats:
            print(user_stats)
            print(stats, other_events)
        print(user_stats)


def get_user_details(username):
    orig_username = username
    username, git_username = get_usernames(username)

    stats_commits = 0
    if (get_stats):
        stats_add = 0
        stats_del = 0
        stats_total = 0
    else:
        stats_add = ""
        stats_del = ""
        stats_total = ""

    after_date = "2023-07-01"

    # Make a GET request to the GitLab API to get information about the user

    users_api = f"/users?username={username}"
    cache_user_base = run_folder+"/users/"+username
    users_cache = cache_user_base+"/user.p"
    users_url = f"{gitlab_url}{users_api}"
    # print(users_url)
    headers = {"Private-Token": pat}

    users = get_data(users_url, headers, users_cache)
    # Extract the user's ID from the response
    if len(users) > 0:
        user_id = users[0]["id"]
    else:
        if (print_debug):
            print(f"No user was found with the username {username}")
        return

    # GET /users/:id/events
    events_api = f"/users/{user_id}/events"
    events_url = f"{gitlab_url}{events_api}"
    events_cache = cache_user_base+"/events/events-0.p"

    if (print_debug):
        print(events_url, events_cache)
    params = {
        "pagination": "keyset",
        "per_page": "100",
        "order_by": "id",
        "sort": "asc",
        "after": after_date
    }
    get_events(events_url, headers, params, events_cache, orig_username,
               stats_commits=0, stats_add=0, stats_del=0, stats_total=0)


def get_group_members(group_id):
    gm_api = f"/groups/{group_id}/members"
    gm_url = f"{gitlab_url}{gm_api}"
    gm_cache = run_folder+"/groups/"+group_id


def get_usernames(username):
    if ("," in username):
        username, git_username = username.split(",")
    else:
        git_username = username
    return username, git_username
#
#  Execution starts here


output_file = run_folder+"/stats.txt"

if args.userfile:
    userfile = args.userfile

if args.ignore_terraformer_all:
    ignore_terraform_commits = args.ignore_terraformer_all

if args.user:
    users = [args.user]
else:
    with open(userfile, 'r') as file:
        if (print_info2):
            print("[INFO] Reading users from file "+userfile)
        users = [line.strip() for line in file]


print_events_all = False
print_commits = False
# TODO: Move it to separate args and maybe levels
if args.print_commits:
    print_commits = args.print_commits

if args.print_events_all:
    print_events_all = args.print_events_all

output_header = "{username}\t{stats_commits}\t{stats_add}\t{stats_del}\t{stats_total}"
if (print_info2):
    print(output_header)

output_fh = open(output_file, 'w')
output_fh.write(output_header+"\n")
output_fh.flush()
output_fh.close()

if (use_threads_users):
    with concurrent.futures.ThreadPoolExecutor(max_workers=5) as executor:
        future_to_users = {executor.submit(
            get_user_details, username): username for username in users}
        for future in concurrent.futures.as_completed(future_to_users):
            user = future_to_users[future]
            try:
                data = future.result()
            except Exception as exc:
                print('%r generated an exception: %s' % (user, exc))
            else:
                if (print_debug):
                    print('processed %r user successfully' % (user))
                pass
else:
    for username in users:
        get_user_details(username)
output_fh.close()

# # print(global_other_events)
# # pprint.pprint(user_other_events_store)
# # pprint.pprint(user_stats)

# reset_dict_to_zero(global_other_events)
# # print(global_other_events)
# sorted_goe = {k: v for k, v in sorted(global_other_events.items())}
# # print(sorted_goe)

print(user_stats)


# for user in user_stats:
#     print(user_stats)
    # print(user)
    # print(sorted_goe)
    # print(user_stats[user]["o"])
    # user_stats[user]["o"] = sorted_goe.update(user_stats[user]["o"])
    # user_data = user_stats[user]["o"]
    # print(sorted_goe)
    # print(user_stats[user]["o"])
    
    
    # print(sorted_goe)
    # user_stats[user].pop("o")
    # sorted_user_data = {k: v for k, v in sorted(user_data.items())}
    # user_stats[user].update(sorted_user_data)
    # print(user, ",", user_stats[user])
    # tmp_user_stats = []
    # tmp_user_stats.append(user)
    # for _,v in user_stats[user]:
    #     tmp_user_stats.append(v)

    # o_stats = get_values_in_order(sorted_user_data)

    # for v in o_stats:
    #  tmp_user_stats.append(v)
    
    # reset_dict_to_zero(sorted_goe)

    # print(tmp_user_stats)
