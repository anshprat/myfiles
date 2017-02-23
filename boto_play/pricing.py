import json
import sys

def get_price(type):
	with open('pricing-'+type+'.json') as data_file:
		data=data_file.read()

	p_data = json.loads(data)
	region_count = len(p_data['config']['regions'])
	# print region_count
	file_keywords = {'ec2':{'instanceTypes':['sizes','size','valueColumns']},
					 'ebs':{'types':['name','prices','values']}
					}
	kw1 = file_keywords[type].keys()[0]
	kw2 = file_keywords[type][file_keywords[type].keys()[0]][0]
	kw3 = file_keywords[type][file_keywords[type].keys()[0]][1]
	kw4 = file_keywords[type][file_keywords[type].keys()[0]][2]

	ebs_types = {'Amazon EBS General Purpose SSD (gp2) volumes':'gp2',
				 'Amazon EBS Provisioned IOPS SSD (io1) volumes':'io1',
				 'Amazon EBS Throughput Optimized HDD (st1) volumes':'st1',
				 'Amazon EBS Cold HDD (sc1) volumes':'sc1',
				 'ebsSnapsToS3':'ebsSnapsToS3'
				}
	ebs_rate_types = {'perGBmoProvStorage':'gb',
					  'perPIOPSreq':'iops',
					  'perGBmoDataStored':'gb'
					}
	# >>> p_data['config']['regions'][0]['region']
	# u'us-east-1'

	regional_data = p_data['config']['regions']
	# regional_data[0]['instanceTypes'][0]['sizes'][0]['valueColumns'][0]['prices']['USD']
	# u'0.0059'
	# >>> regional_data[0]['instanceTypes'][0]['sizes'][0]['size']
	# u't2.nano'

	price_dict = {}

	for reg_index in list(range(region_count)):
		# Gets inside a region
		region = regional_data[reg_index]['region']
		region_price = {}
		instanceTypes = regional_data[reg_index][kw1]
		for instanceTypeIndex in list(range(len(instanceTypes))):
			#t2
			if (type == 'ec2'):
				sizes_index = len(instanceTypes[instanceTypeIndex][kw2])
				for size_index in list(range(sizes_index)):
					instanceSize = instanceTypes[instanceTypeIndex][kw2][size_index][kw3]
					price = instanceTypes[instanceTypeIndex][kw2][size_index][kw4][0]['prices']['USD']
					region_price[instanceSize] = price
		# print reg_index
			if (type == 'ebs'):
				sizes_index = 1
				for size_index in list(range(sizes_index)):
					ebsType = ebs_types[instanceTypes[instanceTypeIndex][kw2]]
					count_prices = len(instanceTypes[instanceTypeIndex][kw4])
					region_price[ebsType] = {}
					for price_index in range(count_prices):
						price_obj = instanceTypes[instanceTypeIndex][kw4][price_index]
						rate_t = str(price_obj['rate'])
						price_t = float(price_obj['prices']['USD'])
						region_price[ebsType].update({ebs_rate_types[rate_t]:price_t})

		price_dict[region] = region_price


		# sys.exit()
	return price_dict

price_dict_ec2 = get_price('ec2')
price_dict_ebs = get_price('ebs')
