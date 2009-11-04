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
(require "config.ss")
;Registration and getting of output ports -- closures!
(define-values (register-client get-output-port-list)
  (let ([output-port-list '()])
    (values
     (λ (port) (file-stream-buffer-mode port 'none) (set! output-port-list (cons port output-port-list)) (write '("server" "text" "Registered.") port))
     (λ () output-port-list))))
;Dispatching stuff (the function that actually does it)
(define (dispatch name type message)
  (for ([port (get-output-port-list)])
    (with-handlers (((lambda (exn) #t) (lambda (exn) (close-output-port port) #t)))
      (write `(,name ,type ,message) port))))
;The server! This could possibly be better-named. Anyway, configurable port --
;for now assuming that we want it to just listen on every address. Right now, 
;only sending of source really works.

;TODO: Make everything else work again
(define (server #:port [port (SERVER-PORT)])
  (define-listener-and-verifier port #f
    (
        ;Send source to the client (AGPL compliance).
        [(equal? type "source")
         (write (print-all-source) me->client)
         (close-output-port me->client)]
        ;TODO: Write some sort of interactive help.
        [(equal? type "help")
         (write "Help is not yet implemented" me->client)
         (close-output-port me->client)]
        ; Registration function -- currently sends two strings then 
        ; causes an exit on the clientside
        [(equal? type "register")
         (register-client me->client)]
        ;Dispatching text
        [(equal? type "text")
         (dispatch name type message)
         (write '("server" "text" "Dispatched.") me->client)
         (close-output-port me->client)]
        ;Dispatching code
        [(equal? type "code")
         (dispatch name type message)
         (write '("server" "text" "Dispatched.") me->client)
         (close-output-port me->client)]
        ;Else be upset
        [else (write `("server" "text" ,(format "Invalid type: ~a" type)) me->client) 
              (close-output-port me->client)])))

  
