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
(define (server #:port [port 2000])
  (let ([listener (tcp-listen port)])
    (let loop ()
    (let-values ([(client->me me->client)
                  (tcp-accept listener)])
      (let ([name-read (read client->me)] [code-read (read client->me)])
        (if code-read
            (begin (write 'received me->client) (run-and-print-with-label name-read code-read))
            (write 'wtf? me->client)))
          (close-output-port me->client)
          (close-input-port client->me))
      (loop))))
  
