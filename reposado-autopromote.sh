#!/bin/bash

# ======================================
# reposado-autopromote.sh
#
# Script to autopromote items through branches
#
# This script is setup to run daily to give one day between branches. However, schedule
# the cron to increase the days between promotion.
# Some code borrowed from https://github.com/clburlison/scripts/tree/master/clburlison_scripts/reposado
# who borrowed from other places.
# ======================================

# set the number of branches to keep
number_of_branches=4
repo_dir='/bin/reposado/code/'


repoutil=${repo_dir}'repoutil'
repo_sync=${repo_dir}'repo_sync'

${repo_sync}

base_branch='0'

while [[ ${number_of_branches} -gt 0 ]];
do
    number_of_branches=$(( ${number_of_branches}-1 ))
    ${repoutil} --copy-branch=${number_of_branches} $(( ${number_of_branches}+1 )) --force
done

# Add any new products to the base branch
newProductsFull=(`${repoutil} --products | grep -e " \[\] \$"`)
if [[ ${#newProductsFull[@]} -eq 0 ]]; then
	echo "No new products"
else
    for (( i=0; i<${#newProductsFull[@]}; i++ )); do
        echo ${newProductsFull[$i]}
    done
    ${repoutil} --add-products ${newProducts[@]} ${base_branch}
fi

# Iterates through the output that shows deprecated items in the base branch.
i=0
for item in $(${repoutil} --list-branch=${base_branch} | awk '/Deprecated/{ print $1 }'); do
    deprecatedProducts[$i]=$item
    let i++
done

echo ${deprecatedProducts[*]}

# Removes deprecated products
${repoutil} --remove-products=${deprecatedProducts[*]} ${base_branch}