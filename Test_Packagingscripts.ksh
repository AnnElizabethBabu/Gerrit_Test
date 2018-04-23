#------------
export REPO=/omr/git/aia/AIA_Repo
export WORKSPACE=/omr/git/aia/AIA_Repo/aia_ws
export VERSION_NAME=AIA_VN_v11.00.00.26
export ARCHIVE_HOME=${WORKSPACE}/${VERSION_NAME}
mkdir -p ${WORKSPACE}/source/${VERSION_NAME}
mkdir -p ${WORKSPACE}/scripts
mkdir -p ${ARCHIVE_HOME}/data
cp -r ${REPO}/tags/TEST/AIA/AIA_APPL/${VERSION_NAME} ${WORKSPACE}/source/${VERSION_NAME}
cp -r ${REPO}/branches/Project_DevOps/PackagingScripts/AIA/* ${WORKSPACE}/scripts
cp -r ${REPO}/branches/Project_DevOps/DeploymentScripts/AIA/AIA_APPL ${WORKSPACE}/scripts/AIA_APPL
cp -r ${REPO}/branches/Project_DevOps/PackagingScripts/Common ${WORKSPACE}/scripts/common
cp -r ${WORKSPACE}/source/${VERSION_NAME}/* ${ARCHIVE_HOME}/data
#Copy BL scripts and other files to package
cd ${WORKSPACE}/scripts/AIA_APPL
cp *.ksh ${ARCHIVE_HOME}
#dos2unix ${ARCHIVE_HOME}/*.ksh
cp *.py ${ARCHIVE_HOME}
cp Sample.SIG ${ARCHIVE_HOME}/${VERSION_NAME}.SIG
cp *sh ${ARCHIVE_HOME}
cp -r ${WORKSPACE}/scripts/AIA_APPL/data/* ${ARCHIVE_HOME}/data/.
#cp -r ${WORKSPACE}/source/${VERSION_NAME}/source/manual_steps ${ARCHIVE_HOME}/data
cd ${ARCHIVE_HOME}/data
mkdir SOACompApps
FILES=config/*
for f in $FILES
do
  echo "Replacing PCKNAME in $f file..."
  sed -i "s/{VERSION_NAME}/${VERSION_NAME}/g" $f
done
 
sed -i "s/{VERSION_NAME}/${VERSION_NAME}/g" UpdateMetaDataDP_FULL.xml
 
#parse the CustomDp
cp ${ARCHIVE_HOME}/data/${VERSION_NAME}/deploymentplans/O2CCustomDP.xml ${WORKSPACE}/scripts/.
chmod 777 ${WORKSPACE}/scripts/parse.sh
#dos2unix ${WORKSPACE}/scripts/parse.sh
cd ${WORKSPACE}/scripts
${WORKSPACE}/scripts/parse.sh 
 
#copy the CustomDp 
cp ${ARCHIVE_HOME}/data/${VERSION_NAME}/deploymentplans/O2CCustomDP.xml ${ARCHIVE_HOME}/data/.
 
#remove extra folders/files
echo "removing"
cd ${ARCHIVE_HOME}
#rm -rf .svn
cd data
rm -rf  services deploymentplans
#rm -rf ${ARCHIVE_HOME}/data/AIAMetaData/config/AIAEHNotification.xml
#rm -rf ${ARCHIVE_HOME}/data/AIAMetaData/config/AIAInstallProperties.xml
 
#tar the package
cd ${ARCHIVE_HOME}
 
#dos2unix data/config/*
#dos2unix data/env/*
tar -cvzf ${VERSION_NAME}.tar.gz *
mv ${VERSION_NAME}.tar.gz ${WORKSPACE}
cp ${WORKSPACE}/${VERSION_NAME}.tar.gz /omr/git/aia/deployment_dir/deployment/package/.
cp ${WORKSPACE}/sequence/* /omr/git/aia/deployment_dir/deployment/package/. 
APP=`echo "${VERSION_NAME}" | cut -f1 -d'_'`
PKG=`echo "${VERSION_NAME}" | cut -f2 -d'_'`
PKG_TYPE=${APP}_${PKG}
