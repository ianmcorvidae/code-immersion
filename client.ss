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
(provide send-to-server register-with)
;registration function
;#:server Server hostname or IP, as a string.
;#:port Server port, as an integer.
(define (register-with #:server [server "localhost"] #:port [port 2000])
  (let-values ([(server->me me->server)
                (tcp-connect server port)])
    (write `("" "register" "") me->server)
    ;clean up, clean up, everybody everywhere...
    (close-output-port me->server) 
    (do ([exit-loop #f]) (exit-loop)
      (let ([response (read server->me)])
        (cond
          [(eof-object? response)] 
          [(equal? response "break") (set! exit-loop #t)]
          [else (begin (display response) (newline))])))
    (close-input-port server->me)))
;The lowest-level "send some code to the server" function
;#:name Your identifier to the server, as a string.
;#:server Server hostname or IP, as a string.
;#:port Server port, as an integer.
;#:type Type of message, as a string. 
;       Standard values: "code" "text" "register" "source"
;message Content of message. For text messages, string. 
;                            For code, quoted expressions.
;                            For other operations, blank string.
(define (send-to-server #:name [name "Unconfigured Name"] #:server [server "localhost"] #:port [port 2000] #:type type message)
  (let-values ([(server->me me->server)
                (tcp-connect server port)])
    ;Doing this right for once: now it sends a pretty s-expression
    (write `(,name ,type ,message) me->server)
    ;clean up, clean up, everybody everywhere...
    (close-output-port me->server)
    (let ([response (read server->me)])
      (display response) (newline)
      (close-input-port server->me))))
