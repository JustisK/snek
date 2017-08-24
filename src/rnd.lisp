
(in-package :rnd)


(defun lget (l)
  (nth (random (length l)) l))


(defun aget (l)
  (aref l (random (length l))))


; NUMBERS AND RANGES


(defun rndi (a &optional b)
  (declare (integer a))
  ;(declare (type (or integer nil) b))
  (if (not b)
    (random a)
    (+ a (random (- (math:int b) a)))))


(defun rndi* (ab)
  (declare (list ab))
  (destructuring-bind (a b)
    ab
    (declare (integer a b))
    (+ a (random (- b a)))))


(defun rnd (&optional (x 1.0d0))
  (declare (double-float x))
  (random x))


(defun rndbtwn (a b)
  (declare (double-float a b))
  (+ a (random (- b a))))


(defun rnd* (&optional (x 1.0d0))
  (declare (double-float x))
  (- x (* 2.0d0 (random x))))


(defun mixed (x f)
  (declare (double-float x f))
  (+ (random (* f x)) (- x (* 2.0d0 (random x)))))


(defun rndspace (a b n &key order)
  (destructuring-bind (a b)
    (sort (list a b) #'<)
      (let ((d (math:dfloat (- b a))))
        (let ((res (math:nrep n (+ a (random d)))))
          (if order (sort res #'<) res)))))


(defun rndspacei (a b n &key order)
  (destructuring-bind (a b)
    (sort (list a b) #'<)
      (let ((d (math:int (- b a))))
        (let ((res (math:nrep n (+ a (random d)))))
          (if order (sort res #'<) res)))))


(defun bernoulli (p n)
  (loop for i from 0 below n collect
    (if (< (rnd:rnd) p)
      1d0
      0d0)))


; SHAPES


(defun -add-if (a xy)
  (if xy (vec:add a xy) a))


(defun on-circ (rad &key xy)
  (-add-if (vec:scale (vec:cos-sin (random (* PI 2.0d0))) rad) xy))



(defun in-circ (rad &key xy)
  (declare (double-float rad))
  (-add-if
    (let ((a (random 1.0d0))
          (b (random 1.0d0)))
      (declare (double-float a b))
      (if (< a b)
        (vec:scale (vec:cos-sin (* 2 PI (/ a b))) (* b rad))
        (vec:scale (vec:cos-sin (* 2 PI (/ b a))) (* a rad))))
    xy))


(defun in-box (sx sy &key xy)
    (-add-if
      (vec:vec (rnd* (math:dfloat sx))
               (rnd* (math:dfloat sy)))
      xy))


(defun on-line (a b)
  (declare (vec:vec a b))
  (vec:add a (vec:scale (vec:sub b a) (random 1.0d0))))


; WALKERS


(defun get-lin-stp (&optional (init 0.0d0))
  (let ((x (math:dfloat init)))
    (lambda (stp)
      (setf x (math:inc x (rnd* stp))))))


(defun get-lin-stp* (&optional (init 0.0d0))
  (let ((x (math:dfloat init)))
    (lambda (stp)
      (incf x (rnd* stp)))))


(defun get-acc-lin-stp (&optional (init-x 0.0d0) (init-a 0.0d0))
  (let ((a (math:dfloat init-a))
        (x (math:dfloat init-x)))
    (lambda (s)
      (setf x (math:inc x (incf a (rnd* s)))))))


(defun get-acc-lin-stp* (&optional (init-x 0.0d0) (init-a 0.0d0))
  (let ((a (math:dfloat init-a))
        (x (math:dfloat init-x)))
    (lambda (s)
      (incf x (incf a (rnd* s))))))


(defun get-circ-stp* (&optional (init (vec:vec 0.0d0 0.0d0)))
  (let ((xy (vec:copy init)))
    (lambda (stp)
      (setf xy (vec:add xy (in-circ stp))))))


(defun get-acc-circ-stp* (&optional (init (vec:vec 0.0d0 0.0d0))
                                    (init-a (vec:vec 0.0d0 0.0d0)))
  (let ((a (vec:copy init-a))
        (xy (vec:copy init)))
    (lambda (stp)
      (setf xy (vec:add xy (setf a (vec:add a (in-circ stp))))))))
