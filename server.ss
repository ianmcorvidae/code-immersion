#lang scheme
(require scheme/tcp)
(require "utilities.ss")
(define (server)
  (let ([listener (tcp-listen 2000)])
    (let-values ([(client->me me->client)
                  (tcp-accept listener)])
      (let ([code-read (read client->me)])
        (if code-read
            (run-and-print-with-label "Unknown Client" code-read)
            (write 'who-are-you? me->client)))
          (close-output-port me->client)
          (close-input-port client->me))))
  