# AI FinOps Platform on Kubernetes

This project implements a real-time, event-driven **FinOps platform** on **AWS EKS** to monitor and visualize specialized **AI/ML costs** (such as GPU usage and third-party API calls) that are not covered by standard cloud billing dashboards.

---

## The Need for Real-Time AI FinOps

Traditional cloud billing dashboards are often updated only once every few hours or once a day. This is sufficient for predictable web server costs but fails to address the unique challenges of AI/ML workloads:

* **High-Velocity GPU Costs:**  
  A single misconfigured machine learning training job on a multi-GPU instance (like an AWS `p4d.24xlarge`) can burn thousands of dollars in a single afternoon. A daily report is too late.

* **Volatile API Costs:**  
  Applications integrating with generative AI (like GPT-4 or Claude) make millions of token-based API calls. A sudden spike in usage can go unnoticed until a massive bill arrives at the end of the month.

* **Poor Attribution:**  
  It is difficult to attribute these granular costs back to the specific team, project, or even a specific user request.

This platform solves this by ingesting custom cost events in **real-time**, processing them through a **scalable pipeline**, and visualizing them in a custom dashboard **within seconds**.

---

## Architecture and Data Flow

This platform is built on a **cloud-native**, **event-driven** architecture running entirely on **Kubernetes**.

1. **Event Generation (Producer):**  
   A `Deployment` runs a producer script (e.g., `kafka-producer.sh`) which simulates AI/ML cost events.  
   It generates randomized JSON messages representing GPU job costs or API call costs, complete with team and project metadata.

2. **Ingestion (Kafka):**  
   The producer sends these JSON messages to an `ai-costs` topic within an **Apache Kafka** cluster.  
   The Kafka cluster is stateful, highly available (3 nodes), and runs in **KRaft (Zookeeper-less)** mode.  
   It acts as a resilient, persistent buffer that can absorb massive spikes in cost events without data loss.
<img width="832" height="347" alt="image" src="https://github.com/user-attachments/assets/c393f8c8-b59a-4fb9-b8f5-95b61d354c25" />

3. **Processing (Python Consumer):**  
   A separate `Deployment` runs a custom Python application (`consumer.py`).  
   This consumer subscribes to the `ai-costs` topic, reads the JSON messages one by one, and parses them.

4. **Metric Exposure (Prometheus Client):**  
   Using the `prometheus_client` library, the Python consumer translates each JSON message into a custom Prometheus metric.  
   It creates a `Counter` named `ai_finops_cost_dollars_total` and attaches labels (e.g., `team`, `project`, `source`) extracted from the message.  
   This metric data is exposed via an HTTP server on a `/metrics` endpoint.

5. **Scraping 
   A `ServiceMonitor` resource is deployed, which declaratively tells the Prometheus Operator to find the consumer’s `Service` (via its labels)  
   and automatically configure Prometheus to scrape the `/metrics` endpoint every 15 seconds.
<img width="1905" height="855" alt="image" src="https://github.com/user-attachments/assets/5fdc31f9-c279-4cf8-8f0e-3ed1bf8ef7ee" />

6. **Visualization (Grafana):**  
   Grafana is configured with Prometheus as a data source.  
   It can now query *both* the standard `opencost_*` metrics and our new custom `ai_finops_cost_dollars_total` metric,  
   allowing for a single, unified dashboard showing total cluster cost *plus* our granular, real-time AI costs.
<img width="1672" height="816" alt="image" src="https://github.com/user-attachments/assets/4c551a45-5f20-4a5e-8273-0872cc0a9bfd" />

---

## Technologies Used

| Category | Technology |
|-----------|-------------|
| **Infrastructure as Code** | Terraform |
| **Cloud Provider** | AWS (EKS, VPC, EC2, EBS) |
| **Container Orchestration** | Kubernetes |
| **Package Management** | Helm |
| **Data Streaming** | Apache Kafka (via Strimzi Operator) |
| **Monitoring** | Prometheus (via Prometheus Operator / `kube-prometheus-stack`) |
| **Visualization** | Grafana |
| **Standard Cost Monitoring** | OpenCost |
| **Application Languages** | Python (consumer), Shell (producer), Docker |

---

## Project Deployment (Bootstrapping from Scratch)

This project is fully automated using **Terraform** and requires a two-step apply process to handle the dynamic provider configuration for Kubernetes.

### Prerequisites
* Terraform CLI  
* AWS CLI (configured with credentials)  
* `kubectl`  
* `docker` (logged in to push consumer image)

---

### Step 1: Build Infrastructure

Run the initial apply, targeting *only* the EKS module.  
This builds the VPC and EKS cluster itself.

```bash
terraform apply -target=module.eks --auto-approve
```

### **Step 2: Update Kubeconfig**
Run the output command from Terraform to configure kubectl to talk to the new cluster.

```bash
aws eks update-kubeconfig --region <your_region> --name AI-FinOps-Platform
kubectl get nodes
```

### **Step 3: Build and Push Consumer Image**
Build the Python consumer’s Docker image and push it to a container registry.

```bash
cd ../kafka-consumer
docker build -t dakshsawhneyy/kafkaconsumer-python:latest .
docker push dakshsawhneyy/kafkaconsumer-python:latest
cd ../terraform
```

### **Step 4: Apply Applications**
Run the output command from Terraform to configure kubectl to talk to the new cluster.
Run a full Terraform apply.

Terraform will now use the valid kubeconfig to connect to the cluster and deploy all applications:
> helm_release (Strimzi, Prometheus, OpenCost)
> kubernetes_manifest (Kafka Cluster, Kafka Topic, Producer, Consumer, Service, ServiceMonitor)

```bash
terraform apply
```

## Core Concepts Implemented
* Infrastructure as Code (IaC):
The entire platform, from VPC to applications, is defined declaratively in Terraform.
* Kubernetes Operators:
Used the Strimzi Operator to manage stateful Kafka clusters and the Prometheus Operator to manage monitoring.
* Custom Resource Definitions (CRDs):
Interacted directly with CRDs like kind: Kafka, kind: KafkaTopic, and kind: ServiceMonitor via Terraform.
* Event-Driven Architecture:
Designed a decoupled system using Kafka as a central message bus.
* StatefulSets on Kubernetes:
Deployed and managed a stateful, persistent Kafka cluster (via Strimzi).
* Kubernetes Service Discovery:
Used a ServiceMonitor to allow Prometheus to automatically discover and scrape the consumer application.
* Custom Prometheus Metrics:
Implemented a Python application to export custom, labeled metrics from an external data source (Kafka).
* GitOps Principles:
Maintained a single source of truth for all infra and application configuration in a Git-trackable format.
