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
(require mzlib/string)
(provide ignoring-errors 
         run-and-print-with-label 
         reply-and-process-name-and-code 
         print-all-source)
;A basic function that runs whatever code you throw at it, in a string, ignoring
;every error that said code might have (returning #t). Should probably return
;a special value to indicate there was an error, but this is unnecessary for now.
(define (ignoring-errors input-string)
    (with-handlers ([(lambda (exn) #t) (lambda (exn) #t)])
      (eval (read-from-string input-string))))
;Formatting and printing function, mostly for the server but could be useful
;in a client if we want to implement peer-to-peer sorts of interactions. Should
;be made more configurable, e.g. with a format string (although I don't know 
;the scheme equivalent of CL's FORMAT). This whole string-of-DISPLAY-calls thing
;is ugly. D:
(define (run-and-print-with-label label-string code-string) 
  (display label-string) (display ":\t") (display code-string) (display "\n")
  (ignoring-errors code-string) (display "\n"))
;This appears to work! Takes a port to reply to and a function (taking two 
;arguments, the last two non-keyword arguments of this function), and optionally 
;a choice of what to reply with (default 'received)
(define (reply-and-process-name-and-code #:reply-to-port reply-to #:reply-with [reply 'received]  #:process-with-function function name-string code-string)
  (begin
    (write reply reply-to)
    (function name-string code-string)))
;Some preliminary tinkering with sending of source code re: AGPL compliance
(define (string-from-text-file text-file-port)
  (let ([return-string ""])
      (if (eof-object? (peek-string 1 0 text-file-port))
          return-string
          (string-append (read-line text-file-port) "\n" 
                           (string-from-text-file text-file-port)))))
(define (print-all-source)
  (let ([utilities (open-input-file "utilities.ss" #:mode 'text)]
        [server (open-input-file "server.ss" #:mode 'text)]
        [client (open-input-file "client.ss" #:mode 'text)]
        [license (open-input-file "COPYING" #:mode 'text)])
    (string-append "UTILITIES.SS:\n\n" (string-from-text-file utilities) "\n\n" 
                   "SERVER.SS:\n\n" (string-from-text-file server) "\n\n" 
                   "CLIENT.SS:\n\n" (string-from-text-file client) "\n\n"
                   "COPYING:\n\n" (string-from-text-file license))))

  