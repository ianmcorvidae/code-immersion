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
(provide send-to-server)
;The lowest-level "send some code to the server" function
(define (send-to-server #:name [name-string "Unconfigured Name"] code-string #:server [server "localhost"] #:port [port 2000])
  (let-values ([(server->me me->server)
                (tcp-connect server port)])
    ;This is sort of hackish, it seems to me, but this just writes the name-string 
    ;and then the code-string (which is expected to be a single s-expression) to 
    ;the TCP port. read-from-string should (is!) very nice about doing this right,
    ;although it might cause nasty choking if someone sends improper input. To fix.
    (write name-string me->server) 
    (write code-string me->server)
    (close-output-port me->server)
    ;A product of the tutorial I was copying from -- however, it is probably useful
    ;to have the client get a response from the server indicating success or failure.
    (let ([response (read server->me)])
      (display response) (newline)
      (close-input-port server->me))))
