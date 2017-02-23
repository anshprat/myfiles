import time
start_time = time.time()
import boto3 as boto
import boto3
from collections import Counter
from itertools import chain
from pricing import price_dict
import sys
import statsd

statsd_prefix = 'costrack.aws'
print_region_details = False
statsdc = statsd.StatsClient('statsd01.corp.freecharge.com', 8125, prefix=statsd_prefix)

roles_dict = {'glassfish':'arn:aws:iam::538360184485:role/GlassFish-Prod-PowerUsers',
				'freechargeProd':'arn:aws:iam::695210568016:role/FreeCharge-Prod-PowerUsers',
				'freechargeDev':'arn:aws:iam::186079218002:role/FreeCharge-Dev-PowerUsers',
				'klickpay':'arn:aws:iam::608836331289:role/KlickPay-Prod-PowerUsers',
				'blueshark':'arn:aws:iam::077358570399:role/Wallet-Prod-PowerUsers',
				'nebula':'arn:aws:iam::355100291228:role/Nebula-Dev-PowerUsers',
				'whirlpool':'arn:aws:iam::259209043622:role/Whirlpool-QA-PowerUsers',
				'identity':'arn:aws:iam::020272951068:role/IdentityPowerUsers'
				}

def_region='ap-south-1'
# Get regions using Identity Account
client = boto3.client('ec2', region_name=def_region)
regions = [region['RegionName'] for region in client.describe_regions()['Regions']]



sts_client = boto3.client('sts')
ec2_cost = {}
# print price_dict
all_instances = {}
keyPrint = 'Processing '
for role in roles_dict:
	role_cost = {}
	count_before_role = len(all_instances)
	assumedRoleObject = sts_client.assume_role(
	    RoleArn=roles_dict[role],
	    RoleSessionName=role
	)

	credentials = assumedRoleObject['Credentials']
	for region in regions:
		# print keyPrint, role, region 
		print '.',
		sys.stdout.flush()
		ec2 = boto3.resource('ec2', 
			region_name=region,
			aws_access_key_id = credentials['AccessKeyId'],
    		aws_secret_access_key = credentials['SecretAccessKey'],
    		aws_session_token = credentials['SessionToken'],
		)
		instances = ec2.instances.filter(
		    Filters=[{'Name': 'instance-state-name', 'Values': ['running']}])
		this_region = {}
		for instance in instances:
			# print role,region,instance.id
			this_region[instance.id]=instance.instance_type
			all_instances.update(this_region)
		    #instance.id, instance.instance_type)
		instance_count = len(this_region)
		if instance_count > 0:
			print 
			region_cost = {}
			print role,region,instance_count
			counts = Counter(this_region.itervalues())
			for instance in list(counts):
				#price of this instance type count
				try:
					price_instance_region = price_dict[region][instance]
				except KeyError:
					# print 'Instance type',instance,'in ',region,'in ',role,'is really old!'
					pass
				cost = counts[instance]*float(price_instance_region)
				if print_region_details == True:
					print instance, counts[instance],  price_instance_region, cost
				statsdc.gauge('count.'+role+'.'+region+'.'+instance, counts[instance])
				statsdc.gauge('cost.'+role+'.'+region+'.'+instance, cost)
				region_cost[instance] = cost
				region_cost_total = sum(region_cost.values())

			print role, region, 'cost is', region_cost_total
			role_cost[region] = region_cost_total
			
	print
	role_instances_count = len(all_instances)-count_before_role
	print role,'count =',role_instances_count	
	print role,'cost =',sum(role_cost.values())
	ec2_cost[role] = sum(role_cost.values())
all_instance_count = len(all_instances)	
all_instance_cost = sum(ec2_cost.values())
print 'total instance count =',all_instance_count
print 'total instance cost =',all_instance_cost
statsdc.gauge('count.all.global.ec2',all_instance_count)
statsdc.gauge('cost.all.global.ec2', all_instance_cost)

run_time = time.time() - start_time
m, s = divmod(run_time,60)
print 'Total time take to generate this report -', m, 'mins,',s,'secs'
statsdc.timing('report.runtime',int(run_time*1000))