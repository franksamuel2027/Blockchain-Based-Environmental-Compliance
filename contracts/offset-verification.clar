;; Offset Verification Contract
;; Validates environmental remediation

(define-data-var admin principal tx-sender)

;; Map of offset projects
(define-map offset-projects
  { project-id: (string-ascii 32) }
  {
    owner: principal,
    description: (string-ascii 200),
    offset-type: (string-ascii 50),
    amount: uint,
    unit: (string-ascii 10),
    start-date: uint,
    end-date: uint,
    verified: bool
  }
)

;; Public function to register an offset project
(define-public (register-offset-project
    (project-id (string-ascii 32))
    (description (string-ascii 200))
    (offset-type (string-ascii 50))
    (amount uint)
    (unit (string-ascii 10))
    (end-date uint))
  (begin
    (asserts! (is-none (map-get? offset-projects { project-id: project-id })) (err u100))

    (map-set offset-projects
      { project-id: project-id }
      {
        owner: tx-sender,
        description: description,
        offset-type: offset-type,
        amount: amount,
        unit: unit,
        start-date: block-height,
        end-date: end-date,
        verified: false
      }
    )
    (ok true)
  )
)

;; Public function to verify an offset project
(define-public (verify-offset-project (project-id (string-ascii 32)))
  (let ((project (unwrap! (map-get? offset-projects { project-id: project-id }) (err u404))))
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))

    (map-set offset-projects
      { project-id: project-id }
      (merge project { verified: true })
    )
    (ok true)
  )
)

;; Read-only function to get offset project details
(define-read-only (get-offset-project (project-id (string-ascii 32)))
  (map-get? offset-projects { project-id: project-id })
)

;; Function to transfer admin rights
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (var-set admin new-admin)
    (ok true)
  )
)
