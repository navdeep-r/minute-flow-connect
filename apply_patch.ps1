# Read the original content.js file
$content = Get-Content -Path "extension\content.js" -Raw

# Step 1: Add Live Batch Streamer variables after line with "let transcript = []"
$content = $content -replace '(let transcript = \[\])', @'
$1

// Live Batch Streamer variables
let lastSentIndex = 0 // Pointer to track which transcript entries have been sent
/** @type {number | null} */
let batchIntervalId = null // Store interval ID for cleanup
'@

# Step 2: Add interval setup after "overWriteChromeStorage([`"meetingStartTimestamp`"], false)"
$content = $content -replace '(overWriteChromeStorage\(\[`"meetingStartTimestamp`"\], false\))([^\n]*\n\s*\n\s*\/\/\*{11} MEETING START ROUTINES \*{10}\/\/)', @'
$1$2
    
    // Start Live Batch Streamer interval (every 30 seconds)
    batchIntervalId = setInterval(() => {
      console.log("🔔 30-second interval triggered!") // Debug log
      sendBatchToWebhook()
    }, 30000) // 30 seconds = 30,000ms
    console.log("Live Batch Streamer started (30-second interval)")
    console.log("⏰ Interval ID:", batchIntervalId) // Debug log
    
'@

# Step 3: Add cleanup and batch send before meeting end
$content = $content -replace '(if \(chatMessagesObserver\) \{[^\}]*\}\s*)\n(\s*\/\/ Push any data in the buffer)', @'
$1
        
        // Stop Live Batch Streamer and send final batch
        if (batchIntervalId) {
          clearInterval(batchIntervalId)
          console.log("Live Batch Streamer stopped")
        }
        // Send any remaining data before meeting ends
        sendBatchToWebhook()
        
$2'@

# Step 4: Add sendBatchToWebhook function before HELPER FUNCTIONS section
$content = $content -replace '(}\s*\n\s*\n\s*\n\s*\n\s*\n\s*\n\s*\n\s*\n\s*\n\s*\/\/\*{11} HELPER FUNCTIONS \*{10}\/\/)', @'


/**
 * @description Sends batch of new transcript lines to webhook (delta logic)
 */
function sendBatchToWebhook() {
  console.log("📡 sendBatchToWebhook() called") // Debug log
  console.log("📋 Current transcript length:", transcript.length) // Debug log
  console.log("👉 Last sent index:", lastSentIndex) // Debug log
  
  // Slice only new entries since lastSentIndex
  const batch = transcript.slice(lastSentIndex)

  // Only send if there's new data
  if (batch.length === 0) {
    console.log("No new transcript data to send")
    return
  }

  // Hardcoded webhook URL as per user request
  const WEBHOOK_URL = "https://webhook.site/721b4abf-ea74-4a8e-b287-d9a8f2349b2e"

  // Prepare payload
  const payload = {
    type: "30_sec_batch",
    timestamp: new Date().toISOString(),
    meetingTitle: meetingTitle,
    meetingStartTimestamp: meetingStartTimestamp,
    new_lines: batch
  }

  console.log(`Sending batch with ${batch.length} new entries to webhook...`)

  // Send POST request
  fetch(WEBHOOK_URL, {
    method: "POST",
    headers: {
      "Content-Type": "application/json"
    },
    body: JSON.stringify(payload)
  })
    .then(response => {
      if (!response.ok) {
        throw new Error(`Webhook request failed with status ${response.status} ${response.statusText}`)
      }
      return response
    })
    .then(() => {
      // CRITICAL: Only update pointer on successful response
      lastSentIndex = transcript.length
      console.log(`✓ Batch sent successfully. Pointer updated to index ${lastSentIndex}`)
    })
    .catch(err => {
      console.error(`✗ Failed to send batch to webhook:`, err)
      console.log(`Data preserved. Will retry in next interval. Current pointer: ${lastSentIndex}`)
    })
}


$1'@

# Write the modified content back
$content | Set-Content -Path "extension\content.js" -NoNewline

Write-Host "Patch applied successfully!"
