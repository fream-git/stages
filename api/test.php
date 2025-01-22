<?php
// Zeige alle Fehler im Browser
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

// Teste Datenbankverbindung
try {
    $db_host = 'localhost';
    $db_name = 'stages_db';
    $db_user = 'stages_user';
    $db_pass = 'constantin_php';

    echo "Versuche Datenbankverbindung...<br>";
    $pdo = new PDO("mysql:host=$db_host;dbname=$db_name;charset=utf8mb4", $db_user, $db_pass);
    echo "Verbindung erfolgreich!<br>";
    
    echo "Teste Tabellen...<br>";
    $stmt = $pdo->query('SHOW TABLES');
    print_r($stmt->fetchAll());
    
} catch(Exception $e) {
    echo "Fehler: " . $e->getMessage();
} 