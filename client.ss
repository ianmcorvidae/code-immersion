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
(require "config.ss")
(provide (all-defined-out))
;The lowest-level "send something somewhere" function
;#:name Your identifier to the server, as a string.
;#:place Server/Daemon hostname or IP, as a string.
;#:port Server/Daemon port, as an integer.
;#:type Type of message, as a string. 
;       Standard values: "code" "text" "register" "source"
;message Content of message. For text messages, string. 
;                            For code, quoted expressions.
;                            For other operations, blank string.
(define (send-to #:name [name NAME] #:place place #:port port #:type type message)
  (let-values ([(place->me me->place)
                (tcp-connect place port)])
    ;Doing this right for once: now it sends a pretty s-expression
    (write `(,name ,type ,message) me->place)
    ;clean up, clean up, everybody everywhere...
    (close-output-port me->place)
    ;listen for a response, which it should give!
    (let ([response (read place->me)])
      (close-input-port place->me)
      response)))
;Send something to server. Parameters as above, except s/place/server|daemon/ as applies
(define (send-to-server #:name [name NAME] #:server [server SERVER] #:port [port SERVER-PORT] #:type type message)
  (send-to #:name name #:place server #:port port #:type type message))
(define (send-to-daemon #:name [name NAME] #:daemon [daemon DAEMON] #:port [port DAEMON-PORT] #:type type message)
  (send-to #:name name #:place daemon #:port port #:type type message))
;Send code to everyone with this; all parameters as send-to-server except code: quoted code to be sent
(define (send-code #:name [name NAME] #:server [server SERVER] #:port [port SERVER-PORT] code)
  (send-to-server #:name name #:server server #:port port #:type "code" code))
;Send a message to everyone with this; all parameters as send-to-server except message, which will always be a string.
(define (send-message #:name [name NAME] #:server [server SERVER] #:port [port SERVER-PORT] message)
  (send-to-server #:name name #:server server #:port port #:type "text" message))
;Request message from the daemon
(define (request-message #:number index #:from name #:daemon [daemon DAEMON] #:port [port DAEMON-PORT])
  (send-to-daemon #:daemon daemon #:port port #:type "text" `(,name ,index)))
;Request code from the daemon
(define (request-code #:number index #:from name #:daemon [daemon DAEMON] #:port [port DAEMON-PORT])
  (send-to-daemon #:daemon daemon #:port port #:type "code" `(,name ,index)))
;Pretty-print requested message
(define (display-message #:number index #:from name #:daemon [daemon DAEMON] #:port [port DAEMON-PORT] #:format-string [format-string FORMAT-STRING])
  (format-prettily (request-message #:number index #:from name #:daemon daemon #:port port) #:format-string format-string))
;Pretty-print requested code
(define (display-code #:number index #:from name #:daemon [daemon DAEMON] #:port [port DAEMON-PORT] #:format-string [format-string FORMAT-STRING])
  (format-prettily (request-code #:number index #:from name #:daemon daemon #:port port) #:format-string format-string))
;Evaluate requested code
(define (evaluate-code #:number index #:from name #:daemon [daemon DAEMON] #:port [port DAEMON-PORT])
  (eval (caddr (request-code #:number index #:from name #:daemon daemon #:port port))))
;get
(define (get type name index #:daemon (daemon DAEMON) #:port (port DAEMON-PORT) #:format-string (format-string FORMAT-STRING))
  (cond
    [(or (equal? type "text") (equal? type "t") (equal? type "m") (equal? type "message")) (display-message #:number index #:from name #:daemon daemon #:port port #:format-string format-string)]
    [(or (equal? type "code") (equal? type "c")) (display-code #:number index #:from name #:daemon daemon #:port port #:format-string format-string)]
    [else (format-prettily '("self" "text" "huh?"))]))
;run
(define (run name index #:daemon (daemon DAEMON) #:port (port DAEMON-PORT))
  (evaluate-code #:number index #:from name #:daemon daemon #:port port))
;send
(define (send type content #:name [name NAME] #:server [server SERVER] #:port [port SERVER-PORT])
  (format-prettily (cond
                     [(or (equal? type "text") (equal? type "t") (equal? type "m") (equal? type "message")) (send-message #:name name #:server server #:port port content)]
                     [(or (equal? type "code") (equal? type "c")) (send-code #:name name #:server server #:port port content)]
                     [else '("self" "text" "huh?")])))
;rereg
(define (reregister #:daemon (daemon DAEMON) #:port (port DAEMON-PORT))
  (format-prettily (send-to-daemon #:daemon daemon #:port port #:type "reregister" "")))