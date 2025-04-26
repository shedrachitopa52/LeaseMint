;; Define data variables and maps
(define-data-var listing-counter uint u0)

;; Listing structure:
;; - owner: The NFT owner listing the asset
;; - nft-contract: The contract address where the NFT is managed
;; - token-id: The identifier of the NFT
;; - rental-price: Price to rent the NFT (in micro-STX)
;; - deposit: Security deposit amount (in micro-STX)
;; - duration: Rental period (in blocks)
;; - rented: Indicates if the NFT is currently rented
;; - renter: Optionally stores the renter's principal
;; - start-time: Optionally stores the block height when rental began
(define-map listings
  { listing-id: uint }
  {
    owner: principal,
    nft-contract: principal,
    token-id: uint,
    rental-price: uint,
    deposit: uint,
    duration: uint,
    rented: bool,
    renter: (optional principal),
    start-time: (optional uint)
  }
)

;; List an NFT for rent
(define-public (list-nft (nft-contract principal) (token-id uint) (rental-price uint) (deposit uint) (duration uint))
  (let ((listing-id (var-get listing-counter)))
    (begin
      (map-set listings { listing-id: listing-id } {
          owner: tx-sender,
          nft-contract: nft-contract,
          token-id: token-id,
          rental-price: rental-price,
          deposit: deposit,
          duration: duration,
          rented: false,
          renter: none,
          start-time: none
      })
      (var-set listing-counter (+ listing-id u1))
      (ok listing-id)
    )
  )
)

;; Rent an NFT
(define-public (rent-nft (listing-id uint))
  (match (map-get? listings { listing-id: listing-id })
    listing 
      (if (get rented listing)
        (err "NFT already rented")
        (let ((total-cost (+ (get rental-price listing) (get deposit listing))))
          ;; Here, we assume the renter has provided sufficient funds.
          ;; In production, you would integrate token transfers or STX checks.
          (begin
            ;; In a full implementation, you'd trigger an NFT transfer from owner to renter.
            (map-set listings { listing-id: listing-id }
              {
                owner: (get owner listing),
                nft-contract: (get nft-contract listing),
                token-id: (get token-id listing),
                rental-price: (get rental-price listing),
                deposit: (get deposit listing),
                duration: (get duration listing),
                rented: true,
                renter: (some tx-sender),
                start-time: (some burn-block-height)
              })
            (ok listing-id)
          )))
    (err "Listing not found"))
)

;; Return a rented NFT
(define-public (return-nft (listing-id uint))
  (match (map-get? listings { listing-id: listing-id })
    listing-data (if (is-eq (get renter listing-data) (some tx-sender))
        (let ((rental-start (unwrap! (get start-time listing-data) (err "No rental start time recorded"))))
          (if (>= (- burn-block-height rental-start) (get duration listing-data))
              (begin
                (map-set listings { listing-id: listing-id }
                  {
                    owner: (get owner listing-data),
                    nft-contract: (get nft-contract listing-data),
                    token-id: (get token-id listing-data),
                    rental-price: (get rental-price listing-data),
                    deposit: (get deposit listing-data),
                    duration: (get duration listing-data),
                    rented: false,
                    renter: none,
                    start-time: none
                  })
                (ok listing-id)
              )
              (err "Rental period not yet completed")
          ))
        (err "Caller is not the renter"))
    (err "Listing not found"))
)
