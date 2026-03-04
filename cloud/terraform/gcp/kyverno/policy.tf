resource "helm_release" "kyverno_policies" {
	chart="raw"
	count=var.spot ? 1 : 0
	depends_on=[helm_release.kyverno]
	name="kyverno-policies"
	namespace=kubernetes_namespace_v1.kyverno.metadata[0].name
	repository="https://bedag.github.io/helm-charts/"

	values=[
		yamlencode({
			resources=[
				{
					apiVersion="kyverno.io/v1"
					kind="ClusterPolicy"
					metadata={
						annotations={
							"policies.kyverno.io/category"="Cost Optimization"
							"policies.kyverno.io/description"="Automatically prefers GKE spot nodes for all Pods but allows fallback to standard nodes."
							"policies.kyverno.io/title"="Prefer Spot Nodes"
						}
						name="prefer-spot-nodes"
					}
					spec={
						background=false
						rules=[
							{
								exclude={
									any=[
										{
											resources={
												namespaces=[
													"gatekeeper-system",
													"gke-system",
													"kube-system",
												]
											}
										}
									]
								}
								match={
									any=[
										{
											resources={
												kinds=["Pod"]
											}
										}
									]
								}
								mutate={
									patchStrategicMerge={
										spec={
											affinity={
												nodeAffinity={
													preferredDuringSchedulingIgnoredDuringExecution=[
														{
															# Preference 1: Spot Nodes (High Weight)
															preference={
																matchExpressions=[
																	{
																		key="cloud.google.com/gke-spot"
																		operator="In"
																		values=["true"]
																	}
																]
															}
															weight=100
														},
														{
															# Preference 2: Scale-Out compute class
															preference={
																matchExpressions=[
																	{
																		key="cloud.google.com/compute-class"
																		operator="In"
																		values=["Scale-Out"]
																	}
																]
															}
															weight=50
														}
													]
												}
											}
											# REMOVED: forced tolerations. 
											# By removing the toleration, pods will only go to Spot nodes IF they are preferred,
											# but will schedule on Standard nodes immediately if Spot is unavailable.
										}
									}
								}
								name="inject-spot-preference"
							}
						]
					}
				}
			]
		})
	]
}
