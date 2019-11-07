#!/bin/bash
basepath=$(cd `dirname $0`; pwd)
modules=(apollo-configservice apollo-adminservice  apollo-portal)
for module in ${modules[@]}
do
	sh $basepath/startup.sh $module $1
done