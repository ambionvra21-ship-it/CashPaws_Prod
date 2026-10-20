<?php
/**
 * =======================================================================
 * CASHAWS SECURE PROFIT PROTECTION ENGINE
 * TARGET SCHEMA STRUCTURE: user_id
 * =======================================================================
 */

header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// --- 1. Security Configurations ---
define('SUPABASE_API_URL', 'https://supabase.co');
define('SUPABASE_SERVICE_ROLE_KEY', 'your-secret-service-role-key-here'); // Secure server-only role key
define('COIN_CONVERSION_RATE', 15); // Hard reward cap ceiling per video ad interaction
define('MAX_DAILY_ADS', 25); // Protects ad inventory profit loops

// Extract inbound JSON payloads safely
$rawInput = file_get_contents("php://input");
$data = json_decode($rawInput, true);

if (!isset($data['user_id']) || !isset($data['ad_placement_type'])) {
    http_response_code(400);
    echo json_encode(["status" => "error", "message" => "Missing telemetry fields. Transaction aborted."]);
    exit();
}

$targetUserId = trim($data['user_id']);
$placementType = trim($data['ad_placement_type']);

// --- 2. Step 1: Fetch Live User Metrics via Supabase Admin API Rest Node ---
$lookupUrl = SUPABASE_API_URL . "/rest/v1/user_profiles?user_id=eq." . urlencode($targetUserId) . "&select=pawcoins,ads_watched_today";

$ch = curl_init($lookupUrl);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    "Authorization: Bearer " . SUPABASE_SERVICE_ROLE_KEY,
    "apikey: " . SUPABASE_SERVICE_ROLE_KEY
]);

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

if ($httpCode !== 200 || empty($response)) {
    http_response_code(500);
    echo json_encode(["status" => "error", "message" => "Failed to reach profile sync ledger."]);
    exit();
}

$userProfiles = json_decode($response, true);
if (empty($userProfiles)) {
    http_response_code(404);
    echo json_encode(["status" => "error", "message" => "Account identifier matches no profile trace."]);
    exit();
}

$profile = $userProfiles[0];
$currentCoins = intval($profile['pawcoins']);
$adsWatchedToday = intval($profile['ads_watched_today']);

// --- 3. Step 2: Run Profit Protection Logic Gate Check ---
if ($adsWatchedToday >= MAX_DAILY_ADS) {
    http_response_code(403);
    echo json_encode([
        "status" => "denied", 
        "message" => "Daily ad distribution limit reached. No coins credited to maintain profit limits."
    ]);
    exit();
}

// --- 4. Step 3: Compute Verified Credit Totals ---
$calculatedNewCoins = $currentCoins + COIN_CONVERSION_RATE;
$calculatedNewAdTotal = $adsWatchedToday + 1;

// Prepare secure transactional payload back to Supabase Rest API
$updateUrl = SUPABASE_API_URL . "/rest/v1/user_profiles?user_id=eq." . urlencode($targetUserId);
$updateData = json_encode([
    "pawcoins" => $calculatedNewCoins,
    "ads_watched_today" => $calculatedNewAdTotal,
    "last_ad_watch" => date('c')
]);

$ch = curl_init($updateUrl);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_CUSTOMREQUEST, "PATCH");
curl_setopt($ch, CURLOPT_POSTFIELDS, $updateData);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    "Authorization: Bearer " . SUPABASE_SERVICE_ROLE_KEY,
    "apikey: " . SUPABASE_SERVICE_ROLE_KEY,
    "Content-Type: application/json",
    "Prefer: return=minimal"
]);

$updateResponse = curl_exec($ch);
$updateHttpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

if ($updateHttpCode === 200 || $updateHttpCode === 204) {
    echo json_encode([
        "status" => "success",
        "message" => "Ad interaction verified.",
        "credited_points" => COIN_CONVERSION_RATE,
        "total_balance" => $calculatedNewCoins,
        "remaining_ads" => (MAX_DAILY_ADS - $calculatedNewAdTotal)
    ]);
} else {
    http_response_code(500);
    echo json_encode(["status" => "error", "message" => "Failed to write reward credits to ledger table."]);
}
?>
