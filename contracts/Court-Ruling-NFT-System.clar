
(define-non-fungible-token court-ruling uint)

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-already-exists (err u102))
(define-constant err-unauthorized (err u103))
(define-constant err-invalid-ruling (err u104))
(define-constant err-restricted-access (err u105))
(define-constant err-appeal-exists (err u106))
(define-constant err-invalid-status (err u107))
(define-constant err-ruling-not-found (err u108))

(define-data-var token-counter uint u0)
(define-data-var contract-paused bool false)
(define-data-var appeal-counter uint u0)

(define-map court-rulings uint {
    case-number: (string-ascii 50),
    court-name: (string-ascii 100),
    plaintiff: (string-ascii 100),
    defendant: (string-ascii 100),
    judge-name: (string-ascii 100),
    ruling-date: uint,
    ruling-summary: (string-ascii 500),
    case-type: (string-ascii 50),
    ruling-hash: (buff 32),
    access-level: (string-ascii 20),
    created-at: uint,
    created-by: principal
})

(define-map authorized-minters principal bool)
(define-map ruling-metadata uint (string-utf8 500))
(define-map case-to-token (string-ascii 50) uint)
(define-map restricted-access uint bool)

(define-map appeals uint {
    appeal-id: uint,
    original-ruling-id: uint,
    appellant: principal,
    appeal-court: (string-ascii 100),
    appeal-case-number: (string-ascii 50),
    appeal-grounds: (string-ascii 500),
    filing-date: uint,
    status: (string-ascii 20),
    decision: (optional (string-ascii 500)),
    decision-date: (optional uint),
    filed-by: principal,
    filed-at: uint
})

(define-map ruling-appeals uint (list 50 uint))
(define-map appeal-status-history uint (list 20 {status: (string-ascii 20), updated-at: uint, updated-by: principal}))

(define-public (mint-ruling
    (recipient principal)
    (case-number (string-ascii 50))
    (court-name (string-ascii 100))
    (plaintiff (string-ascii 100))
    (defendant (string-ascii 100))
    (judge-name (string-ascii 100))
    (ruling-date uint)
    (ruling-summary (string-ascii 500))
    (case-type (string-ascii 50))
    (ruling-hash (buff 32))
    (access-level (string-ascii 20))
    (metadata (string-utf8 500)))
    (let ((token-id (+ (var-get token-counter) u1)))
        (asserts! (not (var-get contract-paused)) err-unauthorized)
        (asserts! (or (is-eq tx-sender contract-owner)
                      (default-to false (map-get? authorized-minters tx-sender))) err-unauthorized)
        (asserts! (is-none (map-get? case-to-token case-number)) err-already-exists)
        (asserts! (> ruling-date u0) err-invalid-ruling)
        (try! (nft-mint? court-ruling token-id recipient))
        (map-set court-rulings token-id {
            case-number: case-number,
            court-name: court-name,
            plaintiff: plaintiff,
            defendant: defendant,
            judge-name: judge-name,
            ruling-date: ruling-date,
            ruling-summary: ruling-summary,
            case-type: case-type,
            ruling-hash: ruling-hash,
            access-level: access-level,
            created-at: stacks-block-height,
            created-by: tx-sender
        })
        (map-set ruling-metadata token-id metadata)
        (map-set case-to-token case-number token-id)
        (if (is-eq access-level "restricted")
            (map-set restricted-access token-id true)
            true)
        (var-set token-counter token-id)
        (ok token-id)))

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
    (begin
        (asserts! (is-eq tx-sender sender) err-unauthorized)
        (asserts! (not (var-get contract-paused)) err-unauthorized)
        (nft-transfer? court-ruling token-id sender recipient)))

(define-public (add-authorized-minter (minter principal))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (map-set authorized-minters minter true)
        (ok true)))

(define-public (remove-authorized-minter (minter principal))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (map-delete authorized-minters minter)
        (ok true)))

(define-public (update-ruling-metadata (token-id uint) (new-metadata (string-utf8 500)))
    (let ((ruling-data (unwrap! (map-get? court-rulings token-id) err-not-found)))
        (asserts! (or (is-eq tx-sender contract-owner)
                      (is-eq tx-sender (get created-by ruling-data))
                      (default-to false (map-get? authorized-minters tx-sender))) err-unauthorized)
        (map-set ruling-metadata token-id new-metadata)
        (ok true)))

(define-public (set-restricted-access (token-id uint) (restricted bool))
    (let ((ruling-data (unwrap! (map-get? court-rulings token-id) err-not-found)))
        (asserts! (or (is-eq tx-sender contract-owner)
                      (default-to false (map-get? authorized-minters tx-sender))) err-unauthorized)
        (if restricted
            (map-set restricted-access token-id true)
            (map-delete restricted-access token-id))
        (ok true)))

(define-public (pause-contract)
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (var-set contract-paused true)
        (ok true)))

(define-public (unpause-contract)
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (var-set contract-paused false)
        (ok true)))

(define-read-only (get-ruling-data (token-id uint))
    (let ((ruling-data (map-get? court-rulings token-id))
          (is-restricted (default-to false (map-get? restricted-access token-id))))
        (if (and is-restricted 
                 (not (is-eq tx-sender contract-owner))
                 (not (default-to false (map-get? authorized-minters tx-sender))))
            err-restricted-access
            (ok ruling-data))))

