;; Permit Tracking Contract
;; Manages regulatory authorizations

(define-data-var admin principal tx-sender)

;; Map of permits
(define-map permits
  { permit-id: (string-ascii 32) }
  {
    facility-id: (string-ascii 32),
    permit-type: (string-ascii 50),
    issue-date: uint,
    expiry-date: uint,
    status: (string-ascii 20),
    issuer: principal
  }
)

;; Public function to issue a permit
(define-public (issue-permit
    (permit-id (string-ascii 32))
    (facility-id (string-ascii 32))
    (permit-type (string-ascii 50))
    (expiry-date uint))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (asserts! (is-none (map-get? permits { permit-id: permit-id })) (err u100))

    (map-set permits
      { permit-id: permit-id }
      {
        facility-id: facility-id,
        permit-type: permit-type,
        issue-date: block-height,
        expiry-date: expiry-date,
        status: "active",
        issuer: tx-sender
      }
    )
    (ok true)
  )
)

;; Public function to revoke a permit
(define-public (revoke-permit (permit-id (string-ascii 32)))
  (let ((permit (unwrap! (map-get? permits { permit-id: permit-id }) (err u404))))
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))

    (map-set permits
      { permit-id: permit-id }
      (merge permit { status: "revoked" })
    )
    (ok true)
  )
)

;; Read-only function to get permit details
(define-read-only (get-permit (permit-id (string-ascii 32)))
  (map-get? permits { permit-id: permit-id })
)

;; Read-only function to check if a permit is valid
(define-read-only (is-permit-valid (permit-id (string-ascii 32)))
  (match (map-get? permits { permit-id: permit-id })
    permit (and
             (is-eq (get status permit) "active")
             (> (get expiry-date permit) block-height))
    false
  )
)

;; Function to transfer admin rights
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (var-set admin new-admin)
    (ok true)
  )
)
