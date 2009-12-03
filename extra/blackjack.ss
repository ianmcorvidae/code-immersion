#lang scheme
(require "../client.ss")

(sendcode '("all" 
            (define one-suit 
              (lambda ()
                ;; Return numbers corresponding to one suit.
                ;; Suit is not actually represented.
                ;; J, Q, and K are all 10
                (list 1 2 3 4 5 6 7 8 9 10 10 10 10)))
            
            ;;(one-suit)
            
            (define one-deck
              (lambda ()
                ;; Return numbers corresponding to one full deck.
                (append (one-suit) (one-suit) (one-suit) (one-suit))))
            
            ;; (one-deck)
            
            (define four-decks
              (lambda ()
                ;; Return numbers corresponding to four full deck.
                (append (one-deck) (one-deck) (one-deck) (one-deck))))
            
            ;; (/ (length (four-decks)) 4)
            
            
            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            ;; general utilities that will come in handy
            
            (define shuffle ; Returns a randomly re-ordered copy of list.
              (lambda (list)
                (if (< (length list) 2) 
                    list
                    (let ((item (list-ref list (random (length list)))))
                      (cons item (shuffle (remove item list)))))))
            
            ;; (shuffle (one-deck))
            
            (define list-change
              (lambda (lst pos new-item)
                ;; Returns a copy of lst with new-item replacing whatever was at position pos.
                (append (take lst pos)
                        (list new-item)
                        (drop lst (+ pos 1)))))
            
            ;; (list-change '(a b c d e) 2 'z)
            ;; (list-change '(a b c d e) 0 'z)
            ;; (list-change '(a b c d e) 4 'z)
            
            (define list-without
              (lambda (lst pos)
                ;; Returns a copy of lst without the item at position pos.
                (append (take lst pos)
                        (drop lst (+ pos 1)))))
            
            ;; (list-without '(a b c d e) 2)
            ;; (list-without '(a b c d e) 0)
            ;; (list-without '(a b c d e) 4)
            
            (define increment
              (lambda (name name-number-list)
                ;; Returns a (name number) list in which the number paired with the given
                ;; name has been incremented by 1.
                (cond ((null? name-number-list) '())
                      ((equal? name (first (first name-number-list)))
                       (cons (list name (+ 1 (second (first name-number-list))))
                             (cdr name-number-list)))
                      (else (cons (car name-number-list)
                                  (increment name (cdr name-number-list)))))))
            
            ;; (increment 'foo '((bar 2) (foo 4) (baz 0)))
            
            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            ;; blackjack-specific procedures
            
            (define best-total
              (lambda (cards)
                ;; Returns the best total of the cards, using 1 or 11 for each 1
                (let ((raw-score
                       (if (member 1 cards)
                           (let* ((without1 (remove 1 cards))
                                  (score1 (+ 1 (apply + without1)))
                                  (score11 (+ 11 (apply + without1))))
                             (if (< score11 22)
                                 score11
                                 score1))
                           (apply + cards))))
                  (if (< raw-score 22)
                      raw-score
                      0))))
            
            ;; (best-total '(2 4 1 5))
            ;; (best-total '(10 1))
            ;; (best-total '(9 1 1))
            ;; (best-total '(9 9 9))
            ;; (best-total '(9 9 9 1))
            
            (define winner 
              (lambda (hands names)
                ;; Returns the name of the winner, assuming the hands and names
                ;; are in corresponding order.
                (let ((named-hands (shuffle (map list names hands)))) ;; shuffled to randomize ties
                  (car (car (sort named-hands
                                  (lambda (h1 h2)
                                    (if (= (best-total h1) (best-total h2))
                                        (< (length h1) (length h2))
                                        (> (best-total h1) (best-total h2))))
                                  #:key second))))))
            
            ;; (winner '((2 4 1 5) (10 1) (10 1) (9 1 1) (9 9 9) (9 9 9 1)) '(a b c d e f))
            
            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            ;; the top-level procedure
            
            (define tournament
              (lambda (games players)
                ;; Returns a sorted list of (name wins) lists.
                ;; Games is the number of games to play.
                ;; Players is a list of (name hit-function).
                ;; A hit-function takes a list of the player's cards and a list
                ;; of other-player-visible-cards lists.
                (let ((scores (map (lambda (p) (list (car p) 0)) players)))
                  (for ((game (in-range 0 games)))
                    (printf "\nGame #~A" game)
                    (let* ((cards (shuffle (four-decks)))
                           (names (shuffle (map car players))) ;; shuffle player order
                           (hands (map (lambda (x)             ;; deal initial cards
                                         (let ((my-cards (list (car cards)
                                                               (cadr cards))))
                                           (set! cards (cddr cards))
                                           my-cards))
                                       names))
                           (game-over #f)
                           (someone-hit #f))
                      (printf "\nInitial hands: ~A" (map list names hands))
                      (do ((turn 0 (+ turn 1)))
                        (game-over (let ((w (winner hands names)))
                                     (set! scores (increment w scores))
                                     (printf "\nGame won by ~A\n" w)))
                        (printf "\nTurn #~A" turn)
                        (set! someone-hit #f)
                        (do ((player-number 0 (+ player-number 1))) ;; ask each player if wants card
                          ((>= player-number (length players)))
                          (when (and (> (best-total (list-ref hands player-number)) 0) ;; can only hit if still alive
                                     ((cadr (assoc (list-ref names player-number) players))
                                      (list-ref hands player-number)
                                      (map cdr (list-without hands player-number))))
                            (set! hands (list-change hands 
                                                     player-number 
                                                     (append (list-ref hands player-number)
                                                             (list (car cards)))))
                            (printf "\n~A hit, now has ~A" (list-ref names player-number)
                                    (list-ref hands player-number))
                            (set! cards (cdr cards))
                            (set! someone-hit #t)))
                        (unless someone-hit (set! game-over #t))
                        (unless (> (apply max (map best-total hands)) 0) (set! game-over #t)))))
                  (sort scores > #:key second))))
            
            ))
(sendcode '("all"
            (require "../datastore.ss")
            (require "../config.ss")
            (define-values (blackjack-put blackjack-get blackjack-clear)
              (let ((datastore-put (car DATASTORE)) (datastore-get (cadr DATASTORE)) (users (caddr DATASTORE)))
                (values
                 (lambda (user function)
                   (datastore-put "jack" `(,user ,function)))
                 (lambda ()
                   (map (lambda (user) `(,user ,(datastore-get "jack" (list user 0)))) (users)))
                 (lambda () (map (lambda (list) (datastore-put "jack" `(,(car list) ,(lambda (a b) #f)))) (blackjack-get))))))
            ))
