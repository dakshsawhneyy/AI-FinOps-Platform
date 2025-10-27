from kafka import KafkaConsumer
import json
from prometheus_client import start_http_server, Counter
import logging

# Setup logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s [%(levelname)s] %(message)s')

# Custom Prometheus Counters
c = Counter('ai_finops_cost_dollars_total', 'Total accumulated AI cost in USD', ['team', 'project', 'source'])

# Kafka Consumer
consumer = KafkaConsumer('ai-costs', group_id='ai-costs', bootstrap_servers='my-kafka-cluster-kafka-brokers.kafka.svc.cluster.local:9092')

if __name__ == '__main__':
    # Start Prometheus Server
    start_http_server(8000)
    logging.info('Prometheus Server started on port 8000')
    print('Prometheus Server started on port 8000')
    
    for msg in consumer:
        try:
            # Parse the message -- kafka has stringified it
            message_data = json.loads(msg.value.decode('utf-8'))
            
            # Extract each piece from the message data
            cost = message_data.get('cost', 0)
            team = message_data.get('details', {}).get('team', 'unknown')
            project = message_data.get('details', {}).get('project', 'unknown')
            source = message_data.get('source', 'unknown')
            
            # Adding Labels
            c.labels(team=team, project=project, source=source).inc(float(cost))
            
            print(f"Processed message: Cost={cost} Project={project} Team={team}")
            logging.info(f"Processed message: Cost={cost}, Project={project}, Team={team}, Source={source}")
        except json.JSONDecodeError as e:
            print(f'JSON Decode Error: {e}')
            logging.error(f'Error processing message: {e}')