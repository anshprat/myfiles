JENKINS_HOME=/app/docker/jenkins/home/

cleanup () {
  dir=$1
  this_dir=`pwd`
  echo "CLEANING UP ${this_dir}"
  not_names="-not -name 'config.xml'"
  excludes="lastFailedBuild lastStableBuild lastSuccessfulBuild lastUnstableBuild lastUnsuccessfulBuild"
  for f in $excludes
  do
    not_names="${not_names} -not -name '*$f*'"
    not_name=`readlink builds/$f`
    if [ ! -z ${not_name} ]
    then
      not_names="${not_names} -not -name ${not_name}"
    fi
  done
  echo ${not_names}
  cmd="find ${dir} -maxdepth 1 -mindepth 1 -type d -mtime +10 ${not_names} -exec rm -rvf {}  \;"
  echo "CLEANUP ${cmd}"
  # executing cmd fails with missing args to exec
  find ${dir} -maxdepth 1 -mindepth 1 -type d -mtime +10 ${not_names} -exec rm -rvf {}  \;
}

export -f cleanup

find "${JENKINS_HOME}/jobs" -mtime +10  -path '*/builds'  -type d -execdir bash -c 'cleanup "$0"' {} \;
# find . -mtime +10  -path '*/builds'  -type d -execdir bash -c 'cleanup "$0"' {} \;
