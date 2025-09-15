;; Event Ticketing Smart Contract in Clarity

;; Define constants
(define-constant SYSTEM_ADMINISTRATOR tx-sender)
(define-constant ADMISSION_COST u100) ;; Price per ticket in microSTX
(define-constant MAXIMUM_ADMISSIONS u1000) ;; Maximum number of tickets available

;; Data structures
(define-data-var total-admissions uint u0)
(define-data-var admissions-purchased uint u0)
(define-map admissions-held principal uint) ;; Maps principal to number of tickets owned

;; Define NFT trait for tickets
(define-non-fungible-token admission-nft uint)

;; Errors
(define-constant ERR_NOT_ADMINISTRATOR (err u100))
(define-constant ERR_CAPACITY_REACHED (err u101))
(define-constant ERR_INSUFFICIENT_BALANCE (err u102))
(define-constant ERR_INVALID_ADMISSION (err u103))
(define-constant ERR_TRANSFER_UNSUCCESSFUL (err u104))
(define-constant ERR_MINT_UNSUCCESSFUL (err u105))

;; Helper function to check if the caller is the contract owner
(define-private (is-administrator)
    (is-eq tx-sender SYSTEM_ADMINISTRATOR)
)

;; Issue new tickets (only contract owner can do this)
(define-public (issue-admissions (quantity uint))
    (begin
        (asserts! (is-administrator) ERR_NOT_ADMINISTRATOR)
        (asserts! (<= (+ (var-get total-admissions) quantity) MAXIMUM_ADMISSIONS) ERR_CAPACITY_REACHED)
        (var-set total-admissions (+ (var-get total-admissions) quantity))
        (ok true)
    )
)

;; Buy tickets
(define-public (buy-admission)
    (let 
        ((current-admissions-purchased (var-get admissions-purchased)))
        ;; Check if tickets are available
        (asserts! (< current-admissions-purchased (var-get total-admissions)) ERR_CAPACITY_REACHED)
        ;; Check if the sender has enough funds
        (asserts! (>= (stx-get-balance tx-sender) ADMISSION_COST) ERR_INSUFFICIENT_BALANCE)
        ;; Transfer STX from buyer to contract owner
        (match (stx-transfer? ADMISSION_COST tx-sender SYSTEM_ADMINISTRATOR)
            success
                (match (nft-mint? admission-nft current-admissions-purchased tx-sender)
                    mint-success
                        (begin
                            ;; Update tickets sold
                            (var-set admissions-purchased (+ current-admissions-purchased u1))
                            ;; Update tickets owned by the buyer
                            (map-set admissions-held 
                                tx-sender 
                                (+ (default-to u0 (map-get? admissions-held tx-sender)) u1)
                            )
                            (ok true)
                        )
                    mint-error ERR_MINT_UNSUCCESSFUL
                )
            error ERR_TRANSFER_UNSUCCESSFUL
        )
    )
)

;; Transfer ticket ownership
(define-public (transfer-admission (recipient principal) (admission-id uint))
    (let 
        ((current-holder tx-sender))
        ;; Check if the sender owns the ticket
        (asserts! (is-eq (nft-get-owner? admission-nft admission-id) (some current-holder)) ERR_INVALID_ADMISSION)
        ;; Transfer the ticket
        (match (nft-transfer? admission-nft admission-id current-holder recipient)
            success
                (begin
                    ;; Update tickets owned by sender and receiver
                    (map-set admissions-held 
                        current-holder 
                        (- (default-to u0 (map-get? admissions-held current-holder)) u1)
                    )
                    (map-set admissions-held 
                        recipient 
                        (+ (default-to u0 (map-get? admissions-held recipient)) u1)
                    )
                    (ok true)
                )
            error ERR_TRANSFER_UNSUCCESSFUL
        )
    )
)

;; Get total tickets available
(define-read-only (get-total-admissions)
    (ok (var-get total-admissions))
)

;; Get tickets sold
(define-read-only (get-admissions-purchased)
    (ok (var-get admissions-purchased))
)

;; Get tickets owned by a specific principal
(define-read-only (get-admissions-held (holder principal))
    (ok (default-to u0 (map-get? admissions-held holder)))
)

;; Get ticket owner
(define-read-only (get-admission-holder (admission-id uint))
    (ok (nft-get-owner? admission-nft admission-id))
)