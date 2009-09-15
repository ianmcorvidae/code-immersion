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
#lang scheme/load
(let ([config-file-out (open-output-file "config.ss" #:exists 'replace)])
  (display "#lang scheme\n(require \"config-example.ss\")\n(provide (all-defined-out) (all-from-out \"config-example.ss\"))" config-file-out)
  (close-output-port config-file-out))
(require "server.ss") (require "utilities.ss")
(ignoring-errors
  (let loop ()
    (server)
    (display "tell clients to reregister, the server made a boo-boo") 
    (loop)))
