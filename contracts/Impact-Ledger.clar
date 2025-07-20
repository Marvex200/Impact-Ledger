(define-trait contract-owner-trait
  ((is-owner (principal) (response bool uint))
   (get-owner () (response principal uint))))

(define-constant ERR-NGO-ALREADY-REGISTERED u100)
(define-constant ERR-NGO-NOT-FOUND u101)
(define-constant ERR-NOT-AUTHORIZED u102)
(define-constant ERR-NGO-LIST-FULL u103)
(define-constant ERR-OVERFLOW u105)

(define-data-var owner principal tx-sender)
(define-data-var ngo-list (list 200 principal) (list))

(define-map ngos principal
  {
    name: (string-utf8 50),
    purpose: (string-utf8 100),
    website: (string-utf8 100),
    wallet: principal,
    total-donated: uint,
    is-active: bool
  })

(define-map donations
  { donor: principal, ngo: principal }
  { amount: uint })

(define-public (is-owner (sender principal))
  (ok (is-eq sender (var-get owner))))

(define-public (get-owner)
  (ok (var-get owner)))

(define-public (transfer-ownership (new-owner principal))
  (begin
    (asserts! (is-eq tx-sender (var-get owner)) (err ERR-NOT-AUTHORIZED))
    (var-set owner new-owner)
    (ok new-owner)))

(define-public (register-ngo (name (string-utf8 50)) (purpose (string-utf8 100)) (website (string-utf8 100)))
  (let ((current-list (var-get ngo-list)))
    (let ((opt-ngo (map-get? ngos tx-sender)))
      (if (is-some opt-ngo)
          (err ERR-NGO-ALREADY-REGISTERED)
          (let ((new-ngo
                  {
                    name: name,
                    purpose: purpose,
                    website: website,
                    wallet: tx-sender,
                    total-donated: u0,
                    is-active: true
                  }))
            (map-set ngos tx-sender new-ngo)
            (match (as-max-len? (append current-list tx-sender) u200)
              updated-list (begin
                (var-set ngo-list updated-list)
                (ok "NGO Registered Successfully"))
              (err ERR-NGO-LIST-FULL)))))))

(define-public (deactivate-ngo (ngo principal))
  (begin
    (asserts! (is-eq tx-sender (var-get owner)) (err ERR-NOT-AUTHORIZED))
    (let ((opt-ngo (map-get? ngos ngo)))
      (if (is-none opt-ngo)
          (err ERR-NGO-NOT-FOUND)
          (let ((existing-ngo (unwrap! opt-ngo (err ERR-NGO-NOT-FOUND)))
                (updated-ngo {
                  name: (get name existing-ngo),
                  purpose: (get purpose existing-ngo),
                  website: (get website existing-ngo),
                  wallet: (get wallet existing-ngo),
                  total-donated: (get total-donated existing-ngo),
                  is-active: false
                }))
            (map-set ngos ngo updated-ngo)
            (ok "NGO Deactivated"))))))

(define-public (donate (ngo principal))
  (let ((amount u100000)
        (opt-ngo (map-get? ngos ngo)))
    (if (is-none opt-ngo)
        (err ERR-NGO-NOT-FOUND)
        (let ((existing-ngo (unwrap! opt-ngo (err ERR-NGO-NOT-FOUND))))
          (begin
            (asserts! (get is-active existing-ngo) (err ERR-NGO-NOT-FOUND))
            (try! (stx-transfer? amount tx-sender (get wallet existing-ngo)))
            (let ((new-total (+ (get total-donated existing-ngo) amount)))
              (asserts! (<= new-total u340282366920938463463374607431768211455) (err ERR-OVERFLOW))
              (let ((updated-ngo (merge existing-ngo { total-donated: new-total }))
                    (donation-key { donor: tx-sender, ngo: ngo })
                    (prev-donation (default-to u0 (get amount (map-get? donations donation-key)))))
                (asserts! (<= (+ prev-donation amount) u340282366920938463463374607431768211455) (err ERR-OVERFLOW))
                (map-set ngos ngo updated-ngo)
                (map-set donations donation-key { amount: (+ prev-donation amount) })
                (ok "Donation successful"))))))))

(define-read-only (get-ngo (ngo principal))
  (map-get? ngos ngo))

(define-read-only (get-donation (donor principal) (ngo principal))
  (map-get? donations { donor: donor, ngo: ngo }))

(define-read-only (list-all-ngos)
  (ok (var-get ngo-list)))