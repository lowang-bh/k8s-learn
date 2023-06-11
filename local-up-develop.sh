
ret=$(kind get clusters)
if [ -z "$ret" ]; then
    echo  "bring up kind cluster"
    cd  ~/go/src/github.com/lowang-bh/demo/kind
    kind create cluster --config cluster-v1.26.yaml
else
    echo "already exist cluster: $ret"
fi

echo "install training-operator"
cd ~/go/src/github.com/kubeflow/training-operator
kind load docker-image kubeflow/training-operator:latest kubeflow/training-operator:latest
kubectl apply -k  manifests/overlays/standalone/

echo "install volcano"
helm install volcano installer/helm/chart/volcano --namespace volcano-system --create-namespace
