cinder list >cinder_list

grep in-use cinder_list |awk -F '|' '{print $8}'>cinder_in_use

sed -i 's/ //g' cinder_in_use 

cat cinder_in_use |xargs -I id nova show id &>nova_show 

grep No nova_show |awk '{print $10}'|sed -s "s/'//g" >nova_deleted_but_attached 

for i in `cat nova_deleted_but_attached`; do grep $i cinder_list |awk '{print $2}' ; done >cinder_inactive_host

for i in `cat cinder_inactive_host`; do echo "'"$i"'";done|paste -sd, >cinder_id

cinder_ids=`cat cinder_id`

echo "SELECT id,status,attach_status,mountpoint,instance_uuid from volumes where id in ($cinder_ids)"

echo 'UPDATE volumes SET status="available", attach_status="detached", mountpoint=NULL, instance_uuid=NULL WHERE id in ('$cinder_ids')'



#SELECT id,status,attach_status,mountpoint,instance_uuid from volumes where id in ('01fef1f1-dff8-4619-8f7c-8b4fecc052f3','07da5174-338b-4d18-ace4-dea478cddffa','0c04b32a-f3c3-48ac-974e-b910973191c7','0c59a4eb-814c-4397-8885-577579b5bd3c','1a8a30dd-7cc6-4575-9338-d4ba53baa008','1eafac81-5f1c-4c19-bc34-03e80083a276','242116aa-1676-4caf-9206-a4c4bb4c0e83','27ec4f72-10de-495a-a764-d589b31babed','497a9813-9981-4d56-bc15-271e6ad052ff','4fbf427c-1dd5-494a-a5a8-686fd6ec79be','4fe6f6c3-5386-48d3-ba30-14ea68d878db','64d7e111-2857-4afb-88c4-ce9d6def3aed','6aa9281d-0569-4ab7-b704-c705a47cd827','78d27cd9-1852-45f3-b5a9-a6acae8c1ab8','97a521eb-aee4-4b68-aa4a-59f56d021e91','b786c801-b426-4e6e-ad62-0d495a71ece7','ba94c568-054a-444c-92f6-975c0e84f36b','c7f5fe9e-34b8-4e5e-b504-a1f0f219de85')


#UPDATE volumes SET status="available", attach_status="detached", mountpoint=NULL, instance_uuid=NULL WHERE id in ('01fef1f1-dff8-4619-8f7c-8b4fecc052f3','07da5174-338b-4d18-ace4-dea478cddffa','0c04b32a-f3c3-48ac-974e-b910973191c7','0c59a4eb-814c-4397-8885-577579b5bd3c','1a8a30dd-7cc6-4575-9338-d4ba53baa008','1eafac81-5f1c-4c19-bc34-03e80083a276','242116aa-1676-4caf-9206-a4c4bb4c0e83','27ec4f72-10de-495a-a764-d589b31babed','497a9813-9981-4d56-bc15-271e6ad052ff','4fbf427c-1dd5-494a-a5a8-686fd6ec79be','4fe6f6c3-5386-48d3-ba30-14ea68d878db','64d7e111-2857-4afb-88c4-ce9d6def3aed','6aa9281d-0569-4ab7-b704-c705a47cd827','78d27cd9-1852-45f3-b5a9-a6acae8c1ab8','97a521eb-aee4-4b68-aa4a-59f56d021e91','b786c801-b426-4e6e-ad62-0d495a71ece7','ba94c568-054a-444c-92f6-975c0e84f36b','c7f5fe9e-34b8-4e5e-b504-a1f0f219de85')
