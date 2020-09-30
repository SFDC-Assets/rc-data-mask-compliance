USER_ALIAS="${USER_ALIAS:-sfdx-data-mask-compliance__dev}"
# perm set 1
PERM_SET=RC_Data_Mask_Compliance
echo assigning permission set $PERM_SET to USER_ALIAS = $USER_ALIAS
sfdx force:user:permset:assign -n $PERM_SET -u $USER_ALIAS
# perm set 2
#PERM_SET=datamask
#echo assigning permission set $PERM_SET to USER_ALIAS = $USER_ALIAS
#sfdx force:user:permset:assign -n $PERM_SET -u $USER_ALIAS