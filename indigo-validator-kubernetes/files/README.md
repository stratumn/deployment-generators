# Indigo Validator Kubernetes Deployment

This project contains files to deploy an Indigo validator to Kubernetes. It assumes a Kubernetes cluster is already running.

If you are deploying an agent, it also assume a self-contained image has been built and published.

### Setting up a test Kubernetes cluster on MacOS using Homebrew

Install the tools:

```bash
brew install docker-machine-driver-xhyve kubectl
brew cask install minikube
```

Setup the permissions:

```bash
sudo chown root:wheel $(brew --prefix)/opt/docker-machine-driver-xhyve/bin/docker-machine-driver-xhyve
sudo chmod u+s $(brew --prefix)/opt/docker-machine-driver-xhyve/bin/docker-machine-driver-xhyve
```

Launch the local cluster:

```bash
minikube start --vm-driver=xhyve --extra-config=apiserver.ServiceNodePortRange=3000-50000
```

The flag `--extra-config=apiserver.ServiceNodePortRange=3000-50000` is important otherwise Kubernetes will not let services bind to ports below 30000.

Make sure the `default-storageclass` addon is enabled:

```bash
minikube addons list
```

Otherwise enable it:

```bash
minikube addons enable default-storageclass
```

This will make sure a volume is automatically created when we a container needs an external volume.

## Usage

This project contains files for one validator. Each stakeholder should generate his own deployment files.

**NOTE**: If multiple participants are deploying to the same Kubernetes cluster, make sure to use a different namespace for each one. Also, currently, if you are using Minikube on macOS, only one participant should deploy an agent otherwise the ports will conflict.

### Generate keys

Before deploying a network, each validator should privately generate Tendermint keys. You can use the script included in the project to do so:

```bash
mkdir -p tendermint/private

./utils/gen_validator.sh > tendermint/private/priv_validator.json
```

Then you have to extract the public key from the generated file:

```bash
brew install jq # for JSON manipulation

mkdir tendermint/public

./utils/get_pub_key.sh tendermint/private/priv_validator.json > tendermint/public/pub_key.json
```

The next step is to gather the public key of each validator. Put all the public keys in the same folder, for instance in `tendermint/validators`, then generate the genesis file:

```bash
mkdir tendermint/validators
cp tendermint/public/pub_key.json tendermint/validators/pub_key_alice.json
# Copy all the other public keys as well.

./utils/gen_genesis.sh tendermint/validators/*.json > tendermint/public/genesis.json
```

Next create a list of validator host names. The validators need to be able to talk to each other. The validator host for a participant has the form `validor-0.validation.{namespace}.svc.{cluster-domain}`. The default cluster domain used by Minikube is `cluster.local`.

```bash
# Validators need to be able to talk to each other.
VALIDATORS='validator-0.validation.alice.svc.cluster.local validator-0.validation.bob.svc.cluster.local validator-0.validation.carla.svc.cluster.local validator-0.validation.denis.svc.cluster.local'

echo $VALIDATORS > tendermint/public/validators
```

If you want to add segment validation rules, add `rules.json` to the `tendermint/public` folder.

### Push configs and secrets to Kubernetes

Each validator needs to set Kubernetes configs and secret.

```bash
# Create your namespace if needed.
kubectl create namespace alice

kubectl create -n alice secret generic tendermint --from-file=tendermint/private

kubectl create -n alice configmap tendermint --from-file tendermint/public
```

Each validator should replace the namespace (alice) with the correct one.

### Deploy the application

Now each validator can deploy to his cluster/namespace (replace production with the environment you chose will generating the project):

```bash
strat deploy production
```

Deployment can take a few minutes.

## Minikube cheatsheet

Launch dashboard:
```bash
kubectl dashboard
```

Launch Agent UI (replace alice with correct namespace):
```bash
minikube service -n alice agent-ui
```

Delete namespace (replace alice with correct namespace):
```bash
kubectl delete namespace alice
```
