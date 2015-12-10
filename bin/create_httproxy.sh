set -xe
cd $HOME/git/ril/puppet-rjil	
## 
# For creating httpproxy, uncomment the below BUILD_TAG.
# Your httpproxy BUILD_TAG should be different from your regular build tag, else cleanup
# will delete your httpproxy as well
##
BUILD_TAG=external-at  

##
# layout=external only for creating httpproxy. Comment out for regular builds
##
export layout=external


## Update this to the key-pair name you uploaded to your tenant
export KEY_NAME=combo
## Path to your openrc file
#export env_file="/home/anshup/git/anshprat/myfiles/private_keys/anshu_staging_rc"
export env_file="/home/anshup/git/anshprat/myfiles/private_keys/jenkins_staging_at_rc"
export ssh_user=ubuntu

# You should have an environment/<cloud_provider_name_specified_below>.map.yaml
# Use environment/jio.map.yaml as a template for your copy and update the network id there
#export cloud_provider=anshu_gate_staging
export cloud_provider=jenkins_staging_at

export puppet_modules_source_repo=https://github.com/jiocloud/puppet-rjil

######################## END OF MODIFICATIONS ################################

export module_git_cache=http://jiocloud.rustedhalo.com:8080/job/puppet-jiocloud-cache/lastSuccessfulBuild/artifact/cache.tar.gz
export git_protocol=https

export BUILD_NUMBER=$BUILD_TAG
# use the acceptance test environment (I may have to patch this a little)
export module_git_cache=http://jiocloud.rustedhalo.com:8080/job/puppet-jiocloud-cache/lastSuccessfulBuild/artifact/cache.tar.gz
export env=at

./build_scripts/deploy.sh
./build_scripts/test.sh

