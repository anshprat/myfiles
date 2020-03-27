#!/bin/zsh
set -x

source ./creds.sh

base_folder="./jsons"
base_folder_repos="${base_folder}/repos_list"
base_folder_commits="${base_folder}/commits"
mkdir -p ${base_folder_repos}
apicreds="${user}:${usercreds}"
org=myorg
verbosity=-s
url_base="https://${apicreds}@api.bitbucket.org/2.0"
year_till=2019
repos_list_file=repos_list

repos_url="${url_base}/repositories/${org}"

# Use this counter to track rate limit
# https://confluence.atlassian.com/bitbucket/rate-limits-668173227.html
# Using 10% of all limits to pace it all out rather than going full steam first
# to go full steam first use factor=1
#factor=0.01

let api_hit_count=1
let threshold_sec=30
let api_warn_limit=7
let time_limit=36
let api_hit_limit=10

start=`date +%s`

function get_all(){
next_page=${1:-null}
this_file_base=${2:-"${base_folder_repos}/${repos_list_file}"}
this_file="${this_file_base}_${next_page}.json"
features_url=$3
is_commits=$4
while [ ${next_page} != 'null' ]
do
    let api_hit_count=api_hit_count+1
    now=`date +%s`
    let d=now-start
    if [ $d -lt ${threshold_sec} ]
      then
        if [ ${api_hit_count} -ge ${api_warn_limit} ]
        then
          let sleep_time=$(( (time_limit-d)/(api_hit_limit-api_hit_count) ))
          sleep ${sleep_time}
        fi
    fi
    if [ $d -ge ${threshold_sec} ]
    then
      let api_hit_count=api_hit_limit-api_hit_count
      start=`date +%s`
    fi
    # echo ${api_hit_count}
    curl "${verbosity}" "${repos_url}${features_url}?${next_page}" -o ${this_file}
    if [ ! -z ${is_commits} ]
    then
       jq '.values[]|.date' < ${this_file}|grep ${year_till}
       is_year=$?
       if [ ${is_year} -eq 0 ]
       then
         break
       fi
     fi

    next_file=`jq '.next' < ${this_file}`
    next_page=`echo $next_file|cut -f 2- -d '?'|cut -f 1 -d '"'`
    this_file="${this_file_base}_${next_page}.json"
done

}

get_all


for f in `ls ${base_folder_repos}`
# for f in 1
do
  for repo in `jq '.values[]|.links.commits|.href' < ${base_folder_repos}/${f}| awk -F '/' '{ print $(NF-1)}'`
  # for repo in reponame
  do
    # echo ${repo}
    if [ ! -d ${base_folder_commits}/${repo} ]
    # if [ -d ${base_folder_commits}/${repo} ]
    then
      # echo $repo
      mkdir -p ${base_folder_commits}/${repo}
      get_all 1 "${base_folder_commits}/${repo}/commits" "/${repo}/commits" commits
    fi
    repo_folder="${base_folder_commits}/${repo}"
    commits_date="${repo_folder}/commits_date.txt"
    rm -rf ${commits_date}
    for c in `ls ${repo_folder}`
    do
      this_file="${repo_folder}/$c"
      jq '.values[]|.date' < ${this_file} >> ${commits_date}
    done
  done
done
