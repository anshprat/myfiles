# AWS RO restricts it to pure RO only. There could be actions like decrypt which are logically RO but need write scope in AWS. 
# This is to get various such actions that we need for a complete "Admin-RO" mode.

set +x 

POLICIES_FILE=policies.js
ACTIONS_FILE=action.txt
FILE_LOCATION="$HOME/tmp"
ADMIN_RO_ACTIONS=admin-ro-actions.txt
ADMIN_RO_ACTIONS_INDEX=admin-ro-actions-index.txt


mkdir -p ${FILE_LOCATION}
cd ${FILE_LOCATION}
if [ ! -f ${POLICIES_FILE} ]
then
    curl https://awspolicygen.s3.amazonaws.com/js/policies.js -o ${POLICIES_FILE}
fi

cat ${POLICIES_FILE} | cut -d= -f2 |
jq -r '.serviceMap[] | .StringPrefix as $prefix | .Actions[] | "\($prefix):\(.)"' |
sort | uniq >${ACTIONS_FILE}


# Use the below to get list of all verbs and then do manual curation on that.
# cat ${ACTIONS_FILE} | cut -f 2 -d ':'|grep -oE '^[A-Z][a-z]+'|sort|uniq

# Manually curated verbs
for v in Assume Check Count Decrypt Discover Domain Download Evaluate Get List Lookup Monitor Preview Read Render Report Sample Scan Search Select Test Verify View 

do
    grep ":$v" ${ACTIONS_FILE}
done > ${ADMIN_RO_ACTIONS}

cat ${ADMIN_RO_ACTIONS}| grep -oE '[a-z].*\:[A-Z][a-z]+' |sort|uniq | sed 's/.*/&\*/' > ${ADMIN_RO_ACTIONS_INDEX}

cat ${ADMIN_RO_ACTIONS_INDEX} 