USER_ALIAS=DataMaskProd
PACKAGE_NAME=dataMaskCompliance	
# export unmanaged package into temp dir
mkdir temp
sfdx force:mdapi:retrieve -s -r ./temp -u $USER_ALIAS -p $PACKAGE_NAME
unzip ./temp/unpackaged.zip -d ./temp/
# convert Meta-data API source to Salesforce DX project structure
sfdx force:mdapi:convert -r ./temp -d ../force-app/
# delete temp dir
rm -rf ./temp
