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
;The server! This could possibly be better-named. Anyway, configurable port --
;for now assuming that we want it to just listen on every address.
(define (server #:port [port 2000])
  (let ([listener (tcp-listen port)])
    ;So it keeps going, and going, and going...
    (let loop ()
    (let-values ([(client->me me->client)
                  (tcp-accept listener)])
      ;Reading the two s-expressions that should be sent by clients --- name
      ;followed by a single s-expression of code. Will probably choke on bad
      ;input. Possibly irrecoverably. Fix at some point, or, well, don't do that.
      (let ([name-read (read client->me)] [code-read (read client->me)])
        (if code-read
	    ;Tell the client that we got what they said... or didn't. For now,
	    ;this uses run-and-print-with-label from utilities.ss, but this 
	    ;should be replaced with a queueing system. Note: currently, this 
	    ;should never ever fail, hence the 'wtf?'
            (begin (write 'received me->client) (run-and-print-with-label name-read code-read))
            (write 'wtf? me->client)))
          (close-output-port me->client)
          (close-input-port client->me))
      (loop))))
  
