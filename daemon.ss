;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Copyright 2009 Ian McEwen                                                    ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;This file is part of the Code-Immersion software collaboration framework.    ;
;                                                                             ;
;    Code-Immersion is free software: you can redistribute it and/or modify   ;
;    it under the terms of the GNU Affero General Public License as published ; 
;     by the Free Software Foundation, either version 3 of the License, or    ;
;    (at your option) any later version.                                      ;
;                                                                             ;
;    Code-Immersion is distributed in the hope that it will be useful,        ;
;    but WITHOUT ANY WARRANTY; without even the implied warranty of           ;
;    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            ;
;    GNU Affero General Public License for more details.                      ;
;                                                                             ;
;    You should have received a copy of the GNU Affero General Public License ;
;    along with Code-Immersion.  If not, see <http://www.gnu.org/licenses/>.  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#lang scheme
(require scheme/tcp)
(require "utilities.ss")
(require "datastore.ss")
(require "config.ss")
(provide daemon register-with)
;registration function
;#:server Server hostname or IP, as a string.
;#:port Server port, as an integer.
(define (register-with #:server [server SERVER] #:port [port SERVER-PORT] #:datastore-put [datastore-put (car DATASTORE)] #:datastore-get [datastore-get (cadr DATASTORE)])
  (let-values ([(server->me me->server)
                (tcp-connect server port)])
    ;This is in standard (NAME TYPE MESSAGE) format, except you only really need
    ;type for this. Hence.
    (write `("" "register" "") me->server)
    ;clean up output port, then loop over the input port for responses from server
    (close-output-port me->server) 
    (do ([exit-loop #f]) (exit-loop)
      (let ([response (read server->me)])
        (cond
          [(eof-object? response)] 
          [(equal? response "break") (set! exit-loop #t)]
          [else (format-prettily response) (datastore-put (cadr response) `(,(car response) ,(caddr response)))]))
      (sleep 1))
    (close-input-port server->me)))

;the daemon itself
(define (daemon #:server [server SERVER] #:server-port [server-port SERVER-PORT] #:self-port [self-port DAEMON-PORT] #:datastore-put [datastore-put (car DATASTORE)] #:datastore-get [datastore-get (cadr DATASTORE)])
  (let ([register-thread (thread (λ () (register-with #:server server #:port server-port)))])
    (define-listener-and-verifier self-port #t
      (;Send source to the client (AGPL compliance).
       [(equal? type "source")
        (write (print-all-source) me->client)]
       ;TODO: Write some sort of interactive help.
       [(equal? type "help")
        (write "Help is not yet implemented" me->client)]
       ;For text
       [(equal? type "text")
        (write `(,(string-append (car message) (format " index ~a" (cadr message))) "text" ,(datastore-get "text" message)) me->client)]
       ;For code
       [(equal? type "code")
        (write `(,(string-append (car message) (format " index ~a" (cadr message))) "code" ,(datastore-get "code" message)) me->client)]
       ;For re-registering
       [(equal? type "reregister")
        (kill-thread register-thread)
        (set! register-thread (thread (λ () (register-with #:server server #:port server-port))))
        (write `("daemon" "text" "Reregistered.") me->client)]
       ;Else be upset
       [else (write `("server" "text" ,(format "Invalid type: ~a" type)) me->client)]))))
