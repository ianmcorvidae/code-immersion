#lang scheme/load
(require "../client.ss")
(require "../utilities.ss")

(define thread-list null)

(define (kill-all-threads)
  (for-each kill-thread thread-list)
  (set! thread-list null))

(define run-once
  (let ((database (make-hash)))
    (lambda (user)
      (let* ((message (request-code #:number 0 #:from user))
             (code (third message)))
        (cond
          ((equal? code "invalid") #f)
          ((equal? code (hash-ref database user #f)) #f)
          ((equal? code "kill-all-threads") (kill-all-threads))
          (else 
           (set! thread-list (cons (thread (lambda () 
                                             (hash-set! database user code)
                                             (printf "~a:\t" user)
                                             (if (list? code)
                                                 (if (equal? (car code) "all")
                                                     (last (map ignoring-errors (cdr code)))
                                                     (ignoring-errors code))
                                                 (ignoring-errors code))
                                             (newline)))
                                   thread-list))))))))

(define the-loop
  (lambda ()
    (for-each run-once (users))
    (sleep 1)
    (the-loop)))
           
(the-loop)
