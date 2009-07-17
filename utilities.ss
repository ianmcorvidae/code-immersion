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
(provide ignoring-errors run-and-print-with-label reply-and-process-name-and-code)
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
;hopefully this works
(define (reply-and-process-name-and-code #:reply-to-port reply-to #:reply-with [reply 'received]  #:process-with-function function name-string code-string)
  (begin
    (write reply reply-to)
    (function name-string code-string)))
