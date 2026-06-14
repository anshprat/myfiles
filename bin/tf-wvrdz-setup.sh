ln -s ../variables.tf ./
ln -s ../data.tf ./
ln -s ../providers.tf ./
if [ ! -f state-store.tf ]; then
  cp ../state-store.tf ./
fi