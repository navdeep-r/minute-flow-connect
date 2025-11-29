// @ts-check
/// <reference path="../types/chrome.d.ts" />
/// <reference path="../types/index.js" />


(function () {
'use strict'

//*********** GLOBAL VARIABLES **********//
/** @type {ExtensionStatusJSON} */
const extensionStatusJSON_bug = {
    "status": 400,
    "message": `MINUTE FLOW encountered a new error`
}

const reportErrorMessage = "MINUTE FLOW encountered a new error. "
/** @type {MutationObserverInit} */
const mutationConfig = { childList: true, attributes: true, subtree: true, characterData: true }

// Name of the person attending the meeting
let userName = "You"

// Transcript array that holds one or more transcript blocks
/** @type {TranscriptBlock[]} */
let transcript = []

// Live Batch Streamer variables
let lastSentIndex = 0 // Pointer to track which transcript entries have been sent
/** @type {number | null} */
let batchIntervalId = null // Store interval ID for cleanup

// Buffer variables to dump values, which get pushed to transcript array as transcript blocks, at defined conditions
/**
   * @type {HTMLElement | null} 
   */
let transcriptTargetBuffer
let personNameBuffer = "", transcriptTextBuffer = "", timestampBuffer = ""

// Chat messages array that holds one or more chat messages of the meeting
/** @type {ChatMessage[]} */
let chatMessages = []

/** @type {MeetingSoftware} */
const meetingSoftware = "Google Meet"

// Capture meeting start timestamp, stored in ISO format
let meetingStartTimestamp = new Date().toISOString()
let meetingTitle = document.title

// Capture invalid transcript and chatMessages DOM element error for the first time and silence for the rest of the meeting to prevent notification noise
let isTranscriptDomErrorCaptured = false
let isChatMessagesDomErrorCaptured = false

// Capture meeting begin to abort userName capturing interval
let hasMeetingStarted = false

// Capture meeting end to suppress any errors
let hasMeetingEnded = false

/** @type {ExtensionStatusJSON} */
let extensionStatusJSON

})(); 
