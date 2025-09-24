
(define-non-fungible-token court-ruling uint)

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-already-exists (err u102))
(define-constant err-unauthorized (err u103))
(define-constant err-invalid-ruling (err u104))
(define-constant err-restricted-access (err u105))

(define-data-var token-counter uint u0)
(define-data-var contract-paused bool false)

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
