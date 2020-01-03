#!/bin/sh

# apollo config db info
apollo_config_db_url='jdbc:mysql://10.160.81.18:6001/ApolloConfigDB?serverTimezone=Asia/Shanghai&characterEncoding=utf8&useUnicode=true&useSSL=false&zeroDateTimeBehavior=convertToNull'
apollo_config_db_username='tester'
apollo_config_db_password='nopass.2'

# apollo portal db info
apollo_portal_db_url='jdbc:mysql://10.160.81.18:6001/ApolloPortalDB?serverTimezone=Asia/Shanghai&characterEncoding=utf8&useUnicode=true&useSSL=false&zeroDateTimeBehavior=convertToNull'
apollo_portal_db_username='tester'
apollo_portal_db_password='nopass.2'

# meta server url, different environments should have different meta server addresses
dev_meta=http://dev.meta.apollo.com
test_meta=http://test.meta.apollo.com
pre_meta=http://pre.meta.apollo.com
pro_meta=http://pro.meta.apollo.com

META_SERVERS_OPTS="-Ddev_meta=$dev_meta -Dfat_meta=$fat_meta -Duat_meta=$uat_meta -Dpro_meta=$pro_meta"

# =============== Please do not modify the following content =============== #
# go to script directory
cd "${0%/*}"

cd ..

# package config-service and admin-service
echo "==== starting to build config-service and admin-service ===="

mvn clean package -DskipTests -pl apollo-configservice,apollo-adminservice -am -Dapollo_profile=github -Dspring_datasource_url=$apollo_config_db_url -Dspring_datasource_username=$apollo_config_db_username -Dspring_datasource_password=$apollo_config_db_password

echo "==== building config-service and admin-service finished ===="

echo "==== starting to build portal ===="

mvn clean package -DskipTests -pl apollo-portal -am -Dapollo_profile=github,auth -Dspring_datasource_url=$apollo_portal_db_url -Dspring_datasource_username=$apollo_portal_db_username -Dspring_datasource_password=$apollo_portal_db_password $META_SERVERS_OPTS

echo "==== building portal finished ===="

echo "==== start dist jar ===="
basepath=$(cd `dirname $0`;cd ../; pwd)
version=1.6.0-SNAPSHOT
modules=(apollo-configservice apollo-adminservice  apollo-portal)
for module in ${modules[@]}
do
cp $basepath/$module/target/$module-$version.jar ./dist
done

cp $basepath/scripts/*.sh $basepath/dist
chmod u+x $basepath/dist/*.sh
