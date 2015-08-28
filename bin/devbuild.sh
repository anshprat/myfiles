set -xe
cd $HOME/git/ril/puppet-rjil
BUILD_TAG=anshu-test-tenant-1
#BUILD_TAG=jumphost-external-at
##
# For creating httpproxy, uncomment the below BUILD_TAG.
# Your httpproxy BUILD_TAG should be different from your regular build tag, else cleanup
# will delete your httpproxy as well
##
#BUILD_TAG=external-at

##
# layout=external only for creating httpproxy. Comment out for regular builds
##
# export layout=external

##
# Use this for setting your puppet-rjil PR id
# Comment out both if you just want to use master branch.
##
#ghprbPullId=774
#export pull_request_id=$ghprbPullId

## Update this to the key-pair name you uploaded to your tenant
export KEY_NAME=combo
## Path to your openrc file
#export env_file="/home/anshup/git/anshprat/myfiles/private_keys/anshu_staging_rc"
export env_file="/home/anshup/git/anshprat/myfiles/private_keys/anshu_rc"
export ssh_user=ubuntu
## You need to change the dns_server only if the private ip of your httpproxy is different.
## This should be the private ip of your httpproxy server
#export dns_server=10.0.0.2
#export env_http_proxy=http://${dns_server}:3128/
#export env_https_proxy=http://${dns_server}:3128/

# You should have an environment/<cloud_provider_name_specified_below>.map.yaml
# Use environment/jio.map.yaml as a template for your copy and update the network id there
export cloud_provider=anshu_gate
#export cloud_provider=anshu_gate_staging

##
# Below are only required if you are making changed to python-jiocloud and need to source
# them from your repo instead of from jiocloud master
##
#export python_jiocloud_source_repo=git+https://github.com/anshprat/python-jiocloud
#export python_jiocloud_source_branch=bodepd_rolling_upgrade_code

##
# This is required only when you are using your own pkgs build via pkg_test_build or consul-gate
##
#export override_repo="http://jiocloud.rustedhalo.com:8080/job/pkg_test_build/82/artifact/new_repo.tgz"

##
# This is required to be changed only when you are making changes to
# puppet rjil and want to test those changes from your repo without opening PR
# This and PR id should not be used together.
##
#export puppet_modules_source_repo=https://github.com/anshprat/puppet-rjil
export puppet_modules_source_repo=https://github.com/JioCloud/puppet-rjil
#export puppet_modules_source_branch=test-tenant-upgrade
##

######################## END OF MODIFICATIONS ################################

export module_git_cache=http://jiocloud.rustedhalo.com:8080/job/puppet-jiocloud-cache/lastSuccessfulBuild/artifact/cache.tar.gz
export git_protocol=https

export BUILD_NUMBER=$BUILD_TAG
# use the acceptance test environment (I may have to patch this a little)
export module_git_cache=http://jiocloud.rustedhalo.com:8080/job/puppet-jiocloud-cache/lastSuccessfulBuild/artifact/cache.tar.gz
export env=at

./build_scripts/deploy.sh
./build_scripts/test.sh
