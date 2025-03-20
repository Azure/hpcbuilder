
## Overview

The primary goal of this project is to offer an example for building HPC infrastructure with Terraform. HPCBuilder emphasizes the essential components needed to build an HPC environment and the proper sequence for their creation.  

## Features

- **Terraform Modules**: Examples of reusable infrastructure as code (IaC) modules for deploying HPC resources.
- **Security Management**: Example modules for creating and managing secure passwords and SSH keys using Azure Key Vault.
- **Customization**: Example of flexible configuration options to tailor the HPC environment to specific requirements.

Most projects typically deploy all infrastructure at once, but this project is designed differently. Each folder represents a step to create a required component, emphasizing a more modular and step-by-step approach to infrastructure deployment. This approach is mainly to encourage learning and to provide flexibility in testing individual components. 


## Getting Started

To get started with HPCBuilder, you can clone the repository and follow the instructions in the provided `README.md` files for each step. Below is a general guide to help you begin:

1. Clone the repository:
   ```bash
   git clone https://github.com/Azure/hpcbuilder.git
   cd hpcbuilder/tf/<step> # Follow README of each step for deployment

## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft 
trademarks or logos is subject to and must follow 
[Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/en-us/legal/intellectualproperty/trademarks/usage/general).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.
Any use of third-party trademarks or logos are subject to those third-party's policies.
