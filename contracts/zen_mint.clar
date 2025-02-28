;; ZenMint NFT and Auction Contract

;; Define NFT token
(define-non-fungible-token zen-nft uint)

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-auction-exists (err u102))
(define-constant err-low-bid (err u103))
(define-constant err-auction-ended (err u104))

;; NFT Data
(define-map nft-data uint 
  {
    creator: principal,
    title: (string-ascii 64),
    description: (string-ascii 256),
    price: uint
  }
)

;; Auction Data
(define-map auctions uint
  {
    seller: principal,
    current-bid: uint,
    highest-bidder: (optional principal),
    end-block: uint,
    min-increment: uint
  }
)

;; NFT counter
(define-data-var last-token-id uint u0)

;; Create new NFT
(define-public (create-nft (title (string-ascii 64)) (description (string-ascii 256)) (price uint))
  (let
    (
      (token-id (+ (var-get last-token-id) u1))
    )
    (try! (nft-mint? zen-nft token-id tx-sender))
    (map-set nft-data token-id {
      creator: tx-sender,
      title: title,
      description: description,
      price: price
    })
    (var-set last-token-id token-id)
    (ok token-id)
  )
)

;; Start auction
(define-public (start-auction (token-id uint) (min-price uint) (min-increment uint))
  (let
    (
      (owner (unwrap! (nft-get-owner? zen-nft token-id) err-not-found))
    )
    (asserts! (is-eq tx-sender owner) err-owner-only)
    (asserts! (is-none (map-get? auctions token-id)) err-auction-exists)
    (map-set auctions token-id {
      seller: tx-sender,
      current-bid: min-price,
      highest-bidder: none,
      end-block: (+ block-height u144), ;; 24 hour auction
      min-increment: min-increment
    })
    (ok true)
  )
)

;; Place bid
(define-public (place-bid (token-id uint) (bid-amount uint))
  (let
    (
      (auction (unwrap! (map-get? auctions token-id) err-not-found))
      (current-bid (get current-bid auction))
      (min-increment (get min-increment auction))
    )
    (asserts! (< block-height (get end-block auction)) err-auction-ended)
    (asserts! (>= bid-amount (+ current-bid min-increment)) err-low-bid)
    (map-set auctions token-id (merge auction {
      current-bid: bid-amount,
      highest-bidder: (some tx-sender)
    }))
    (ok true)
  )
)

;; Claim auction
(define-public (claim-auction (token-id uint))
  (let
    (
      (auction (unwrap! (map-get? auctions token-id) err-not-found))
      (winner (unwrap! (get highest-bidder auction) err-not-found))
    )
    (asserts! (>= block-height (get end-block auction)) err-auction-ended)
    (try! (nft-transfer? zen-nft token-id (get seller auction) winner))
    (map-delete auctions token-id)
    (ok true)
  )
)

;; Read only functions
(define-read-only (get-nft-data (token-id uint))
  (ok (map-get? nft-data token-id))
)

(define-read-only (get-auction-data (token-id uint))
  (ok (map-get? auctions token-id))
)
