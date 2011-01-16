(in-package #:external-program)

(defun rename-parameter (from-name to-name rest)
  (setf (getf rest to-name) (getf rest from-name))
  (remf rest from-name)
  rest)

(defun stringify-args (args)
  (mapcar (lambda (arg)
            (typecase arg
              (sequence              (coerce arg 'string))
              ((or symbol character) (string arg))
              (number                (format nil "~a" arg))
              (pathname              (namestring arg))))
          args))

(defun reformat-environment (environment)
  "SBCL accepts vars as either (\"FOO=meh\" ...) or ((:foo . \"meh\")
  ...), but not ((\"FOO\" . \"meh\") ...), so we build up the first
  kind (since the second kind is potentially lossy)."
  ;; FIXME: probably need to escape single-quotes and backslashes
  (mapcar (lambda (var) (format nil "~a=~s" (car var) (cdr var))) environment))

(defun make-shell-string (program args environment replace-environment-p)
  (format nil "~:[~;env -i PATH=''~] ~:{~a=~s ~}~a~{ ~s~}"
          replace-environment-p
          (reformat-environment environment)
          program
          (stringify-args args)))
