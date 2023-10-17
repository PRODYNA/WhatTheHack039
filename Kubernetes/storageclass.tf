// Create a managed-premium-zrs storage class that can be used for RWO volumes with the feature that the data is replicated across three zones in the region.
resource "kubectl_manifest" "premium-zrs" {
  yaml_body = <<EOF
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: managed-premium-zrs
provisioner: disk.csi.azure.com
parameters:
  skuName: Premium_ZRS
reclaimPolicy: Retain
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
EOF
}