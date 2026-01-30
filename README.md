# Log Analyzer

Hadoop MapReduce log analyzer that detects security anomalies.

## Requirements

- Docker

## Usage

1. Load the Hadoop image:
```bash
docker load -i hadoop_bigdata.tar
```

2. Add log files to `logs/` folder

3. Run the analysis:
```bash
docker run --rm --privileged --hostname localhost --entrypoint /bin/bash \
  -v "$(pwd)/output:/data/output" \
  -v "$(pwd)/logs:/data/input" \
  -v "$(pwd)/init.sh:/init.sh" \
  -v "$(pwd)/mapper:/usr/local/hadoop/mapper" \
  -v "$(pwd)/reducer:/usr/local/hadoop/reducer" \
  suhothayan/hadoop-spark-pig-hive:2.9.2 /init.sh
```

4. Generate HTML report:
```bash
./generate_report.sh
```

5. Open `report.html` in browser

## Output

Results are saved to `output/anomalies.txt`

## Detection Types

| Type | Description |
|------|-------------|
| BRUTE | Brute force login attempts |
| SCAN | Port/vulnerability scanning |
| ID | Credential stuffing |
| IP | DDoS attacks |
