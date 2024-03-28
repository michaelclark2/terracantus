# terracantus

A platform to share field recordings

## Setup environment

- Install and setup [direnv](https://direnv.net/)
- Install and setup [pyenv](https://github.com/pyenv/pyenv)
- Install and setup [terraform](https://developer.hashicorp.com/terraform/install)
- Run `direnv allow`
- Run `pyenv install 3.11`
- Run `pyenv virtualenv 3.11 terracantus`
- Run `pip install -r requirements.dev.txt`
- Run `invoke init` the first time to setup the app

To setup infrastructure

- `cd infra`
- `direnv allow`
- `terraform init`
- `terraform apply`

To start the dev server

- `invoke dev`
