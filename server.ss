#lang scheme
(require scheme/tcp)
(provide server)
(require "utilities.ss")
(define (server #:port [port 2000])
  (let ([listener (tcp-listen port)])
    (let loop ()
    (let-values ([(client->me me->client)
                  (tcp-accept listener)])
      (let ([name-read (read client->me)] [code-read (read client->me)])
        (if code-read
            (begin (write 'received me->client) (run-and-print-with-label name-read code-read))
            (write 'wtf? me->client)))
          (close-output-port me->client)
          (close-input-port client->me))
      (loop))))
  
