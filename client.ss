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
(define (send-to #:name [name (NAME)] #:place place #:port port #:type type message)
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

;;; WHOLE BUNCH OF MIDDLEMAN CLIENT FUNCTIONS -- these have hyphens;;;
;Send code to everyone with this; all parameters as send-to-server except code: quoted code to be sent
(define (send-code #:name [name (NAME)] #:server [server (SERVER)] #:port [port (SERVER-PORT)] code)
  (send-to #:name name #:place server #:port port #:type "code" code))
;Send a message to everyone with this; all parameters as send-to-server except message, which will always be a string.
(define (send-text #:name [name (NAME)] #:server [server (SERVER)] #:port [port (SERVER-PORT)] message)
  (send-to #:name name #:place server #:port port #:type "text" message))
;Request message from the daemon
(define (request-text #:number index #:from name #:daemon [daemon (DAEMON)] #:port [port (DAEMON-PORT)])
  (send-to #:place daemon #:port port #:type "text" `(,name ,index)))
;Request code from the daemon
(define (request-code #:number index #:from name #:daemon [daemon (DAEMON)] #:port [port (DAEMON-PORT)])
  (send-to #:place daemon #:port port #:type "code" `(,name ,index)))
;Pretty-print requested message
(define (display-text #:number index #:from name #:daemon [daemon (DAEMON)] #:port [port (DAEMON-PORT)] #:format-string [format-string (FORMAT-STRING)])
  (format-prettily (request-text #:number index #:from name #:daemon daemon #:port port) #:format-string format-string))
;Pretty-print requested code
(define (display-code #:number index #:from name #:daemon [daemon (DAEMON)] #:port [port (DAEMON-PORT)] #:format-string [format-string (FORMAT-STRING)])
  (format-prettily (request-code #:number index #:from name #:daemon daemon #:port port) #:format-string format-string))
;Evaluate requested code
(define (evaluate-one #:number index #:from name #:daemon [daemon (DAEMON)] #:port [port (DAEMON-PORT)] #:eval-function [eval-function eval])
  (eval-function (caddr (request-code #:number index #:from name #:daemon daemon #:port port))))
;list-eval 
(define (evaluate-list #:number index #:from name #:daemon (daemon (DAEMON)) #:port (port (DAEMON-PORT)) #:eval-function (eval-function eval))
  (last (map eval-function (caddr (request-code #:number index #:from name #:daemon daemon #:port port)))))

;;; WHOLE BUNCH OF CLIENT FUNCTIONS -- these all don't have hyphens;;;
;;;
;get
(define (gettext name index #:daemon (daemon (DAEMON)) #:port (port (DAEMON-PORT)) #:format-string (format-string (FORMAT-STRING)))
    (display-text #:number index #:from name #:daemon daemon #:port port #:format-string format-string))
(define (getcode name index #:daemon (daemon (DAEMON)) #:port (port (DAEMON-PORT)) #:format-string (format-string (FORMAT-STRING)))
    (display-code #:number index #:from name #:daemon daemon #:port port #:format-string format-string))
;run
(define (run name index #:daemon (daemon (DAEMON)) #:port (port (DAEMON-PORT)) #:eval-function (eval-function eval) #:code (provided-code null))
  (let* ((message (request-code #:number index #:from name #:daemon daemon #:port port))
         (code (or provided-code (caddr message))))
         (if (list? code)
             (if (equal? (car code) "all")
                 (last (map eval-function (cdr code)))
                 (eval-function code))
             (eval-function code))))
;send
(define (sendtext content #:name [name (NAME)] #:server [server (SERVER)] #:port [port (SERVER-PORT)])
  (format-prettily (send-text #:name name #:server server #:port port content)))
(define (sendcode content #:name [name (NAME)] #:server [server (SERVER)] #:port [port (SERVER-PORT)])
  (format-prettily (send-code #:name name #:server server #:port port content)))
;rereg
(define (reregister #:daemon (daemon (DAEMON)) #:port (port (DAEMON-PORT)))
  (format-prettily (send-to #:place daemon #:port port #:type "reregister" ""))) 
(define (users #:daemon (daemon (DAEMON)) #:port (port (DAEMON-PORT)))
  (caddr (send-to #:place daemon #:port port #:type "users" "")))
(define (help #:long (long #f))
  (begin
    (display "(sendtext \"text\")\n   sends text") 
    (display (if long " (text must be in double-quotes)\n" "\n"))
    (display "(sendcode 'code)\n   sends code")
    (display (if long " (you'll probably want to quote it, as demonstrated)\n" "\n"))
    (display "(gettext \"name\" index)\n   displays text from others")
    (display (if long " (name in double-quotes, index is a number)\n" "\n"))
    (display "(getcode \"name\" index)\n   displays code from others")
    (display (if long " (name in double-quotes, index is a number)\n" "\n"))
    (display "(run \"name\" index)\n   runs code from others")
    (display (if long " (name in double-quotes, index is a number)\n" "\n"))
    (display "(reregister)\n   reregisters with server")
    (display (if long "; do this if you aren't getting messages others are sending\n" "\n"))
    (display "(users)\n   returns a list of users")
    (display (if long "; do this if you need such a list (perhaps for iteration)\n" "\n"))
    (if long (display "(help)\n   displays short help\n")
        (display "(help)\n   displays this message\n"))
    (if long (display "(long-help)\n   displays this message\n")
        (display "(long-help)\n   displays long help\n"))
    (display "To send more than one bit of code at once, use (sendcode '(\"all\" ...) with ... being your chunks of code.")))
(define (long-help)
  (help #:long #t))
  
