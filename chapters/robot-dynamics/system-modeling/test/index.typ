#import "/lib.typ": *

#show: docs-subsubchapter.with(
  title: [Test $2 ii ee^(ii theta)$],
  route: "test",
  description: "State-space modeling and control-affine dynamics.",
)

Usually, controlling a system involves using a loop that adjusts the input of the system by observing the state of the system. How exactly the observants affect the input and how to design this relationship to change the system to a desired state is the study of control theory.

The mathematical background consists mainly of nonlinear differential equations and linear algebra.

Mostly, for differential equations, we will consider how the state vector would change given the current state vector and the control input.

Let $vb(x)$ be the state vector, and let $vb(u)$ be the set of control inputs. Then this relationship is modelled by some function $f$ of $vb(x)$ and $vb(u)$ with $ dot(vb(x)) = vb(f)(vb(x), vb(u)). $

In the linear case, $ dot(vb(x)) = vb(A x + B u). $

In many mechanical systems, by virtue of Newton's second law, which states that force changes the second-order derivative of position, $dot.double(vb(q))$, depends on both the generalized positions $vb(q)$, and the generalized velocities $dot(vb(q))$. Therefore, $ dot.double(vb(q)) = vb(f)(vb(q), dot(vb(q)), vb(u)), $ as a second-order system. The state of a system comprises not only the positions, but their velocities. Then we write that
$
  vb(x) = mat(vb(q); dot(vb(q))), quad "and" quad vb(x) = mat(dot(vb(q)); dot.double(vb(q))) = mat(dot(vb(q)); vb(f)(vb(q), dot(vb(q)), dot(vb(u)))).
$
If $vb(u)$ represents the motor torques (for example), and the generalized positions measure angles, then this is typically written as
$
  dot.double(vb(q)) = vb(f)_1(vb(q), dot(vb(q))) + vb(f)_2 (vb(q), dot(vb(q))) vb(u), #tag[$(dagger)$]
$
where $vb(f_1)(dot) in RR^m$ is a vector with dimensionality matching $vb(q) in RR^m$, and $vb(f_1)$ is a matrix of dimension $m times n$.

_Affinity_ is perceived with respect to the control input $vb(u) in RR^n$ (hence _control affine_), and the equation above is affine in $vb(u)$ since it is a linear transformation of it.

#explicit-label(<def:qqq>, definition([Much], restate: true, restate-keys: ("test",))[
  Ah vous dirai je maman
])

#proof[
  #lorem(40)
  $
    integral integral integral integral integral integral integral integral integral integral integral integral dx dx dx dx dx dx dx qedhere
  $
  #lorem(2)
  $ F = m a $
  #lorem(2)
  #explicit-label($ F = m a $, <eq:test-alignment>)
  #lorem(2)
  $ F = m a $
  #lorem(2)
  #explicit-label($ F = m a $, <eq:test-alignment>)
]

#solution[of a test][
  #lorem(40)
  + #lorem(20)
  + #lorem(20)
  + #lorem(20) #qedhere
]
Obviously, in the case that $vb(f)_2$ has more rows ($m$) than columns ($n$), then the rank of $vb(f)_2$ is at most $n$, whereas the dimensionality of $vb(q)$, or $m$, is greater than $n$. Thus, in this case the system will always be underactuated. We provide a heuristic or intuitive explanation; since there are less control inputs than the positions we wish to control, we do not _have full control_ of the system. Refer to @def:qqq

