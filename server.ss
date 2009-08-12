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
(provide server)
(require "utilities.ss")
;new testing server just prints out what it's given. To be moved later, probably into a package of tests.
(define (new-server #:port [port 2000])
  (let ([listener (tcp-listen port)])
    (let loop ()
      (let-values ([(client->me me->client)
                    (tcp-accept listener)])
        (let ([s-read (read client->me)])
          (print s-read))
        (close-output-port me->client)
        (close-input-port client->me))
      (loop))))
;The server! This could possibly be better-named. Anyway, configurable port --
;for now assuming that we want it to just listen on every address. Right now, 
;only sending of source really works.

;TODO: Make everything else work again
(define (server #:port [port 2000])
  (let ([listener (tcp-listen port)])
    ;So it keeps going, and going, and going...
    (let loop ()
      (let-values ([(client->me me->client)
                    (tcp-accept listener)])
        ;Reading the s-expression that should have been sent by a client, 
        ;verifying it, then processing it based on the type
        (let ([data (read client->me)])  
          (if (verify-data data)
          ;Check what exactly they want with a cond over (eq? type ...)
            (let ([name (car data)]
                  [type (cadr data)]
                  [message (caddr data)])
              (cond 
                ;Send source to the client (AGPL compliance).
                [(equal? type "source")
                 (write (print-all-source) me->client)]
                ;TODO: Write some sort of interactive help.
                [(equal? type "help")
                 (write "Help is not yet implemented" me->client)]
                ; Registration function -- currently sends two strings then 
                ; causes an exit on the clientside
                [(equal? type "register")
                 ;(register-client me->client)
                 (write "Registration is not yet implemented" me->client)
                 (write "sending test second string" me->client)
                 (write "break" me->client)]
                ;Dispatching text
                [(equal? type "text")
                 ;(dispatch-message message)
                 (write "Text dispatching is not yet implemented" me->client)]
                ;Dispatching code
                [(equal? type "code")
                 ;(dispatch-code message)
                 ;(reply-and-process-name-and-code 
                 ; #:reply-to-port me->client 
                 ; #:process-with-function run-and-print-with-label 
                 ; name-read code-read)
                 (write "Code dispatching is not yet implemented" me->client)]
                ;Else be upset
                [else (write (format "Invalid type: ~a" type) me->client)]))
            (write "Malformed data" me->client)))
        (close-output-port me->client)
        (close-input-port client->me))
      (loop))))
  
