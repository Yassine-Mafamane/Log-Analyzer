#!/bin/bash

OUTPUT_FILE="output/anomalies.txt"
HTML_FILE="report.html"

[ ! -f "$OUTPUT_FILE" ] && echo "Error: $OUTPUT_FILE not found" && exit 1

TOTAL=$(wc -l < "$OUTPUT_FILE")
CRITICAL=$(grep -c "CRITICAL" "$OUTPUT_FILE" || echo 0)
WARNING=$(grep -c "WARNING" "$OUTPUT_FILE" || echo 0)

ROWS=""
while IFS= read -r line; do
    TYPE=$(echo "$line" | cut -d':' -f1)
    TARGET=$(echo "$line" | sed 's/^[^:]*:\([^|]*\).*/\1/' | xargs)
    COUNT=$(echo "$line" | grep -oP 'Count:\s*\K\d+')
    ACTION=$(echo "$line" | sed 's/.*| //' | sed 's/.*Count: [0-9]* | //')
    
    if echo "$ACTION" | grep -q "CRITICAL"; then
        SEVERITY="critical"
        BADGE='<span class="badge critical">CRITICAL</span>'
    else
        SEVERITY="warning"
        BADGE='<span class="badge warning">WARNING</span>'
    fi
    
    ACTION_TEXT=$(echo "$ACTION" | sed 's/CRITICAL:\s*//;s/WARNING:\s*//')
    TYPE_LOWER=$(echo "$TYPE" | tr '[:upper:]' '[:lower:]')
    
    ROWS="$ROWS<div class=\"anomaly-item $SEVERITY\"><span class=\"anomaly-type $TYPE_LOWER\">$TYPE</span><span class=\"anomaly-target\">$TARGET</span><span class=\"anomaly-count\">${COUNT}x</span><span class=\"anomaly-action\">$BADGE $ACTION_TEXT</span></div>"
done < "$OUTPUT_FILE"

cat > "$HTML_FILE" << EOF
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Log Analyzer Report</title>
<style>
*{margin:0;padding:0;box-sizing:border-box}body{font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,sans-serif;background:linear-gradient(135deg,#1a1a2e,#16213e);min-height:100vh;color:#fff;padding:20px}.container{max-width:1000px;margin:0 auto}header{text-align:center;padding:30px 0}header h1{font-size:2.5rem;margin-bottom:10px;background:linear-gradient(90deg,#00d4ff,#7b2cbf);-webkit-background-clip:text;-webkit-text-fill-color:transparent}header p{color:#888;font-size:1.1rem}.stats{display:grid;grid-template-columns:repeat(auto-fit,minmax(200px,1fr));gap:20px;margin-bottom:30px}.stat-card{background:rgba(255,255,255,.05);border-radius:12px;padding:20px;text-align:center;border:1px solid rgba(255,255,255,.1)}.stat-card h3{font-size:2rem;margin-bottom:5px}.stat-card p{color:#888;font-size:.9rem}.stat-card.critical h3{color:#ff4757}.stat-card.warning h3{color:#ffa502}.stat-card.total h3{color:#00d4ff}.results{background:rgba(255,255,255,.05);border-radius:12px;border:1px solid rgba(255,255,255,.1);overflow:hidden}.results-header{background:rgba(255,255,255,.05);padding:15px 20px;border-bottom:1px solid rgba(255,255,255,.1)}.results-header h2{font-size:1.2rem}.anomaly-list{padding:10px}.anomaly-item{display:grid;grid-template-columns:100px 1fr 80px auto;gap:15px;align-items:center;padding:15px;border-radius:8px;margin-bottom:10px;background:rgba(255,255,255,.03);border-left:4px solid transparent}.anomaly-item.critical{border-left-color:#ff4757}.anomaly-item.warning{border-left-color:#ffa502}.anomaly-type{font-weight:700;font-size:.85rem;padding:5px 10px;border-radius:20px;text-align:center}.anomaly-type.brute{background:#ff475733;color:#ff6b7a}.anomaly-type.scan{background:#ffa50233;color:#ffb732}.anomaly-type.id{background:#7b2cbf33;color:#a855f7}.anomaly-target{font-family:monospace;color:#00d4ff}.anomaly-count{text-align:center;font-weight:700}.anomaly-action{font-size:.85rem;color:#888}.badge{display:inline-block;padding:3px 8px;border-radius:4px;font-size:.75rem;font-weight:700}.badge.critical{background:#ff4757;color:#fff}.badge.warning{background:#ffa502;color:#000}footer{text-align:center;padding:30px;color:#666;font-size:.9rem}
</style>
</head>
<body>
<div class="container">
<header><h1>Log Analyzer Report</h1><p>Anomaly Detection Results</p></header>
<div class="stats">
<div class="stat-card total"><h3>$TOTAL</h3><p>Total</p></div>
<div class="stat-card critical"><h3>$CRITICAL</h3><p>Critical</p></div>
<div class="stat-card warning"><h3>$WARNING</h3><p>Warnings</p></div>
</div>
<div class="results">
<div class="results-header"><h2>Detected Anomalies</h2></div>
<div class="anomaly-list">$ROWS</div>
</div>
<footer>Hadoop MapReduce</footer>
</div>
</body>
</html>
EOF

echo "Report: $HTML_FILE"