#lbl(
  figure(
    canvas({
      import cetz.draw: *
      import cetz.decorations: brace

      catmull(
        (-3.3, -0.8),
        (-0.5, -2.5),
        (1.5, -1.6),
        (3.5, 0.2),
        (2.0, 4.2),
        (-1.5, 4.0),
        (-2.3, 2.4),
        (-3.2, 0.2),
        close: true,
        tension: 0.5,
        stroke: (thickness: 0.35pt),
        name: "vn+1",
      )

      catmull(
        (-3.0, -0.8),
        (-0.5, -2.1),
        (1.5, -1.2),
        (2.8, 0.5),
        (1.8, 3.5),
        (-0.8, 3.7),
        (-1.9, 2.4),
        (-2.8, 0.2),
        close: true,
        tension: 0.5,
        stroke: (thickness: 0.5pt),
        name: "vn",
      )

      catmull(
        (-2.5, -0.8),
        (-0.5, -1.8),
        (1.5, -0.8),
        (2.5, 1.3),
        (1.5, 2.9),
        (-0.5, 3.2),
        (-1.5, 2.2),
        (-2.5, 0.2),
        close: true,
        tension: 0.5,
        stroke: (thickness: 0.65pt),
        name: "vn-1",
      )

      catmull(
        (-2.3, -0.3),
        (-0.5, -1.3),
        (1.0, -0.4),
        (1.7, 0.9),
        (1.9, 2.2),
        (-0.5, 2.7),
        (-1.0, 2.2),
        (-1.5, 1.2),
        close: true,
        tension: 0.5,
        stroke: (thickness: 1pt),
        name: "kn-2",
      )

      // dotted subcovers remain the same
      let subcover_arrays = (
        ((1.9, 2.5), (2.0, 3.6), (0.2, 3.9), (0.0, 2.8), (1.0, 2.9)),
        ((-1.3, 2.2), (-1.8, 2.7), (-1.3, 3.6), (-0.9, 3.9), (0.2, 3.8), (-0.1, 3.0), (-1.0, 2.6)),
        ((-1.3, 2.2), (-1.8, 2.7), (-1.3, 3.6), (-0.9, 3.9), (0.2, 3.8), (-0.1, 3.0), (-1.0, 2.6)),
        ((-3.0, 0.2), (-2.7, 1.2), (-1.9, 2.8), (-1.0, 2.5), (-1.8, 1.2), (-2.3, 0.2), (-2.5, -0.6)),
        ((-2.5, -1.3), (-0.3, -2.4), (-0.5, -1.7), (-1.5, -1.3), (-2.5, -0.5), (-2.8, 0.2), (-3.0, 0.2), (-3.2, -0.6)),
        ((-0.5, -1.6), (1.0, -1.0), (1.5, -0.1), (2.7, -0.1), (1.0, -1.7), (-0.7, -2.2)),
        ((1.5, -0.6), (1.8, 0.4), (3.0, 1.2), (3.1, 0.2)),
        ((3.0, 0.6), (2.3, 0.7), (2.1, 2.0), (1.7, 2.6), (1.9, 3.0), (2.4, 3.1)),
      )
      for points in subcover_arrays {
        catmull(..points, close: true, tension: 0.5, stroke: 0.5pt, fill: dot-tiling())
      }

      hide({
        line((0, 0), (2, 10), name: "brace_test_line")
        line((0, 0), (.5, 10), name: "label_test_line")
      })

      intersections("label_sect_kn-2", "kn-2", "label_test_line")
      intersections("label_sect_vn-1", "vn-1", "label_test_line")
      intersections("label_sect_vn", "vn", "label_test_line")
      intersections("label_sect_vn+1", "vn+1", "label_test_line")

      intersections("brace_sects", "kn-2", "vn+1", "brace_test_line")

      content(
        ("label_sect_kn-2.0", 50%, "label_sect_vn-1.0"),
        math-rect($V_(n-1)$),
        anchor: "center",
      )
      content(
        ("label_sect_vn-1.0", 50%, "label_sect_vn.0"),
        math-rect($V_n$),
        anchor: "center",
      )
      content(
        ("label_sect_vn.0", 50%, "label_sect_vn+1.0"),
        math-rect($V_(n+1)$),
        anchor: "center",
      )

      content((0.0, 1.0), $K_(n-2)$, anchor: "north")
      brace(
        ("brace_sects.0", 2%, "brace_sects.1"),
        ("brace_sects.0", 98%, "brace_sects.1"),
        name: "wn-brace",
        amplitude: 7pt,
        stroke: (thickness: 1pt),
        flip: true,
      )
      content("wn-brace.content", math-rect($W_n$))
    }),
    caption: [Geometry of the finite subcover of $V_n subset W_n$ for some $n in NN$.],
  ),
  <fig:locally-finite-open-cover-existence>,
)
@fig:locally-finite-open-cover-existence

Really#footnote[Im done], I'm done with #lorem(40) and know that $ #[know that @fig:locally-finite-open-cover-existence is true] $
#footnote[Im done $2 uppi$]

$
  & norm(bold(sigma)(w_1) - bold(sigma)(w_2)) \
  & wide""= sqrt(
    & ((2 Re w_1)/(abs(w_1)^2+1) - (2 Re w_2)/(abs(w_2)^2+1))^2
      + ((2 Im w_1)/(abs(w_1)^2+1) - (2 Im w_2)/(abs(w_2)^2+1))^2 \
    & ""+ ((abs(w_1)^2-1)/(abs(w_1)^2+1) - (abs(w_2)^2-1)/(abs(w_2)^2+1))^2
  ) \
  & wide""= 1/((abs(w_1)^2+1)(abs(w_2)^2+1)) \
  & wide quad ""times sqrt(
    & 4 Re[w_1(abs(w_2)^2+1) - w_2(abs(w_1)^2+1)]^2 \
    & ""+ 4 Im[w_1(abs(w_2)^2+1) - w_2(abs(w_1)^2+1)]^2 \
    & ""+[(abs(w_1)^2-1)(abs(w_2)^2+1) - (abs(w_2)^2-1)(abs(w_1)^2+1)]^2
  ) \
  & wide""= 2/(rho_1 rho_2) sqrt(abs(w_1 rho_2 - w_2 rho_1)^2 + (rho_1 - rho_2)^2) #tag[(where $rho_i = abs(w_i)^2 + 1$)] \
  & wide""= 2 / (rho_1 rho_2) sqrt(rho_2^2 (rho_1 - 1) + rho_1^2 (rho_2 - 1) - 2 rho_2 rho_1 Re[w_1 overline(w_2)] + (rho_1 - rho_2)^2) \
  & wide""= 2 / (rho_1 rho_2) sqrt(rho_2^2 rho_1 + rho_1^2 rho_2 - 2 rho_2 rho_1 Re[w_1 overline(w_2)] - 2 rho_1 rho_2) #tag[(nah)] \
  & wide""= 2 / sqrt(rho_1 rho_2) sqrt(rho_2 + rho_1 - 2 Re[w_1 overline(w_2)] - 2) = (2 abs(w_1 - w_2)) / sqrt(rho_1 rho_2) = k(w_1, w_2) #tag[(hello!)] \
$
