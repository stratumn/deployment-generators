# Indigo Validator Kubernetes Deployment Generator

Each stakeholder in a network can use this generator to deploy an Indigo validator to a Kubernetes cluster.

**NOTE**: If multiple participants are deploying to the same Kubernetes cluster, make sure to use a different namespace for each one. Also, currently, if you are using Minikube on macOS, only one participant should deploy an agent otherwise the ports will conflict. This will not be a problem once Agent UI doesn't hardcode the port of the agent.

## Usage:

```bash
strat generate --generators-repo deployment-generators --generators-ref master path/to/outout/dir

cd path/to/outout/dir
```

Then read the generated `README.md` file.
