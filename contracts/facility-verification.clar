;; Facility Verification Contract
;; Validates regulated industrial sites

(define-data-var admin principal tx-sender)

;; Map of verified facilities
(define-map verified-facilities
  { facility-id: (string-ascii 32) }
  {
    owner: principal,
    name: (string-ascii 100),
    location: (string-ascii 100),
    industry-type: (string-ascii 50),
    verified: bool,
    verification-date: uint
  }
)

;; Public function to register a new facility
(define-public (register-facility
    (facility-id (string-ascii 32))
    (name (string-ascii 100))
    (location (string-ascii 100))
    (industry-type (string-ascii 50)))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (asserts! (is-none (map-get? verified-facilities { facility-id: facility-id })) (err u100))

    (map-set verified-facilities
      { facility-id: facility-id }
      {
        owner: tx-sender,
        name: name,
        location: location,
        industry-type: industry-type,
        verified: false,
        verification-date: u0
      }
    )
    (ok true)
  )
)

;; Public function to verify a facility
(define-public (verify-facility (facility-id (string-ascii 32)))
  (let ((facility (unwrap! (map-get? verified-facilities { facility-id: facility-id }) (err u404))))
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))

    (map-set verified-facilities
      { facility-id: facility-id }
      (merge facility {
        verified: true,
        verification-date: block-height
      })
    )
    (ok true)
  )
)

;; Read-only function to get facility details
(define-read-only (get-facility (facility-id (string-ascii 32)))
  (map-get? verified-facilities { facility-id: facility-id })
)

;; Function to transfer admin rights
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (var-set admin new-admin)
    (ok true)
  )
)
