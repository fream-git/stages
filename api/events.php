<?php
// Aktiviere Fehlerberichterstattung
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

error_log("Starting events.php");
require_once 'config.php';

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// Debug-Logging
error_log("Request Method: " . $_SERVER['REQUEST_METHOD']);

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

try {
    switch($_SERVER['REQUEST_METHOD']) {
        case 'GET':
            error_log("Processing GET request");
            $stmt = $pdo->query('SELECT * FROM events');
            $result = $stmt->fetchAll(PDO::FETCH_ASSOC);
            error_log("Found " . count($result) . " events");
            echo json_encode($result);
            break;
            
        case 'POST':
            $data = json_decode(file_get_contents('php://input'), true);
            error_log("Received data: " . print_r($data, true));  // Debug-Logging
            
            $stmt = $pdo->prepare('INSERT INTO events (id, title, description, is_date_range, start_date, end_date, stages) VALUES (?, ?, ?, ?, ?, ?, ?)');
            $stmt->execute([
                $data['id'],
                $data['title'],
                $data['description'],
                $data['is_date_range'],
                $data['start_date'],
                $data['end_date'],
                $data['stages']
            ]);
            
            http_response_code(201);
            echo json_encode($data);
            break;
            
        case 'OPTIONS':
            http_response_code(200);
            break;
    }
} catch(Exception $e) {
    error_log("Error in events.php: " . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'error' => 'Server error',
        'message' => $e->getMessage()
    ]);
} 