(define-read-only (get-ruling-metadata (token-id uint))
    (let ((is-restricted (default-to false (map-get? restricted-access token-id))))
        (if (and is-restricted 
                 (not (is-eq tx-sender contract-owner))
                 (not (default-to false (map-get? authorized-minters tx-sender))))
            err-restricted-access
            (ok (map-get? ruling-metadata token-id)))))

(define-read-only (get-owner (token-id uint))
    (ok (nft-get-owner? court-ruling token-id)))

(define-read-only (get-last-token-id)
    (ok (var-get token-counter)))

(define-read-only (get-token-uri (token-id uint))
    (ok none))

(define-read-only (get-token-by-case-number (case-number (string-ascii 50)))
    (ok (map-get? case-to-token case-number)))

(define-read-only (is-authorized-minter (minter principal))
    (ok (default-to false (map-get? authorized-minters minter))))

(define-read-only (is-contract-paused)
    (ok (var-get contract-paused)))

(define-read-only (get-contract-owner)
    (ok contract-owner))

(define-read-only (search-rulings-by-court (court-name (string-ascii 100)))
    (ok "Search functionality would require additional indexing"))

(define-read-only (search-rulings-by-case-type (case-type (string-ascii 50)))
    (ok "Search functionality would require additional indexing"))

(define-read-only (get-rulings-by-date-range (start-date uint) (end-date uint))
    (ok "Date range search would require additional indexing"))

(define-read-only (verify-ruling-hash (token-id uint) (hash (buff 32)))
    (match (map-get? court-rulings token-id)
        ruling-data (ok (is-eq (get ruling-hash ruling-data) hash))
        err-not-found))

(define-read-only (get-ruling-summary (token-id uint))
    (let ((ruling-data (map-get? court-rulings token-id))
          (is-restricted (default-to false (map-get? restricted-access token-id))))
        (if (and is-restricted 
                 (not (is-eq tx-sender contract-owner))
                 (not (default-to false (map-get? authorized-minters tx-sender))))
            err-restricted-access
            (match ruling-data
                data (ok (some (get ruling-summary data)))
                err-not-found))))

(define-public (file-appeal
    (original-ruling-id uint)
    (appellant principal)
    (appeal-court (string-ascii 100))
    (appeal-case-number (string-ascii 50))
    (appeal-grounds (string-ascii 500)))
    (let ((appeal-id (+ (var-get appeal-counter) u1))
          (ruling-data (unwrap! (map-get? court-rulings original-ruling-id) err-ruling-not-found))
          (existing-appeals (default-to (list) (map-get? ruling-appeals original-ruling-id))))
        (asserts! (not (var-get contract-paused)) err-unauthorized)
        (asserts! (or (is-eq tx-sender contract-owner)
                      (default-to false (map-get? authorized-minters tx-sender))) err-unauthorized)
        (map-set appeals appeal-id {
            appeal-id: appeal-id,
            original-ruling-id: original-ruling-id,
            appellant: appellant,
            appeal-court: appeal-court,
            appeal-case-number: appeal-case-number,
            appeal-grounds: appeal-grounds,
            filing-date: stacks-block-height,
            status: "pending",
            decision: none,
            decision-date: none,
            filed-by: tx-sender,
            filed-at: stacks-block-height
        })
        (map-set appeal-status-history appeal-id (list {status: "pending", updated-at: stacks-block-height, updated-by: tx-sender}))
        (map-set ruling-appeals original-ruling-id (unwrap-panic (as-max-len? (append existing-appeals appeal-id) u50)))
        (var-set appeal-counter appeal-id)
        (ok appeal-id)))

(define-public (update-appeal-status
    (appeal-id uint)
    (new-status (string-ascii 20))
    (decision (optional (string-ascii 500))))
    (let ((appeal-data (unwrap! (map-get? appeals appeal-id) err-not-found))
          (current-history (default-to (list) (map-get? appeal-status-history appeal-id))))
        (asserts! (or (is-eq tx-sender contract-owner)
                      (default-to false (map-get? authorized-minters tx-sender))) err-unauthorized)
        (asserts! (not (var-get contract-paused)) err-unauthorized)
        (map-set appeals appeal-id (merge appeal-data {
            status: new-status,
            decision: decision,
            decision-date: (if (or (is-eq new-status "granted") (is-eq new-status "denied"))
                              (some stacks-block-height)
                              none)
        }))
        (map-set appeal-status-history appeal-id 
            (unwrap-panic (as-max-len? 
                (append current-history {status: new-status, updated-at: stacks-block-height, updated-by: tx-sender}) 
                u20)))
        (ok true)))

(define-read-only (get-appeal (appeal-id uint))
    (ok (map-get? appeals appeal-id)))

(define-read-only (get-appeals-for-ruling (ruling-id uint))
    (ok (map-get? ruling-appeals ruling-id)))

(define-read-only (get-appeal-status-history (appeal-id uint))
    (ok (map-get? appeal-status-history appeal-id)))

(define-read-only (get-total-appeals)
    (ok (var-get appeal-counter)))

(define-read-only (get-appeal-count-for-ruling (ruling-id uint))
    (ok (len (default-to (list) (map-get? ruling-appeals ruling-id)))))
