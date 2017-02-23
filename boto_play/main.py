import time
start_time = time.time()
import boto3 as boto
import boto3
from collections import Counter
from itertools import chain
from pricing import price_dict_ec2, price_dict_ebs
import sys
import statsd
from time import gmtime, strftime

print strftime("%a, %d %b %Y %H:%M:%S +0000", gmtime())
# print price_dict_ebs
# sys.exit()

statsd_prefix = 'costrack.aws'
print_region_details = False
print_ebs_details = False
check_ec2 = True

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
ec2_cost_multiplier=24*30
separator=', '
# Get regions using Identity Account
client = boto3.client('ec2', region_name=def_region)
regions = [region['RegionName'] for region in client.describe_regions()['Regions']]

def print_d(l,s,m):
	if print_debug == True:
		level = {'D':'DEBUG'}
		print '[',level[l],']',s,':',m
def calc_ebs_cost(r,s,i,t):
	if t == 'standard':
		t = 'gp2'
	if t != 'io1':
		return round(price_dict_ebs[r][t]['gb']*s,2)
	else:
		return round((price_dict_ebs[r][t]['gb']*s)+((price_dict_ebs[r][t]['iops']*i)),2)

sts_client = boto3.client('sts')
ec2_cost = {}
ebs_cost = {}
all_instances = {}
all_ebs = {}
keyPrint = 'Processing '

for role in roles_dict:
	role_cost = {}
	role_cost_ebs = {}
	count_before_role = len(all_instances)
	assumedRoleObject = sts_client.assume_role(
	    RoleArn=roles_dict[role],
	    RoleSessionName=role
	)

	credentials = assumedRoleObject['Credentials']
	for region in regions:
		# print keyPrint, role, region 
		header=role,separator,region
		header=''.join(header)
		print '.',
		sys.stdout.flush()
		ec2 = boto3.resource('ec2', 
			region_name=region,
			aws_access_key_id = credentials['AccessKeyId'],
    		aws_secret_access_key = credentials['SecretAccessKey'],
    		aws_session_token = credentials['SessionToken'],
		)
		# print role,region

		region_ebs = {}
		ebs = ec2.volumes.all()
		# Filters=[{'Name': 'status','Values': ['available',]}]
		for v in ebs:
			# if v.state == 'available':
			# 	print v.id
			# sys.exit()
			# region_ebs[v.id]=[v.size,v.volume_type,v.iops]
			region_ebs[v.id] = {'v':v.volume_type, 's':v.size, 'i':v.iops,'c':calc_ebs_cost(region,v.size,v.iops,v.volume_type)}
			if print_ebs_details == True:
				print v.id, region_ebs[v.id]

		# print ebs
		if len(region_ebs)>0:
			region_ebs_c = {}
			# print region_ebs
			for v in region_ebs:
				region_ebs_c[v] = region_ebs[v]['c']
				# print 'DEBUG: Individual cost',region_ebs[v]['c']
			region_ebs_cost = sum(region_ebs_c.values())
			# print 'DEBUG: region_ebs_cost cost',region_ebs_cost
			print '\n',header,separator,'ebs',separator,'cost',separator,region_ebs_cost
			statsdc.gauge('cost.'+role+'.'+region+'.ebs.', region_ebs_cost)
			role_cost_ebs[region] = sum(region_ebs_c.values())
			# print 'DEBUG: role_cost_region',role_cost_ebs[region]
		
		# Process EC2 onlt if EBS exists, else its a waste of time
		if len(region_ebs)>0 and check_ec2 == True:
			instances = ec2.instances.filter(
			    Filters=[{'Name': 'instance-state-name', 'Values': ['running']}])
			this_region = {}
			for instance in instances:
				# print role,region,instance.id
				this_region[instance.id]=instance.instance_type
			all_instances.update(this_region)
			    #instance.id, instance.instance_type)
			instance_count = len(this_region)
			if instance_count > 0: # This check is now redundant since its checked above at EBS count
				# print 
				region_cost = {}
				print header,separator,'ec2',separator,'count',separator,instance_count
				counts = Counter(this_region.itervalues())
				for instance in list(counts):
					#price of this instance type count
					try:
						price_instance_region = price_dict_ec2[region][instance]
					except KeyError:
						# print 'Instance type',instance,'in ',region,'in ',role,'is really old!'
						pass
					cost_instance_type = counts[instance]*float(price_instance_region)*ec2_cost_multiplier
					if print_region_details == True:
						print instance, counts[instance],  price_instance_region, cost_instance_type
					statsdc.gauge('count.'+role+'.'+region+'.ec2.'+instance, counts[instance])
					statsdc.gauge('cost.'+role+'.'+region+'.ec2.'+instance, cost_instance_type)
					region_cost[instance] = cost_instance_type
					region_cost_total = sum(region_cost.values())

				print header,separator,'ec2',separator,'cost',separator, region_cost_total
				role_cost[region] = region_cost_total
			
	print
	ebs_cost[role] = sum(role_cost_ebs.values())
	role_instances_count = len(all_instances)-count_before_role
	if check_ec2 == True:	
		print role,separator,'global',separator,'ec2',separator,'count',separator,role_instances_count	
		print role,separator,'global',separator,'ec2',separator,'cost',separator,sum(role_cost.values())
	print role,separator,'global',separator,'ebs',separator,'cost',separator,ebs_cost[role]
	ec2_cost[role] = sum(role_cost.values())
all_instance_count = len(all_instances)	
all_instance_cost = sum(ec2_cost.values())
all_ebs_cost = sum(ebs_cost.values())
print
if check_ec2 == True:
	print 'all roles',separator,'global',separator,'ec2',separator,'count',separator,all_instance_count
	print 'all roles',separator,'global',separator,'ec2',separator,'cost',separator,all_instance_cost
print 'all roles',separator,'global',separator,'ebs',separator,'cost',separator,all_ebs_cost

statsdc.gauge('count.all.global.ec2',all_instance_count)
statsdc.gauge('cost.all.global.ec2', all_instance_cost)
statsdc.gauge('cost.all.global.ebs', all_ebs_cost)

run_time = time.time() - start_time
m, s = divmod(run_time,60)
print 'Total time taken to generate this report -', int(m), 'mins',separator,int(s),'secs'
statsdc.timing('report.runtime',int(run_time*1000))