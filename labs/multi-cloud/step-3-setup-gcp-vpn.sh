function install_prerequisites() {
    sudo yum install -y jq
    sudo yum install -y wget
}

# Function to check if Terraform is installed already, if not, then download and installed the version of Terraform as required.
function install_terraform() {
    # Sticking to Terraform v1.1.7 as it was used for the development of this code-base
    TERRAFORM_VERSION="1.1.9"

    # Check if terraform is already installed and display the version of terraform as installed
    [[ -f ${HOME}/bin/terraform ]] && echo "`${HOME}/bin/terraform version` already installed at ${HOME}/bin/terraform" && return 0

    TERRAFORM_DOWNLOAD_URL=$(curl -sL https://releases.hashicorp.com/terraform/index.json | jq -r '.versions[].builds[].url' | egrep 'linux.*amd64' | egrep "${TERRAFORM_VERSION}" | egrep -v 'rc|beta|alpha')
    TERRAFORM_DOWNLOAD_FILE=$(basename $TERRAFORM_DOWNLOAD_URL)

    echo "Downloading Terraform v$TERRAFORM_VERSION from '$TERRAFORM_DOWNLOAD_URL'"

    # Download and install Terraform v1.1.7 as that is the version used for the development of this code-base.
    # TODO: Once Base and Ceiling versions have been validated, the code here will be modified to download the Ceiling version of terraform as required by the scripts in this code-base.
    mkdir -p ${HOME}/bin/ && cd ${HOME}/bin/ && wget $TERRAFORM_DOWNLOAD_URL && unzip $TERRAFORM_DOWNLOAD_FILE && rm $TERRAFORM_DOWNLOAD_FILE

    # Display an confirmation of the successful installation of Terraform.
    echo "Installed: `${HOME}/bin/terraform version`"
}

function deploy_gcp_vpn_step_3_lab() {
    PROJECT_ID=$(gcloud projects list --filter='name:qwiklab-MULTICLOUD-LAB' --format="value(projectId)")
    VARS_FILENAME="${HOME}/panw-lab-hybrid-multi-cloud/labs/multi-cloud/gcp-vpn/terraform.tfvars"

    echo "Updating the Project ID to ${PROJECT_ID}"
    sed -i "s/__project_id__/$PROJECT_ID/" $VARS_FILENAME

    # Assuming that this setup script is being run from the cloned github repo, changing the current working directory to one from where Terraform will deploy the lab resources.
    cd "${HOME}/panw-lab-hybrid-multi-cloud/labs/multi-cloud/gcp-vpn"

    # Initialize terraform
    echo "Initializing directory for lab resource deployment"
    terraform init

    # Deploy resources
    echo "Deploying Resources required for the VPN connection between GCP and AWS."
    terraform apply -auto-approve

    if [ $? -eq 0 ]; then
        echo "VPN connection established between GCP and AWS successfully!"
    else
        echo "There was a problem while deploying the cloud resources for the VPN connection between GCP and AWS!"
        exit 1
    fi
}

#install_prerequisites
#install_terraform
deploy_gcp_vpn_step_3_lab