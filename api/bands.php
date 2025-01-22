<?php
require_once 'config.php';
header('Content-Type: application/json');

$eventId = $_GET['eventId'];
$date = $_GET['date'];

switch($_SERVER['REQUEST_METHOD']) {
    case 'GET':
        $stmt = $pdo->prepare('
            SELECT * FROM bands 
            WHERE event_id = ? 
            AND DATE(start_time) = ?
        ');
        $stmt->execute([$eventId, $date]);
        echo json_encode($stmt->fetchAll(PDO::FETCH_ASSOC));
        break;
        
    case 'PUT':
        $data = json_decode(file_get_contents('php://input'), true);
        
        // Lösche alte Einträge für diesen Tag
        $stmt = $pdo->prepare('
            DELETE FROM bands 
            WHERE event_id = ? 
            AND DATE(start_time) = ?
        ');
        $stmt->execute([$eventId, $date]);
        
        // Füge neue Einträge hinzu
        $stmt = $pdo->prepare('
            INSERT INTO bands 
            VALUES (?, ?, ?, ?, ?, ?)
        ');
        
        foreach($data as $band) {
            $stmt->execute([
                $band['id'],
                $eventId,
                $band['name'],
                $band['startTime'],
                $band['endTime'],
                $band['stageIndex']
            ]);
        }
        
        http_response_code(200);
        break;
} 