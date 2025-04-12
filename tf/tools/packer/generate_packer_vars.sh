#!/bin/bash

THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASE_CONFIG="$THIS_DIR/../../0_base/cfg/base_config.yml"
NETWORK_CONFIG="$THIS_DIR/../../1_network/cfg/vnet_config.yml"
STORAGE_CONFIG="$THIS_DIR/../../2_storage/cfg/storage_config.yml"

# Define output file for Packer variables
PACKER_VARS_FILE="$THIS_DIR/variables.auto.pkrvars.hcl"
PACKER_IMG_DEFS="$THIS_DIR/packer_image_definitions.yml"

if [ $# -lt 2 ]; then
  echo "Usage build_image.sh "
  echo "  Required arguments:"
  echo "    -i|--image <image_file> | image packer file"
  exit 1
fi

while (( "$#" )); do
  case "${1}" in
    -i|--image)
      PACKER_FILE=${2}
      shift 2
    ;;
    *)
      shift
      ;;
  esac
done

if [ ! -f ${PACKER_FILE} ]; then
  echo "Packer file ${PACKER_FILE} not found"
  exit 1
fi

# Extract values from YAML configuration files
SUBSCRIPTION_ID=$(az account show --query 'id' -o tsv)
RG_NAME=$(yq eval '.core-rg.name' $BASE_CONFIG)
SSH_USER=$(yq eval '.admin.username' $BASE_CONFIG)
VAULT=$(yq eval '.keyvault.name' $BASE_CONFIG)
VAULT_RG_NAME=$(yq eval '.keyvault.rg' $BASE_CONFIG)

if [ "$VAULT_RG_NAME" == "null" ]; then
    VAULT_RG_NAME="$RG_NAME"
fi

VNET=$(yq eval '.vnet.name' $NETWORK_CONFIG)
SUBNET=$(yq eval '.vnet.subnets.infra.name' $NETWORK_CONFIG)
VNET_RG_NAME=$(yq eval '.vnet.rg' $NETWORK_CONFIG)

if [ "$VNET_RG_NAME" == "null" ]; then
    VNET_RG_NAME="$RG_NAME"
fi

GALLERY_NAME=$(yq eval '.image_gallery.name' $STORAGE_CONFIG)
IMAGE_NAME=$(basename "$PACKER_FILE")
IMAGE_NAME="${IMAGE_NAME%.*.*}"
OFFER=$(yq eval ".images[] | select(.name == \"$IMAGE_NAME\") | .offer" $PACKER_IMG_DEFS)
PUBLISHER=$(yq eval ".images[] | select(.name == \"$IMAGE_NAME\") | .publisher" $PACKER_IMG_DEFS)
SKU=$(yq eval ".images[] | select(.name == \"$IMAGE_NAME\") | .sku" $PACKER_IMG_DEFS)
OS_VERSION=$(yq eval ".images[] | select(.name == \"$IMAGE_NAME\") | .version" $PACKER_IMG_DEFS)
OS_TYPE=$(yq eval ".images[] | select(.name == \"$IMAGE_NAME\") | .os_type" $PACKER_IMG_DEFS)
HYPERVISOR=$(yq eval ".images[] | select(.name == \"$IMAGE_NAME\") | .hypervisor" $PACKER_IMG_DEFS)
SECURITY=$(yq eval ".images[] | select(.name == \"$IMAGE_NAME\") | .security" $PACKER_IMG_DEFS)
IMAGE_VERSION=$(date -u +"%Y.%m%d.%H%M")

# use an azure cli command to get the ssh key secret from the key vault
echo "az keyvault secret show --name "$SSH_USER-ssh-private-key" --vault-name "$VAULT" --query 'value' -o tsv"
SSH_KEY_SECRET=$(az keyvault secret show --name "$SSH_USER-ssh-private-key" --vault-name "$VAULT" --query 'value' -o tsv)
if [ -z "$SSH_KEY_SECRET" ]; then
    echo "Error: SSH key secret not found in Key Vault $VAULT"
    exit 1
fi

SSH_PRIVATE_KEY="$THIS_DIR/packer_key"

# Write the SSH key secret to a file
echo "$SSH_KEY_SECRET" > "$SSH_PRIVATE_KEY"
chmod 600 "$SSH_PRIVATE_KEY"
# Check if the SSH key file was created successfully
if [ ! -f "$SSH_PRIVATE_KEY" ]; then
    echo "Error: Failed to create SSH key file at $SSH_PRIVATE_KEY"
    exit 1
fi

IMG_DEF_ID=$(az sig image-definition list -r $GALLERY_NAME -g $RG_NAME --query "[?name=='$IMAGE_NAME'].id" -o tsv)

if [ "$IMG_DEF_ID" == "" ]; then
    echo "Image definition $IMAGE_NAME not found in image gallery $GALLERY_NAME. Creating a new image definition."

    az sig image-definition create -r $GALLERY_NAME -i $IMAGE_NAME -g $RG_NAME \
                -f $OFFER --os-type $OS_TYPE -p $PUBLISHER -s $SKU --hyper-v-generation $HYPERVISOR \
                --features "SecurityType=$SECURITY IsAcceleratedNetworkSupported=true" 
fi

# Write variables to Packer variables file
cat <<EOF > $PACKER_VARS_FILE
subscription_id = "$SUBSCRIPTION_ID"
rg_name         = "$RG_NAME"
gallery_name    = "$GALLERY_NAME"
image_name      = "$IMAGE_NAME"
image_version   = "$IMAGE_VERSION"
vnet            = "$VNET"
subnet          = "$SUBNET"
vnet_rg_name    = "$VNET_RG_NAME"
ssh_user        = "$SSH_USER"
private_key     = "$SSH_PRIVATE_KEY"
managed_image_name = "$IMAGE_NAME-${IMAGE_VERSION//./-}"
os_type       = "$OS_TYPE"

EOF



#echo "Packer variables file created at $PACKER_VARS_FILE"
