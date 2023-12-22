
ret=$(kind get clusters|head -n 1)
if [ -z "$ret" ]; then
    echo  "bring up kind cluster"
    cd  ~/go/src/github.com/lowang-bh/demo/kind
    kind create cluster --config cluster-v1.27.yaml
    ret=$(kind get clusters|head -n 1)
else
    echo "already exist cluster: $ret"
fi

echo "install training-operator"
cd ~/go/src/github.com/kubeflow/training-operator
kind load docker-image kubeflow/training-operator:latest kubeflow/training-operator:latest --name ${ret}
kubectl apply -k  manifests/overlays/standalone/

echo "install volcano"
#helm install volcano installer/helm/chart/volcano --namespace volcano-system --create-namespace
cd ~/go/src/github.com/volcano-sh/volcano
kind load docker-image volcanosh/vc-webhook-manager:v1.7.0 volcanosh/vc-webhook-manager:v1.7.0 --name ${ret}
kind load docker-image volcanosh/vc-scheduler:v1.7.0 volcanosh/vc-scheduler:v1.7.0 --name ${ret}
kind load docker-image volcanosh/vc-controller-manager:v1.7.0 volcanosh/vc-controller-manager:v1.7.0 --name ${ret}
sed -E "s#(image: volcanosh.*)(latest)#\1v1.7.0#; s#imagePullPolicy: Always#imagePullPolicy: IfNotPresent#" installer/volcano-development.yaml | kubectl apply -f -
