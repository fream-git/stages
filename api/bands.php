<?php
require_once 'config.php';
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Hole event_id und date aus der URL
$parts = explode('/', $_SERVER['REQUEST_URI']);
$eventId = $parts[array_search('events', $parts) + 1];
$date = urldecode($parts[array_search('bands', $parts) + 1]);

try {
    switch($_SERVER['REQUEST_METHOD']) {
        case 'GET':
            error_log("Loading bands for event: $eventId");
            $stmt = $pdo->prepare('SELECT * FROM bands WHERE event_id = ?');
            $stmt->execute([$eventId]);
            $result = $stmt->fetchAll(PDO::FETCH_ASSOC);
            error_log("Found " . count($result) . " bands");
            echo json_encode($result);
            break;
            
        case 'PUT':
            $data = json_decode(file_get_contents('php://input'), true);
            error_log("🎸 Saving bands for event: $eventId");
            error_log("📝 Received data: " . print_r($data, true));
            
            // Lösche alte Bands für dieses Event
            $stmt = $pdo->prepare('DELETE FROM bands WHERE event_id = ?');
            $stmt->execute([$eventId]);
            
            // Füge neue Bands hinzu
            $stmt = $pdo->prepare('
                INSERT INTO bands (id, event_id, name, start_time, end_time, stage_index) 
                VALUES (?, ?, ?, ?, ?, ?)
            ');
            
            foreach($data as $band) {
                $stmt->execute([
                    $band['id'],
                    $eventId,
                    $band['name'],
                    $band['start_time'],
                    $band['end_time'],
                    $band['stage_index']
                ]);
            }
            
            error_log("✅ Bands saved successfully");
            http_response_code(200);
            echo json_encode(['status' => 'success']);
            break;
    }
} catch(Exception $e) {
    error_log("❌ Error: " . $e->getMessage());
    http_response_code(500);
    echo json_encode(['error' => $e->getMessage()]);
} 