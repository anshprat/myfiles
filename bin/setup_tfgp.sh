
ln -s ../${1}_vars.tf ./
ln -s ../terraform.tfvars ./
cp ../data_get.tf ./
cp ../state_store.tf ./
cp ../${1}_provider.tf ./
