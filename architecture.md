# Architecture

### Phase 1:
-> Creating VPC<->SG<->EKS

### Phase 2:
-> Observability Stack installation inside EKS using terraform [prometheus, grafana, opencost]

### Phase 3:
-> Installation of kafka cluster(kafka pods and zookeeper pods) using STRIMZI
-> Creation of Cost_Producer [Kafka Producer] using script (Adding script inside cluster using config-map)

### Phase 4:
-> Creation of Kafka-Topic
-> Creation of Kafka-Consumer Pod and Service
-> Kafka-Consumer incrememnt counts and expose metrics to /metrics

### Phase 5:
-> Added service-discovery so that prometheus can know, from which service fetching metrics from